import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_status.dart';
import 'package:todo_app/model/params/create_todo_param.dart';
import 'package:todo_app/model/params/update_todo_param.dart';
import 'package:todo_app/services/ios_notification_service.dart';
import '../../repositories/todo_repository.dart';

part 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository = TodoRepository();
  final NotificationService _notificationService = NotificationService();
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

  void _emitTodosLoaded(List<TodoEntity> todos) {
    final pendingTodos = todos
        .where((todo) => todo.status == TodoStatus.pending)
        .toList();

    final completedTodos = todos
        .where((todo) => todo.status == TodoStatus.completed)
        .toList();

    // Organize todos by time and date, handling null values
    pendingTodos.sort((a, b) {
      // First priority: time
      if (a.time != null && b.time != null) {
        return a.time!.compareTo(b.time!);
      } else if (a.time != null) {
        return -1; // a has time, b doesn't - a comes first
      } else if (b.time != null) {
        return 1; // b has time, a doesn't - b comes first
      }

      // Second priority: date
      if (a.date != null && b.date != null) {
        return a.date!.compareTo(b.date!);
      } else if (a.date != null) {
        return -1; // a has date, b doesn't - a comes first
      } else if (b.date != null) {
        return 1; // b has date, a doesn't - b comes first
      }

      // Both have no time or date, sort by created date
      return a.createdAt.compareTo(b.createdAt);
    });

    completedTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    emit(
      TodoLoaded(pendingTodos: pendingTodos, completedTodos: completedTodos),
    );
  }

  Future<void> createTodo(CreateTodoParams params) async {
    try {
      final newTodo = await _todoRepository.createTodo(params);

      // Schedule notification if todo has time
      if (newTodo.time != null) {
        await _notificationService.scheduleTodoNotification(newTodo);
      }

      await refreshTodos();
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> updateTodo(String todoId, UpdateTodoParams params) async {
    try {
      final updatedTodo = await _todoRepository.updateTodo(todoId, params);

      // Update notification
      await _notificationService.updateTodoNotification(updatedTodo);

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

      // Handle notification based on status
      if (newStatus == TodoStatus.completed) {
        await _notificationService.cancelTodoNotification(todo.id);
      } else if (todo.time != null) {
        await _notificationService.scheduleTodoNotification(todo);
      }
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoRepository.deleteTodo(todoId);
      await _notificationService.cancelTodoNotification(todoId);
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
