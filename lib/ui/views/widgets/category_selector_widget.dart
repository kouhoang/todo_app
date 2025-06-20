import 'package:flutter/material.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/model/enums/todo_enum.dart';

class CategorySelectorWidget extends StatelessWidget {
  final TodoCategory selectedCategory;
  final Function(TodoCategory) onCategorySelected;

  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TodoCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        final color = _getCategoryColor(category);

        return Expanded(
          child: GestureDetector(
            onTap: () => onCategorySelected(category),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: isSelected ? Colors.white : color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : color,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
        return Icons.work;
      case TodoCategory.personal:
        return Icons.person;
      case TodoCategory.important:
        return Icons.star;
    }
  }
}
