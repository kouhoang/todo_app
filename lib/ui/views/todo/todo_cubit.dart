import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_status.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';
import '../../../repositories/todo_repository.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository = TodoRepository();
  RealtimeChannel? _subscription;
  String? _currentUserId;

  TodoCubit() : super(TodoInitial());

  Future<void> loadTodos(String userId) async {
    _currentUserId = userId;
    emit(TodoLoading());

    try {
      final todos = await _todoRepository.getTodos(userId);
      _emitTodosLoaded(todos);

      // Unsubscribe previous subscription if exists
      await _subscription?.unsubscribe();

      // Subscribe to real-time updates
      _subscription = _todoRepository.subscribeToTodos(userId, (updatedTodos) {
        _emitTodosLoaded(updatedTodos);
      });
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  // Manual refresh method
  Future<void> refreshTodos() async {
    if (_currentUserId == null) return;

    try {
      final todos = await _todoRepository.getTodos(_currentUserId!);
      _emitTodosLoaded(todos);
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  // Helper method to parse and emit todos
  void _emitTodosLoaded(List<TodoEntity> todos) {
    final pendingTodos = todos
        .where((todo) => todo.status == TodoStatus.pending)
        .toList();

    final completedTodos = todos
        .where((todo) => todo.status == TodoStatus.completed)
        .toList();

    // Organize todos by time
    pendingTodos.sort((a, b) {
      if (a.time != null && b.time != null) {
        return a.time!.compareTo(b.time!);
      } else if (a.time != null) {
        return -1;
      } else if (b.time != null) {
        return 1;
      } else {
        return a.date.compareTo(b.date);
      }
    });

    completedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(
      TodoLoaded(pendingTodos: pendingTodos, completedTodos: completedTodos),
    );
  }

  Future<void> createTodo(CreateTodoParams params) async {
    try {
      await _todoRepository.createTodo(params);

      // Manual refresh to ensure UI is updated
      await refreshTodos();
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> updateTodo(String todoId, UpdateTodoParams params) async {
    try {
      await _todoRepository.updateTodo(todoId, params);

      // Manual refresh to ensure UI is updated
      await refreshTodos();
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> toggleTodoStatus(TodoEntity todo) async {
    try {
      final newStatus = todo.status == TodoStatus.pending
          ? TodoStatus.completed
          : TodoStatus.pending;

      await updateTodo(todo.id, UpdateTodoParams(status: newStatus));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoRepository.deleteTodo(todoId);

      // Manual refresh to ensure UI is updated
      await refreshTodos();
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  // Method to get todos by status
  List<TodoEntity> getTodosByStatus(TodoStatus status) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      return status == TodoStatus.pending
          ? currentState.pendingTodos
          : currentState.completedTodos;
    }
    return [];
  }

  // Method to get all todos by status
  List<TodoEntity> getAllTodos() {
    final currentState = state;
    if (currentState is TodoLoaded) {
      return currentState.allTodos;
    }
    return [];
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
