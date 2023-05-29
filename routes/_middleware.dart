import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog/src/http_method.dart' as method;
import 'package:twitter_proxy_server/api_keys.dart';

Handler middleware(Handler handler) {
  return (context) async {
    if (context.request.method != method.HttpMethod.post) {
      return Response.json(
        statusCode: 405,
        body: {'status': 'ERROR', 'message': 'Method not allowed'},
      );
    }

    final query = context.request.uri.queryParameters;
    if (query['sponcerKey'] == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'status': 'ERROR',
          'message':
              'sponcerKey parameter is missing in query! contact Ansh-Rathod.',
        },
      );
    }
    if (sponcerKey.firstWhere(
          (e) => query['sponcerKey'] == e,
          orElse: () => 'not',
        ) ==
        'not') {
      return Response.json(
        statusCode: 400,
        body: {
          'status': 'ERROR',
          'message': 'sponcerKey is invalid! contact Ansh-Rathod.',
        },
      );
    }

    final response = await handler(context);

    // Execute code after request is handled.

    // Return a response.
    return response;
  };
}
