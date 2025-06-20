import 'package:flutter/material.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/enums/todo_status.dart';
import 'package:todo_app/utils/date_utils.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.status == TodoStatus.completed;
    final isOverdue = !isCompleted && AppDateUtils.isOverdue(todo.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getCategoryColor(todo.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(todo.category),
                  color: _getCategoryColor(todo.category),
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        Text(
                          todo.time != null
                              ? AppDateUtils.formatDateTime(todo.time!)
                              : AppDateUtils.formatDate(todo.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: isOverdue ? FontWeight.w500 : null,
                          ),
                        ),

                        if (isOverdue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Overdue',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Complete/Uncomplete Button
                  InkWell(
                    onTap: onToggle,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? AppColors.success : Colors.grey,
                          width: 2,
                        ),
                        color: isCompleted
                            ? AppColors.success
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Delete Button
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TodoCategory category) {
    switch (category) {
      case TodoCategory.work:
        return AppColors.workCategory;
      case TodoCategory.personal:
        return AppColors.personalCategory;
      case TodoCategory.important:
        return AppColors.importantCategory;
    }
  }

  IconData _getCategoryIcon(TodoCategory category) {
    switch (category) {
      case TodoCategory.work:
        return Icons.work_outline;
      case TodoCategory.personal:
        return Icons.person_outline;
      case TodoCategory.important:
        return Icons.star_outline;
    }
  }
}
