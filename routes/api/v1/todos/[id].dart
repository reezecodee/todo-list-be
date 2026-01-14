import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  return Response.json(body: {
    'message': 'Ini halaman Detail Todo',
    'id_yang_dicari': id,
  });
}