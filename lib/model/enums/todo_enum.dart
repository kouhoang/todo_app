enum TodoCategory {
  list,
  calendar,
  trophy;

  String get displayName {
    switch (this) {
      case TodoCategory.list:
        return 'List';
      case TodoCategory.calendar:
        return 'Calendar';
      case TodoCategory.trophy:
        return 'Trophy';
    }
  }

  String get iconName {
    switch (this) {
      case TodoCategory.list:
        return 'list';
      case TodoCategory.calendar:
        return 'calendar';
      case TodoCategory.trophy:
        return 'trophy';
    }
  }
}
