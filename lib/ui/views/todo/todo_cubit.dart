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

  TodoCubit() : super(TodoInitial());

  Future<void> loadTodos(String userId) async {
    emit(TodoLoading());

    try {
      final todos = await _todoRepository.getTodos(userId);
      emit(TodoLoaded(todos));

      // Subscribe to real-time updates
      _subscription = _todoRepository.subscribeToTodos(userId, (updatedTodos) {
        emit(TodoLoaded(updatedTodos));
      });
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> createTodo(CreateTodoParams params) async {
    try {
      await _todoRepository.createTodo(params);
      // The real-time subscription will automatically update the state
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> updateTodo(String todoId, UpdateTodoParams params) async {
    try {
      await _todoRepository.updateTodo(todoId, params);
      // The real-time subscription will automatically update the state
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> toggleTodoStatus(TodoEntity todo) async {
    final newStatus = todo.status == TodoStatus.pending
        ? TodoStatus.completed
        : TodoStatus.pending;

    await updateTodo(todo.id, UpdateTodoParams(status: newStatus));
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await _todoRepository.deleteTodo(todoId);
      // The real-time subscription will automatically update the state
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.unsubscribe();
    return super.close();
  }
}
