enum TodoCategory {
  work,
  personal,
  important;

  String get displayName {
    switch (this) {
      case TodoCategory.work:
        return 'Work';
      case TodoCategory.personal:
        return 'Personal';
      case TodoCategory.important:
        return 'Important';
    }
  }

  String get iconName {
    switch (this) {
      case TodoCategory.work:
        return 'work';
      case TodoCategory.personal:
        return 'personal';
      case TodoCategory.important:
        return 'star';
    }
  }
}
