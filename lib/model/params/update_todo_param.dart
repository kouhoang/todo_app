import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/enums/todo_status.dart';

class UpdateTodoParams {
  final String? title;
  final String? notes;
  final DateTime? date;
  final DateTime? time;
  final TodoCategory? category;
  final TodoStatus? status;

  const UpdateTodoParams({
    this.title,
    this.notes,
    this.date,
    this.time,
    this.category,
    this.status,
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) map['title'] = title;
    if (notes != null) map['notes'] = notes;
    if (date != null) map['date'] = date!.toIso8601String();
    if (time != null) map['time'] = time!.toIso8601String();
    if (category != null) map['category'] = category!.name;
    if (status != null) map['status'] = status!.name;

    return map;
  }
}
