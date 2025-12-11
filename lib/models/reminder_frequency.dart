enum ReminderFrequency {
  off,
  everyDay,
}

extension ReminderFrequencyStorage on ReminderFrequency {
  String get storageKey {
    switch (this) {
      case ReminderFrequency.off:
        return 'off';
      case ReminderFrequency.everyDay:
        return 'every_day';
    }
  }

  static ReminderFrequency fromStorageKey(String? key) {
    switch (key) {
      case 'every_day':
        return ReminderFrequency.everyDay;
      case 'off':
      default:
        return ReminderFrequency.off;
    }
  }
}
