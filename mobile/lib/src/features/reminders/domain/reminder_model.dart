const Map<String, String> mealTypeLabels = {
  'breakfast': 'Breakfast',
  'lunch': 'Lunch',
  'dinner': 'Dinner',
  'snack': 'Snack',
};

const Map<String, String> mealTypeIcons = {
  'breakfast': '🌅',
  'lunch': '☀️',
  'dinner': '🌙',
  'snack': '🍎',
};

const Map<String, String> defaultTimes = {
  'breakfast': '07:00',
  'lunch': '12:00',
  'dinner': '18:30',
  'snack': '15:00',
};

class ReminderModel {
  final String mealType;

  /// Time in "HH:mm" 24-hour format, e.g. "07:30"
  final String time;

  /// Days of week: 0=Sunday, 1=Monday, ..., 6=Saturday
  final List<int> days;

  final bool enabled;
  final String? label;

  const ReminderModel({
    required this.mealType,
    required this.time,
    this.days = const [1, 2, 3, 4, 5, 6, 0],
    this.enabled = true,
    this.label,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      mealType: json['mealType'] as String,
      time: json['time'] as String,
      days: (json['days'] as List<dynamic>?)
              ?.map((d) => (d as num).toInt())
              .toList() ??
          [1, 2, 3, 4, 5, 6, 0],
      enabled: json['enabled'] as bool? ?? true,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mealType': mealType,
        'time': time,
        'days': days,
        'enabled': enabled,
        if (label != null) 'label': label,
      };

  ReminderModel copyWith({
    String? time,
    List<int>? days,
    bool? enabled,
    String? label,
  }) {
    return ReminderModel(
      mealType: mealType,
      time: time ?? this.time,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
      label: label ?? this.label,
    );
  }

  String get displayLabel => label ?? mealTypeLabels[mealType] ?? mealType;
  String get icon => mealTypeIcons[mealType] ?? '🍽️';

  @override
  String toString() =>
      'ReminderModel($mealType, $time, enabled=$enabled, days=$days)';
}

/// Default reminders shown when the user has not configured any.
const List<ReminderModel> defaultReminders = [
  ReminderModel(
      mealType: 'breakfast',
      time: '07:00',
      days: [1, 2, 3, 4, 5, 6, 0],
      enabled: true),
  ReminderModel(
      mealType: 'lunch',
      time: '12:00',
      days: [1, 2, 3, 4, 5, 6, 0],
      enabled: true),
  ReminderModel(
      mealType: 'dinner',
      time: '18:30',
      days: [1, 2, 3, 4, 5, 6, 0],
      enabled: true),
  ReminderModel(
      mealType: 'snack', time: '15:00', days: [1, 2, 3, 4, 5], enabled: false),
];
