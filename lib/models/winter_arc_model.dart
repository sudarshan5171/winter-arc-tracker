class WinterArc {
  final DateTime startDate;
  final DateTime endDate;
  final bool isOnboarded;

  const WinterArc({
    required this.startDate,
    required this.endDate,
    this.isOnboarded = true,
  });

  int get totalDays {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }

  int get currentDayNumber {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final diff = today.difference(start).inDays + 1;
    if (diff < 1) return 1;
    if (diff > totalDays) return totalDays;
    return diff;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final diff = end.difference(today).inDays;
    return diff < 0 ? 0 : diff;
  }

  bool get isCompleted {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return today.isAfter(end);
  }

  WinterArc copyWith({
    DateTime? startDate,
    DateTime? endDate,
    bool? isOnboarded,
  }) {
    return WinterArc(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isOnboarded': isOnboarded,
    };
  }

  factory WinterArc.fromMap(Map<String, dynamic> map) {
    return WinterArc(
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      isOnboarded: map['isOnboarded'] as bool? ?? true,
    );
  }

  factory WinterArc.defaultArc() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 90));
    return WinterArc(startDate: start, endDate: end, isOnboarded: false);
  }
}
