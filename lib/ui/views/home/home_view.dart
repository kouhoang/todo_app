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
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
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
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _getTotalItemCount(pendingTodos, completedTodos),
              itemBuilder: (context, index) {
                return _buildListItem(
                  context,
                  index,
                  pendingTodos,
                  completedTodos,
                );
              },
            ),
          );
        }

        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  int _getTotalItemCount(
    List<TodoEntity> pendingTodos,
    List<TodoEntity> completedTodos,
  ) {
    int count = 0;

    if (pendingTodos.isNotEmpty) {
      count += 1; // Header
      count += pendingTodos.length; // Todos
    }

    if (completedTodos.isNotEmpty) {
      count += 1; // Spacing
      count += 1; // Header
      count += completedTodos.length; // Todos
    }

    count += 1; // Bottom spacing
    return count;
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    List<TodoEntity> pendingTodos,
    List<TodoEntity> completedTodos,
  ) {
    int currentIndex = 0;

    // Pending todos section
    if (pendingTodos.isNotEmpty) {
      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSectionHeader('Today\'s Tasks', pendingTodos.length),
        );
      }
      currentIndex++;

      if (index < currentIndex + pendingTodos.length) {
        final todoIndex = index - currentIndex;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // Spacing between items
          child: TodoItemWidget(
            todo: pendingTodos[todoIndex],
            onToggle: () => context.read<TodoCubit>().toggleTodoStatus(
              pendingTodos[todoIndex],
            ),
            onEdit: () => _showEditTodoModel(context, pendingTodos[todoIndex]),
            onDelete: () =>
                _showDeleteConfirmation(context, pendingTodos[todoIndex]),
          ),
        );
      }
      currentIndex += pendingTodos.length;
    }

    // Completed todos section
    if (completedTodos.isNotEmpty) {
      if (pendingTodos.isNotEmpty && index == currentIndex) {
        return const SizedBox(height: 32); // Spacing between sections
      }
      if (pendingTodos.isNotEmpty) currentIndex++;

      if (index == currentIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildSectionHeader('Completed', completedTodos.length),
        );
      }
      currentIndex++;

      if (index < currentIndex + completedTodos.length) {
        final todoIndex = index - currentIndex;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12), // Spacing between items
          child: TodoItemWidget(
            todo: completedTodos[todoIndex],
            onToggle: () => context.read<TodoCubit>().toggleTodoStatus(
              completedTodos[todoIndex],
            ),
            onEdit: () =>
                _showEditTodoModel(context, completedTodos[todoIndex]),
            onDelete: () =>
                _showDeleteConfirmation(context, completedTodos[todoIndex]),
          ),
        );
      }
    }

    // Bottom spacing for FAB
    return const SizedBox(height: 80);
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

  void _showAddTodoModel(BuildContext context) async {
    final todoCubit = context.read<TodoCubit>(); // Save reference before async

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) =>
          BlocProvider.value(value: todoCubit, child: const AddTodoView()),
    );

    // Refresh if having changed
    if (result == true) {
      todoCubit.refreshTodos();
    }
  }

  void _showEditTodoModel(BuildContext context, TodoEntity todo) async {
    final todoCubit = context.read<TodoCubit>(); // Save reference before async

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: todoCubit,
        child: AddTodoView(todo: todo),
      ),
    );

    // Refresh if having changed
    if (result == true) {
      todoCubit.refreshTodos();
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
