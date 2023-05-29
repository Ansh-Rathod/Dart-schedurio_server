// ignore_for_file: avoid_dynamic_calls, cast_nullable_to_non_nullable, inference_failure_on_function_invocation

import 'package:dart_frog/dart_frog.dart';
import 'package:file/local.dart';
import 'package:uuid/uuid.dart';

LocalFileSystem fs = const LocalFileSystem();
Future<Response> onRequest(RequestContext context) async {
  try {
    final body = await context.request.formData();
    const uuid = Uuid();
    if (body.files['media'] == null) {
      return Response.json(
        statusCode: 400,
        body: {
          'status': 'ERROR',
          'message': 'File is missing!',
        },
      );
    }
    final fileId = uuid.v4();

    final file =
        await fs.file('public/${fileId}_${body.files['media']!.name}').create();
    await file.writeAsBytes(await body.files['media']!.readAsBytes());
    return Response.json(
      body: {
        'status': 'OK',
        'message': 'File uploaded!',
        'file': 'public/${fileId}_${body.files['media']!.name}'
      },
    );
  } catch (e) {
    print(e);
    return Response.json(
      statusCode: 500,
      body: {
        'status': 'ERROR',
        'message': 'Something went wrong',
      },
    );
  }
}
