import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/enums/todo_status.dart';

class CreateTodoParams {
  final String title;
  final String? notes;
  final DateTime date;
  final DateTime? time;
  final TodoCategory category;
  final String userId;

  const CreateTodoParams({
    required this.title,
    this.notes,
    required this.date,
    this.time,
    required this.category,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'notes': notes,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'category': category.name,
      'status': TodoStatus.pending.name,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
