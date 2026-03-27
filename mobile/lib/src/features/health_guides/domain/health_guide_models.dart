import 'package:flutter/material.dart';

/// Health guide category with list of guides
class HealthGuideCategory {
  final String category;
  final List<HealthGuide> guides;

  HealthGuideCategory({
    required this.category,
    required this.guides,
  });

  factory HealthGuideCategory.fromJson(Map<String, dynamic> json) {
    return HealthGuideCategory(
      category: json['category'] as String,
      guides: (json['guides'] as List<dynamic>?)
              ?.map((e) => HealthGuide.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'guides': guides.map((e) => e.toJson()).toList(),
      };
}

/// Single health guide
class HealthGuide {
  final String id;
  final String category;
  final String title;
  final String description;
  final String? content;
  final String icon;
  final int? estimatedReadTime;
  final List<String> tags;
  final String? difficulty;

  HealthGuide({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.content,
    required this.icon,
    this.estimatedReadTime,
    required this.tags,
    this.difficulty,
  });

  factory HealthGuide.fromJson(Map<String, dynamic> json) {
    return HealthGuide(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      category: json['category'] as String? ?? 'general',
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String?,
      icon: json['icon'] as String? ?? 'auto',
      estimatedReadTime: json['estimatedReadTime'] as int?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      difficulty: json['difficulty'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'description': description,
        'content': content,
        'icon': icon,
        'estimatedReadTime': estimatedReadTime,
        'tags': tags,
        'difficulty': difficulty,
      };

  HealthGuide copyWith({
    String? id,
    String? category,
    String? title,
    String? description,
    String? content,
    String? icon,
    int? estimatedReadTime,
    List<String>? tags,
    String? difficulty,
  }) {
    return HealthGuide(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      estimatedReadTime: estimatedReadTime ?? this.estimatedReadTime,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  String get readTimeText {
    if (estimatedReadTime == null) return '';
    if (estimatedReadTime == 1) return '1 min read';
    return '$estimatedReadTime min read';
  }

  String get categoryDisplayName {
    switch (category) {
      case 'fasting':
        return 'Fasting Guides';
      case 'workouts':
        return 'Workouts';
      case 'nutrition':
        return 'Nutrition';
      case 'meal_prep':
        return 'Meal Prep';
      case 'emotional_eating':
        return 'Emotional Eating';
      case 'hydration':
        return 'Hydration';
      case 'stress_management':
        return 'Stress Management';
      default:
        return 'Health Guides';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'fasting':
        return Icons.schedule;
      case 'workouts':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'meal_prep':
        return Icons.restaurant;
      case 'emotional_eating':
        return Icons.sentiment_satisfied;
      case 'hydration':
        return Icons.local_drink;
      case 'stress_management':
        return Icons.spa;
      default:
        return Icons.lightbulb;
    }
  }
}
