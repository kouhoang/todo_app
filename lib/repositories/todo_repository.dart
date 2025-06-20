import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';
import 'package:todo_app/network/supabase_service.dart';

class TodoRepository {
  Future<List<TodoEntity>> getTodos(String userId) async {
    return await SupabaseService.getTodos(userId);
  }

  Future<TodoEntity> createTodo(CreateTodoParams params) async {
    return await SupabaseService.createTodo(params);
  }

  Future<TodoEntity> updateTodo(String todoId, UpdateTodoParams params) async {
    return await SupabaseService.updateTodo(todoId, params);
  }

  Future<void> deleteTodo(String todoId) async {
    return await SupabaseService.deleteTodo(todoId);
  }

  RealtimeChannel subscribeToTodos(
    String userId,
    Function(List<TodoEntity>) onUpdate,
  ) {
    return SupabaseService.subscribeToTodos(userId, onUpdate);
  }
}
