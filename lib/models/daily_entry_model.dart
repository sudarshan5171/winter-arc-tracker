class DailyEntry {
  final String date; // Format: yyyy-MM-dd
  final String goalId;
  final bool completed;
  final int? value;

  const DailyEntry({
    required this.date,
    required this.goalId,
    required this.completed,
    this.value,
  });

  String get compositeKey => '${date}_$goalId';

  DailyEntry copyWith({
    String? date,
    String? goalId,
    bool? completed,
    int? value,
  }) {
    return DailyEntry(
      date: date ?? this.date,
      goalId: goalId ?? this.goalId,
      completed: completed ?? this.completed,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'goalId': goalId,
      'completed': completed,
      'value': value,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      date: map['date'] as String,
      goalId: map['goalId'] as String,
      completed: map['completed'] as bool? ?? false,
      value: map['value'] as int?,
    );
  }
}
