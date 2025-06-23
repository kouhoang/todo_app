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
                ),
              ],
            ),
          );
        }

        if (state is TodoLoaded) {
          final pendingTodos = state.pendingTodos;
          final completedTodos = state.completedTodos;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Pending Todos
              ...pendingTodos.map(
                (todo) => TodoItemWidget(
                  todo: todo,
                  onToggle: () =>
                      context.read<TodoCubit>().toggleTodoStatus(todo),
                  onEdit: () => _showEditTodoModal(context, todo),
                  onDelete: () => context.read<TodoCubit>().deleteTodo(todo.id),
                ),
              ),

              // Completed Section
              if (completedTodos.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ...completedTodos.map(
                  (todo) => TodoItemWidget(
                    todo: todo,
                    onToggle: () =>
                        context.read<TodoCubit>().toggleTodoStatus(todo),
                    onEdit: () => _showEditTodoModal(context, todo),
                    onDelete: () =>
                        context.read<TodoCubit>().deleteTodo(todo.id),
                  ),
                ),
              ],

              const SizedBox(height: 80), // Space for FAB
            ],
          );
        }

        return const Center(child: Text('No todos found'));
      },
    );
  }

  void _showAddTodoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<TodoCubit>(),
        child: const AddTodoView(),
      ),
    );
  }

  void _showEditTodoModal(BuildContext context, TodoEntity todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<TodoCubit>(),
        child: AddTodoView(todo: todo),
      ),
    );
  }
}
