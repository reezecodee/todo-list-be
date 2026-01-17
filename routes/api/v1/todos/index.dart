import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:todo_backend/services/todo_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Ambil service yang sudah di-inject di middleware
  final service = context.read<TodoService>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getTodos(service);
    case HttpMethod.post:
      return _createTodo(context, service);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getTodos(TodoService service) async {
  final todos = await service.getAllTodos();
  return Response.json(body: todos);
}

Future<Response> _createTodo(
    RequestContext context, TodoService service) async {
  final json = await context.request.json() as Map<String, dynamic>;
  final title = json['title'] as String?;

  if (title == null || title.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Title is required'},
    );
  }

  final newTodo = await service.createTodo(title);
  return Response.json(statusCode: HttpStatus.created, body: newTodo);
}
