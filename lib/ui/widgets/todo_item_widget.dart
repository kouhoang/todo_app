import 'package:flutter/material.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/enums/todo_status.dart';
import 'package:todo_app/model/enums/item_position.dart';
import 'package:todo_app/utils/date_utils.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ItemPosition position;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = todo.status == TodoStatus.completed;
    final isOverdue =
        !isCompleted && AppDateUtils.isOverdue(todo.date, todo.time);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: _getBorderRadius(),
            boxShadow:
                position == ItemPosition.single ||
                    position == ItemPosition.first
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            onTap: onEdit,
            borderRadius: _getBorderRadius(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(
                        todo.category,
                      ).withAlpha(isCompleted ? 13 : 26),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Opacity(
                        opacity: isCompleted ? 0.3 : 1.0,
                        child: Image.asset(
                          _getCategoryIconAsset(todo.category),
                          width: 20,
                          height: 20,
                          color: _getCategoryColor(
                            todo.category,
                          ).withAlpha(isCompleted ? 77 : 255),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? AppColors.textTertiary.withValues(alpha: 0.5)
                                : AppColors.textPrimary,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: isCompleted
                                ? AppColors.textTertiary.withValues(alpha: 0.5)
                                : null,
                            decorationThickness: isCompleted ? 2.0 : null,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Date/Time
                        if (todo.time != null || todo.date != null)
                          Text(
                            AppDateUtils.formatDisplayDateTime(
                              todo.date,
                              todo.time,
                            ),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: isCompleted
                                  ? AppColors.textSecondary.withValues(
                                      alpha: 0.4,
                                    )
                                  : isOverdue
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                              fontWeight: isOverdue && !isCompleted
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: isCompleted
                                  ? AppColors.textSecondary.withValues(
                                      alpha: 0.4,
                                    )
                                  : null,
                              decorationThickness: isCompleted ? 1.5 : null,
                            ),
                          ),

                        // Notes if available
                        if (todo.notes != null && todo.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            todo.notes!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isCompleted
                                  ? AppColors.textSecondary.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: isCompleted
                                  ? AppColors.textSecondary.withValues(
                                      alpha: 0.3,
                                    )
                                  : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        // Overdue badge
                        if (isOverdue && !isCompleted) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
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
                  ),

                  const SizedBox(width: 12),

                  // Checkbox - Click to toggle status
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          isCompleted
                              ? 'assets/false_checked.png'
                              : 'assets/true_checked.png',
                          key: ValueKey(isCompleted),
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Divider among items
        if (position != ItemPosition.single && position != ItemPosition.last)
          Container(
            height: 1,
            color: Colors.grey.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
      ],
    );
  }

  BorderRadius _getBorderRadius() {
    switch (position) {
      case ItemPosition.single:
        return BorderRadius.circular(16);
      case ItemPosition.first:
        return const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        );
      case ItemPosition.middle:
        return BorderRadius.zero;
      case ItemPosition.last:
        return const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        );
    }
  }

  Color _getCategoryColor(TodoCategory category) {
    switch (category) {
      case TodoCategory.list:
        return AppColors.listCategory;
      case TodoCategory.calendar:
        return AppColors.calendarCategory;
      case TodoCategory.trophy:
        return AppColors.trophyCategory;
    }
  }

  String _getCategoryIconAsset(TodoCategory category) {
    switch (category) {
      case TodoCategory.list:
        return 'assets/file-list-line.png';
      case TodoCategory.calendar:
        return 'assets/calendar-event-fill.png';
      case TodoCategory.trophy:
        return 'assets/trophy-line.png';
    }
  }
}
