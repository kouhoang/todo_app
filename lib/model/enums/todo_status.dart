enum TodoStatus {
  pending,
  completed;

  String get displayName {
    switch (this) {
      case TodoStatus.pending:
        return 'Pending';
      case TodoStatus.completed:
        return 'Completed';
    }
  }
}
