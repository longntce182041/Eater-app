import 'package:flutter/material.dart';

/// 📚 HEALTH & LIFESTYLE GUIDES DATA MODELS
///
/// This file contains all domain models for the health guides feature:
/// - HealthGuideCategory: Grouped guides by category
/// - HealthGuide: Individual guide with metadata and content
///
/// Data Flow:
/// 1. Backend returns guides grouped by category (fasting, workouts, nutrition, etc.)
/// 2. UI displays categories in tabs
/// 3. User selects category → see guides in that category
/// 4. User taps guide → fetch full content
/// 5. Display in bottom sheet modal
///
/// All models implement:
/// - fromJson() → Parse API response to Dart object
/// - toJson() → Serialize to JSON for requests
/// - Null-safety with sensible defaults

/// 📁 Health Guide Category Container
///
/// Groups guides by category for easier organization and browsing:
/// - category: Identifier ("fasting", "nutrition", "workouts", etc.)
/// - guides: List of guides in this category
///
/// Used by:
/// - allHealthGuidesProvider: Fetch all guides grouped by category
/// - CategoryTabBar: Display as tabs
/// - HealthGuidesScreen: Show list of guides per selected category
///
/// Example:
/// ```
/// category: "fasting"
/// guides: [
///   HealthGuide(title: "16:8 Intermittent Fasting", ...),
///   HealthGuide(title: "Fasting for Beginners", ...),
/// ]
/// ```
class HealthGuideCategory {
  final String category;
  final List<HealthGuide> guides;

  HealthGuideCategory({
    required this.category,
    required this.guides,
  });

  /// 📥 Parse category data from backend JSON
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "category": "fasting",
  ///   "guides": [
  ///     {
  ///       "id": "guide_123",
  ///       "title": "16:8 Intermittent Fasting",
  ///       "description": "Learn about popular intermittent fasting protocol",
  ///       "category": "fasting",
  ///       ...
  ///     }
  ///   ]
  /// }
  /// ```
  factory HealthGuideCategory.fromJson(Map<String, dynamic> json) {
    return HealthGuideCategory(
      category: json['category'] as String,
      guides: (json['guides'] as List<dynamic>?)
              ?.map((e) => HealthGuide.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 📤 Serialize to JSON for API requests
  Map<String, dynamic> toJson() => {
        'category': category,
        'guides': guides.map((e) => e.toJson()).toList(),
      };
}

/// 📖 Individual Health & Lifestyle Guide
///
/// Represents a single educational guide with:
/// - id: Unique guide identifier
/// - category: Guide category (fasting, nutrition, workouts, etc.)
/// - title: Display title ("16:8 Intermittent Fasting")
/// - description: Short preview text (shown in card)
/// - content: Full guide text/markdown (fetched separately)
/// - icon: Icon name for UI display
/// - estimatedReadTime: How long to read (in minutes)
/// - tags: Keywords for search/filtering
/// - difficulty: Skill level (beginner, intermediate, advanced)
///
/// Display Flow:
/// 1. List view shows: title, description, read time, difficulty badge
/// 2. User taps card
/// 3. Bottom sheet opens with: title, full content, tags, difficulty
///
/// Example:
/// ```
/// id: "guide_fasting_101"
/// category: "fasting"
/// title: "Complete Guide to 16:8 Intermittent Fasting"
/// description: "Learn the most popular intermittent fasting method..."
/// content: "Intermittent fasting is an eating pattern that cycles..."
/// estimatedReadTime: 8
/// tags: ["fasting", "beginner", "nutrition"]
/// difficulty: "beginner"
/// ```
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

  /// 📥 Parse guide data from backend JSON
  ///
  /// Handles:
  /// - Flexible ID field (id or _id from MongoDB)
  /// - Safe type casting
  /// - Default values
  /// - Nullable fields (content, difficulty, readTime)
  ///
  /// Example JSON:
  /// ```json
  /// {
  ///   "_id": "64abc123",
  ///   "id": "guide_123",
  ///   "category": "fasting",
  ///   "title": "16:8 Intermittent Fasting",
  ///   "description": "Learn the basics of 16:8 fasting",
  ///   "content": "Intermittent fasting is...",
  ///   "icon": "schedule",
  ///   "estimatedReadTime": 8,
  ///   "tags": ["fasting", "beginner"],
  ///   "difficulty": "beginner"
  /// }
  /// ```
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

  /// 📤 Serialize to JSON for API requests
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

  /// 📋 Create modified copy of this guide
  ///
  /// Used to update guide state (e.g., mark as read, add rating)
  ///
  /// Example:
  /// ```dart
  /// final updatedGuide = guide.copyWith(
  ///   content: fullContentText,
  /// );
  /// ```
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

  /// ⏱️ Format read time for display
  ///
  /// Examples:
  /// - null → ""
  /// - 1 → "1 min read"
  /// - 8 → "8 min read"
  /// - 15 → "15 min read"
  String get readTimeText {
    if (estimatedReadTime == null) return '';
    if (estimatedReadTime == 1) return '1 min read';
    return '$estimatedReadTime min read';
  }

  /// 🎯 Get category display name
  ///
  /// Converts category identifier to user-friendly text:
  /// - "fasting" → "Fasting Guides"
  /// - "workouts" → "Workouts"
  /// - "nutrition" → "Nutrition"
  /// - "meal_prep" → "Meal Prep"
  /// - "emotional_eating" → "Emotional Eating"
  /// - "hydration" → "Hydration"
  /// - "stress_management" → "Stress Management"
  ///
  /// Used in:
  /// - Category tabs
  /// - Guide cards
  /// - Headers
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

  /// 🎨 Get category icon for UI display
  ///
  /// Returns Material Icons based on category:
  /// - "fasting" → Icons.schedule (clock)
  /// - "workouts" → Icons.fitness_center (dumbbell)
  /// - "nutrition" → Icons.restaurant (plate)
  /// - "meal_prep" → Icons.restaurant
  /// - "emotional_eating" → Icons.sentiment_satisfied (smiley face)
  /// - "hydration" → Icons.local_drink (glass)
  /// - "stress_management" → Icons.spa (leaf)
  ///
  /// Used in:
  /// - Category tabs
  /// - Guide cards
  /// - Headers
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
