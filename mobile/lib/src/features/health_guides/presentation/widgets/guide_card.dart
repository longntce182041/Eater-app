import 'package:flutter/material.dart';
import '../../domain/health_guide_models.dart';

/// 🎴 GUIDE CARD WIDGET
///
/// Displays a health guide preview in card format
/// Shows: title, description, difficulty badge, read time, tags
/// Used in: HealthGuidesScreen guide list
///
/// Layout:
/// ```
/// ╔─────────────────────────────────╗
/// ║ 💡 Title              [BEGINNER] ║  ← Icon + title + difficulty
/// ║                                 ║
/// ║ Short description of the       ║  ← Description (2 lines max)
/// ║ guide content goes here...     ║
/// │                                 ║
/// ║ ⏱ 8 min read       #fasting    ║  ← Read time + first tag
/// ╚─────────────────────────────────╝
/// ```
///
/// Features:
/// - White background with subtle shadow
/// - Rounded corners (12px)
/// - Light gray border
/// - Tappable entire card (GestureDetector)
/// - Responsive text (maxLines, overflow)
/// - Color-coded difficulty (green, orange, pink)
///
/// Props:
/// - guide: HealthGuide to display
/// - onTap: Callback when user taps card
///
/// Example Usage:
/// ```dart
/// GuideCard(
///   guide: HealthGuide(...),
///   onTap: () {
///     showModalBottomSheet(GuideDetailSheet(guide.id));
///   },
/// )
/// ```
class GuideCard extends StatelessWidget {
  final HealthGuide guide;
  final VoidCallback onTap;

  const GuideCard({
    super.key,
    required this.guide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    /// 🎯 Card Container
    ///
    /// Tappable card that opens guide detail sheet
    /// Supports ripple effect on tap
    return GestureDetector(
      onTap: onTap,
      child: Container(
        /// 🎨 Styling:
        /// - White background
        /// - 12px rounded corners
        /// - Light gray border (subtle separation)
        /// - Subtle shadow (0.05 opacity, 4px blur)
        /// - 16px padding for internal content
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),

        /// 📐 Content Layout
        ///
        /// Column structure:
        /// 1. Header: Icon + title + difficulty badge
        /// 2. Description: Short preview text
        /// 3. Footer: Read time + tags
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📌 Header Section: Icon + Title + Difficulty
            ///
            /// Row layout:
            /// - Left: Icon in orange container
            /// - Middle: Title + optional difficulty badge
            /// - Right: Expand remaining space
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 💡 Icon Badge
                ///
                /// Orange circular background (#FFF3E0)
                /// Shows lightbulb icon (standard for all guides)
                /// Fixed size: 8px padding around icon
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.lightbulb,
                    size: 20,
                    color: const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),

                /// 📝 Title + Difficulty Section
                ///
                /// Takes remaining space (Expanded)
                /// Stack: title on top, difficulty badge below
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🎯 Guide Title
                      ///
                      /// Bold, dark text (16pt)
                      /// Max 2 lines (ellipsis if overflow)
                      /// Examples:
                      /// - "Complete Guide to 16:8 Intermittent Fasting"
                      /// - "Home Workouts for Beginners"
                      Text(
                        guide.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      /// 🏅 Difficulty Badge
                      ///
                      /// Optional: Only show if guide has difficulty level
                      /// Color-coded:
                      /// - Beginner: Green (#4CAF50)
                      /// - Intermediate: Orange (#FF9800)
                      /// - Advanced: Pink (#E91E63)
                      /// White uppercase text (12pt)
                      if (guide.difficulty != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(guide.difficulty!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          child: Text(
                            guide.difficulty!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// 📄 Description
            ///
            /// Short preview of guide content
            /// Gray text (13pt), 1.4x line height
            /// Max 2 lines (ellipsis if longer)
            /// Examples:
            /// - "Learn the most popular intermittent fasting..."
            /// - "Complete guide to strength training at home..."
            Text(
              guide.description,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            /// 🏷️ Footer: Read Time + Tags
            ///
            /// Row layout:
            /// - Left: Clock icon + read time ("8 min read")
            /// - Right: First tag in gray box
            ///
            /// Balances metadata and visual interest
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// ⏱️ Read Time Display
                ///
                /// Clock icon (14pt, gray)
                /// Followed by formatted read time text
                /// Example: "⏱ 8 min read"
                /// Uses guide.readTimeText property
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      guide.readTimeText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                /// 🏷️ First Tag Display
                ///
                /// Shows first tag if available
                /// Used for quick categorization (fasting, nutrition, etc.)
                /// Gray background box, max 1 line
                /// Hidden if no tags
                if (guide.tags.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      guide.tags.first,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 🎨 Get Color for Difficulty Badge
  ///
  /// Maps difficulty level to color:
  /// - "beginner" → Green (#4CAF50) - Easy, start here
  /// - "intermediate" → Orange (#FF9800) - Some knowledge needed
  /// - "advanced" → Pink (#E91E63) - Expert level needed
  /// - default → Gray - Unknown/unspecified
  ///
  /// Used in: GuideCard difficulty badge
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return const Color(0xFF4CAF50);
      case 'intermediate':
        return const Color(0xFFFF9800);
      case 'advanced':
        return const Color(0xFFE91E63);
      default:
        return Colors.grey;
    }
  }
}
