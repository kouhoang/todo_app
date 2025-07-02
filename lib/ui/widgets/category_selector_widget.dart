import 'package:flutter/material.dart';
import 'package:todo_app/common/app_colors.dart';
import 'package:todo_app/common/app_icons.dart';
import 'package:todo_app/model/enums/todo_enum.dart';

class CategorySelectorWidget extends StatelessWidget {
  final TodoCategory selectedCategory;
  final Function(TodoCategory)? onCategorySelected;
  final bool isEnabled;

  const CategorySelectorWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Label Category
          Text(
            'Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isEnabled ? AppColors.textPrimary : Colors.grey[400],
              fontFamily: 'Inter',
            ),
          ),

          const SizedBox(width: 16),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: TodoCategory.values.map((category) {
              final isSelected = category == selectedCategory;
              final color = _getCategoryColor(category);

              return GestureDetector(
                onTap: (isEnabled && onCategorySelected != null)
                    ? () => onCategorySelected!(category)
                    : null,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isEnabled ? color : color.withValues(alpha: 0.3))
                        : (isEnabled
                              ? color.withValues(alpha: 0.1)
                              : color.withValues(alpha: 0.05)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: isEnabled ? 1.0 : 0.5,
                      child: Image.asset(
                        _getCategoryIconAsset(category),
                        width: 20,
                        height: 20,
                        color: isSelected
                            ? (isEnabled
                                  ? Colors.black
                                  : Colors.black.withValues(alpha: 0.5))
                            : (isEnabled
                                  ? color
                                  : color.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
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
        return AppIcons.iconFileList;
      case TodoCategory.calendar:
        return AppIcons.iconCalendarEvent;
      case TodoCategory.trophy:
        return AppIcons.iconTrophy;
    }
  }
}
