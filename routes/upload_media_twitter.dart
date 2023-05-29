// ignore_for_file: avoid_dynamic_calls, cast_nullable_to_non_nullable, inference_failure_on_function_invocation

import 'package:dart_frog/dart_frog.dart';
import 'package:file/local.dart';
import 'package:supabase/supabase.dart';
import 'package:twitter_proxy_server/models/queue_tweet_model.dart';
import 'package:twitter_proxy_server/twitter_api.dart';

LocalFileSystem fs = const LocalFileSystem();

Future<Response> onRequest(RequestContext context) async {
  if (!context.request.headers.containsKey('Authorization')) {
    return Response.json(
      statusCode: 400,
      body: {
        'status': 'ERROR',
        'message': 'Authorization header is missing',
      },
    );
  }

  try {
    final body = await context.request.json();
    final serviceRole = (context.request.headers['Authorization'] as String)
        .replaceFirst('Bearer ', '');
    final supabaseUrl = body['supabaseUrl'];
    final supabase = SupabaseClient(
      supabaseUrl as String,
      serviceRole,
    );

    final queue =
        await supabase.from('queue').select().eq('id', body['queueId']);

    final userData =
        await supabase.from('info').select('twitter').eq('id', body['userId']);

    final authParams = userData.first['twitter'];

    final tweets = (queue.first['tweets'] as List<dynamic>)
        .map(QueueTweetModelEdge.fromMap)
        .toList();

    for (var i = 0; i < tweets.length; i++) {
      final tweet = tweets[i];
      final mediaIds = <String>[];

      for (final media in tweet.media) {
        final file = fs.file(media.url);
        final fileData = await file.readAsBytes();
        final mediaId = await TwitterApi.uploadMedia(
          apiKey: authParams['apiKey'] as String,
          apiSecretKey: authParams['apiSecretKey'] as String,
          oauthToken: authParams['oauthToken'] as String,
          mediaType: media.type,
          tokenSecret: authParams['oauthTokenSecret'] as String,
          body: fileData,
        );

        if (mediaId['statusCode'] != 200) {
          await supabase
              .from('queue')
              .update({'status': 'media_error'}).eq('id', body['queueId']);

          return Response.json(
            statusCode: 403,
            body: {
              'status': 'ERROR',
              'message': 'Media upload failed',
            },
          );
        }
        // delete the file from the server after uploading it to twitter.
        await file.delete();
        mediaIds.add(mediaId['id'].toString());
      }
      tweet.mediaIds = mediaIds;
    }
    await supabase
        .from('queue')
        .update({'tweets': tweets}).eq('id', body['queueId']);

    return Response.json(
      body: {'status': 'OK', 'message': 'DONE'},
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'ERROR',
        'message': 'Something went wrong',
      },
    );
  }
}
