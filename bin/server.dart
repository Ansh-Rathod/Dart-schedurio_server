// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, implicit_dynamic_list_literal

import 'dart:io';

import 'package:dart_frog/dart_frog.dart';


import '../routes/upload_media_twitter.dart' as upload_media_twitter;
import '../routes/upload_media.dart' as upload_media;
import '../routes/post_tweet.dart' as post_tweet;
import '../routes/index.dart' as index;

import '../routes/_middleware.dart' as middleware;

void main() async {
  final address = InternetAddress.anyIPv6;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  createServer(address, port);
}

Future<HttpServer> createServer(InternetAddress address, int port) async {
  final handler = Cascade().add(createStaticFileHandler()).add(buildRootHandler()).handler;
  final server = await serve(handler, address, port);
  print('\x1B[92m✓\x1B[0m Running on http://${server.address.host}:${server.port}');
  return server;
}

Handler buildRootHandler() {
  final pipeline = const Pipeline().addMiddleware(middleware.middleware);
  final router = Router()
    ..mount('/', (context) => buildHandler()(context));
  return pipeline.addHandler(router);
}

Handler buildHandler() {
  final pipeline = const Pipeline();
  final router = Router()
    ..all('/upload_media_twitter', (context) => upload_media_twitter.onRequest(context,))..all('/upload_media', (context) => upload_media.onRequest(context,))..all('/post_tweet', (context) => post_tweet.onRequest(context,))..all('/', (context) => index.onRequest(context,));
  return pipeline.addHandler(router);
}
