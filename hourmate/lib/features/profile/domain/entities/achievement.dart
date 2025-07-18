import 'package:flutter/material.dart';

class Achievement {
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final double progress;

  const Achievement({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.unlocked,
    required this.progress,
  });

  Achievement copyWith({bool? unlocked, double? progress}) {
    return Achievement(
      key: key,
      title: title,
      description: description,
      icon: icon,
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
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'unlocked': unlocked,
      'progress': progress,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      key: map['key'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      icon: IconData(
        map['icon'] as int,
        fontFamily: map['iconFontFamily'] as String?,
      ),
      color: Color(map['color'] as int),
      unlocked: map['unlocked'] as bool,
      progress: (map['progress'] as num).toDouble(),
    );
  }
}
