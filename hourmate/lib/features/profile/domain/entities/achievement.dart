import 'package:flutter/material.dart';

class Achievement {
  final String key;
  final String title;
  final String description;
  final String iconKey;
  final Color color;
  final bool unlocked;
  final double progress;

  const Achievement({
    required this.key,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.color,
    required this.unlocked,
    required this.progress,
  });

  Achievement copyWith({bool? unlocked, double? progress}) {
    return Achievement(
      key: key,
      title: title,
      description: description,
      iconKey: iconKey,
      color: color,
      unlocked: unlocked ?? this.unlocked,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'title': title,
      'description': description,
      'iconKey': iconKey,
      'color': color.value,
      'unlocked': unlocked,
      'progress': progress,
    };
  }

  static const Map<String, IconData> iconMap = {
    'star': Icons.star,
    'trophy': Icons.emoji_events,
    'medal': Icons.military_tech,
    'check': Icons.check_circle,
    'fire': Icons.local_fire_department,
    // Add more mappings as needed
  };

  IconData get icon => iconMap[iconKey] ?? Icons.star;

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      key: map['key'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconKey: map['iconKey'] as String? ?? 'star',
      color: Color(map['color'] as int),
      unlocked: map['unlocked'] as bool,
      progress: (map['progress'] as num).toDouble(),
    );
  }
}
