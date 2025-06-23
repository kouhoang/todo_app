import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/entities/user_entity.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // User operations
  static Future<UserEntity?> createUser(String deviceId) async {
    try {
      final response = await _client
          .from('users')
          .insert({
            'device_id': deviceId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return UserEntity.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserEntity?> getUserByDeviceId(String deviceId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      return response != null ? UserEntity.fromMap(response) : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Todo operations
  static Future<List<TodoEntity>> getTodos(String userId) async {
    try {
      final response = await _client
          .from('todos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((todo) => TodoEntity.fromMap(todo)).toList();
    } catch (e) {
      throw Exception('Failed to get todos: $e');
    }
  }

  static Future<TodoEntity> createTodo(CreateTodoParams params) async {
    try {
      final response = await _client
          .from('todos')
          .insert(params.toMap())
          .select()
          .single();

      return TodoEntity.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create todo: $e');
    }
  }

  static Future<TodoEntity> updateTodo(
    String todoId,
    UpdateTodoParams params,
  ) async {
    try {
      final response = await _client
          .from('todos')
          .update(params.toMap())
          .eq('id', todoId)
          .select()
          .single();

      return TodoEntity.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update todo: $e');
    }
  }

  static Future<void> deleteTodo(String todoId) async {
    try {
      await _client.from('todos').delete().eq('id', todoId);
    } catch (e) {
      throw Exception('Failed to delete todo: $e');
    }
  }

  // Improved Real-time subscription
  static RealtimeChannel subscribeToTodos(
    String userId,
    Function(List<TodoEntity>) onUpdate,
  ) {
    final channel = _client.channel('public:todos:user_id=eq.$userId');

    return channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'todos',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            print('Real-time update received: ${payload.eventType}');
            try {
              // Refresh todos when changes occur
              final todos = await getTodos(userId);
              onUpdate(todos);
            } catch (e) {
              print('Error in real-time callback: $e');
            }
          },
        )
        .subscribe();
  }
}
