part of 'todo_cubit.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoEntity> pendingTodos;
  final List<TodoEntity> completedTodos;

  const TodoLoaded({required this.pendingTodos, required this.completedTodos});

  List<TodoEntity> get allTodos => [...pendingTodos, ...completedTodos];

  @override
  List<Object> get props => [pendingTodos, completedTodos];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object> get props => [message];
}
