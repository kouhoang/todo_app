part of 'todo_cubit.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoEntity> todos;

  const TodoLoaded(this.todos);

  List<TodoEntity> get pendingTodos =>
      todos.where((todo) => todo.status == TodoStatus.pending).toList();

  List<TodoEntity> get completedTodos =>
      todos.where((todo) => todo.status == TodoStatus.completed).toList();

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}
