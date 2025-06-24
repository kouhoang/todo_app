import 'package:equatable/equatable.dart';
import 'package:todo_app/model/enums/todo_enum.dart';
import 'package:todo_app/model/enums/todo_status.dart';

class TodoEntity extends Equatable {
  final String id;
  final String title;
  final String? notes;
  final DateTime date;
  final DateTime? time;
  final TodoCategory category;
  final TodoStatus status;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoEntity({
    required this.id,
    required this.title,
    this.notes,
    required this.date,
    this.time,
    required this.category,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoEntity copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? date,
    DateTime? time,
    TodoCategory? category,
    TodoStatus? status,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      time: time ?? this.time,
      category: category ?? this.category,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'date': date.toIso8601String(),
      'time': time?.toIso8601String(),
      'category': category.name,
      'status': status.name,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TodoEntity.fromMap(Map<String, dynamic> map) {
    return TodoEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      notes: map['notes'],
      date: DateTime.parse(map['date']),
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      category: TodoCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TodoCategory.list,
      ),
      status: TodoStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TodoStatus.pending,
      ),
      userId: map['user_id'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    notes,
    date,
    time,
    category,
    status,
    userId,
    createdAt,
    updatedAt,
  ];
}
