import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/global/auth/auth_cubit.dart';
import 'package:todo_app/ui/views/todo/todo_cubit.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/item_position.dart';
import 'package:todo_app/ui/widgets/todo_item_widget.dart';
import '../../../utils/date_utils.dart';
import '../add_todo/add_todo_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = TodoCubit();
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthAuthenticated) {
          cubit.loadTodos(authState.user.id);
        }
        return cubit;
      },
      child: const _HomeViewBody(),
    );
  }
}

class _HomeViewBody extends StatelessWidget {
  const _HomeViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: Column(
        children: [
          // Header
          Expanded(flex: 1, child: _buildHeader()),
          // Content area
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(color: AppColors.background),
              child: _buildTodoList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoModel(context),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Ellipse images
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset('assets/ellipse_2.png', fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Image.asset('assets/ellipse_1.png', fit: BoxFit.cover),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppDateUtils.formatDate(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'My Todo List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is TodoLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TodoError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<TodoCubit>().loadTodos(authState.user.id);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TodoLoaded) {
          final pendingTodos = state.pendingTodos;
          final completedTodos = state.completedTodos;

          if (pendingTodos.isEmpty && completedTodos.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<TodoCubit>().refreshTodos();
              },
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No todos yet',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first todo',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<TodoCubit>().refreshTodos();
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Pending todos section
                if (pendingTodos.isNotEmpty) ...[
                  _buildSectionHeader('Tasks', pendingTodos.length),
                  const SizedBox(height: 16),
                  _buildTodoGroup(context, pendingTodos, false),
                ],

                // Spacing between sections
                if (pendingTodos.isNotEmpty && completedTodos.isNotEmpty)
                  const SizedBox(height: 32),

                // Completed todos section
                if (completedTodos.isNotEmpty) ...[
                  _buildSectionHeader('Completed', completedTodos.length),
                  const SizedBox(height: 16),
                  _buildTodoGroup(context, completedTodos, true),
                ],

                // Bottom spacing for FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildTodoGroup(
    BuildContext context,
    List<TodoEntity> todos,
    bool isCompleted,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: todos.asMap().entries.map((entry) {
          final index = entry.key;
          final todo = entry.value;

          ItemPosition position;
          if (todos.length == 1) {
            position = ItemPosition.single;
          } else if (index == 0) {
            position = ItemPosition.first;
          } else if (index == todos.length - 1) {
            position = ItemPosition.last;
          } else {
            position = ItemPosition.middle;
          }

          return Dismissible(
            key: Key(todo.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await _showSwipeDeleteConfirmation(context, todo);
            },
            onDismissed: (direction) {
              context.read<TodoCubit>().deleteTodo(todo.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Todo "${todo.title}" deleted'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'UNDO',
                    textColor: Colors.white,
                    onPressed: () {},
                  ),
                ),
              );
            },
            background: _buildSwipeDeleteBackground(),
            child: TodoItemWidget(
              todo: todo,
              position: position,
              onToggle: () => context.read<TodoCubit>().toggleTodoStatus(todo),
              onEdit: () => _showEditTodoModel(context, todo),
              onDelete: () => _showDeleteConfirmation(context, todo),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeDeleteBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_forever, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTodoModel(BuildContext context) async {
    final todoCubit = context.read<TodoCubit>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) =>
          BlocProvider.value(value: todoCubit, child: const AddTodoView()),
    );

    if (result == true) {
      todoCubit.refreshTodos();
    }
  }

  void _showEditTodoModel(BuildContext context, TodoEntity todo) async {
    final todoCubit = context.read<TodoCubit>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: todoCubit,
        child: AddTodoView(todo: todo),
      ),
    );

    if (result == true) {
      todoCubit.refreshTodos();
    }
  }

  Future<bool?> _showSwipeDeleteConfirmation(
    BuildContext context,
    TodoEntity todo,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Todo'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 16),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"${todo.title}"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TodoEntity todo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TodoCubit>().deleteTodo(todo.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
