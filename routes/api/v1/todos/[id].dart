import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:todo_backend/services/todo_service.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final service = context.read<TodoService>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _getTodoById(id, service);
    case HttpMethod.put:
      return _updateTodo(context, id, service);
    case HttpMethod.delete:
      return _deleteTodo(id, service);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _getTodoById(String id, TodoService service) async {
  final todo = await service.getTodoById(id);
  if (todo == null) {
    return Response.json(
        statusCode: HttpStatus.notFound, body: {'error': 'Not found'});
  }
  return Response.json(body: todo);
}

Future<Response> _updateTodo(
    RequestContext context, String id, TodoService service) async {
  final json = await context.request.json() as Map<String, dynamic>;

  final updatedTodo = await service.updateTodo(
    id,
    title: json['title'] as String?,
    isCompleted: json['isCompleted'] as bool?,
  );

  if (updatedTodo == null) {
    return Response.json(
        statusCode: HttpStatus.notFound, body: {'error': 'Not found'});
  }

  return Response.json(body: updatedTodo);
}

Future<Response> _deleteTodo(String id, TodoService service) async {
  final success = await service.deleteTodo(id);
  if (!success) {
    return Response.json(
        statusCode: HttpStatus.notFound, body: {'error': 'Not found'});
  }
  return Response(statusCode: HttpStatus.noContent); // 204 No Content
}
