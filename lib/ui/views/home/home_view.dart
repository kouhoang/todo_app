import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/global/auth/auth_cubit.dart';
import 'package:todo_app/ui/views/todo/todo_cubit.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/ui/views/widgets/todo_item_widget.dart';
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
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _buildTodoList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoModal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppDateUtils.formatDate(DateTime.now()),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'My Todo List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
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
                // Pending Todos Section
                if (pendingTodos.isNotEmpty) ...[
                  _buildSectionHeader('Today\'s Tasks', pendingTodos.length),
                  const SizedBox(height: 16),
                  ...pendingTodos.map(
                    (todo) => TodoItemWidget(
                      todo: todo,
                      onToggle: () =>
                          context.read<TodoCubit>().toggleTodoStatus(todo),
                      onEdit: () => _showEditTodoModal(context, todo),
                      onDelete: () => _showDeleteConfirmation(context, todo),
                    ),
                  ),
                ],

                // Completed Section
                if (completedTodos.isNotEmpty) ...[
                  if (pendingTodos.isNotEmpty) const SizedBox(height: 32),
                  _buildSectionHeader('Completed', completedTodos.length),
                  const SizedBox(height: 16),
                  ...completedTodos.map(
                    (todo) => TodoItemWidget(
                      todo: todo,
                      onToggle: () =>
                          context.read<TodoCubit>().toggleTodoStatus(todo),
                      onEdit: () => _showEditTodoModal(context, todo),
                      onDelete: () => _showDeleteConfirmation(context, todo),
                    ),
                  ),
                ],

                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        }

        return const Center(child: Text('Something went wrong'));
      },
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
            color: Colors.blue.withOpacity(0.1),
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

  void _showAddTodoModal(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<TodoCubit>(),
        child: const AddTodoView(),
      ),
    );

    // Refresh nếu có thay đổi
    if (result == true) {
      context.read<TodoCubit>().refreshTodos();
    }
  }

  void _showEditTodoModal(BuildContext context, TodoEntity todo) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<TodoCubit>(),
        child: AddTodoView(todo: todo),
      ),
    );

    // Refresh nếu có thay đổi
    if (result == true) {
      context.read<TodoCubit>().refreshTodos();
    }
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
