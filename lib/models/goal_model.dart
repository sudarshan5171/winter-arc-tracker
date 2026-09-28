class Goal {
  final String id;
  final String title;
  final String icon; // Emoji string
  final bool isPreset;
  final int? targetValue;
  final String? unit;
  final DateTime createdAt;
  final int order;

  const Goal({
    required this.id,
    required this.title,
    required this.icon,
    this.isPreset = false,
    this.targetValue,
    this.unit,
    required this.createdAt,
    this.order = 0,
  });

  bool get isNumeric => targetValue != null && targetValue! > 0;

  Goal copyWith({
    String? id,
    String? title,
    String? icon,
    bool? isPreset,
    int? targetValue,
    String? unit,
    DateTime? createdAt,
    int? order,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isPreset: isPreset ?? this.isPreset,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'isPreset': isPreset,
      'targetValue': targetValue,
      'unit': unit,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      title: map['title'] as String,
      icon: map['icon'] as String? ?? '🎯',
      isPreset: map['isPreset'] as bool? ?? false,
      targetValue: map['targetValue'] as int?,
      unit: map['unit'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      order: map['order'] as int? ?? 0,
    );
  }
}
