import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/health_guide_models.dart';
import '../providers/health_guides_provider.dart';

/// 📖 GUIDE DETAIL BOTTOM SHEET WIDGET
///
/// Full-screen bottom sheet displaying complete guide content
/// Shows: title, full article text, metadata, tags
/// Used when: User taps guide card in HealthGuidesScreen
///
/// Layout:
/// ```
/// ╔─────────────────────────────────╗
/// ║ ════ Handle Bar ════             ║  ← Draggable handle
/// ├─────────────────────────────────┤
/// ║ 💡 Guide Title  [BEGINNER]      ║  ← Header section
/// ║    ⏱ 8 min read  #tag           ║     with metadata
/// ├─────────────────────────────────┤
/// ║ Short description of guide...   ║
/// ║                                 ║
/// ║ Full article content goes here  ║  ← Scrollable content
/// ║ with all the details and        ║    (DraggableScrollableSheet)
/// ║ information about the topic.    ║
/// ║ ... (long content) ...          ║
/// │                                 ║
/// ╚─────────────────────────────────╝
/// ```
///
/// Features:
/// - Draggable bottom sheet (user can drag up/down)
/// - Scrollable content area
/// - Fixed header with metadata
/// - Loading/error states
/// - Full-screen readable content (dark text on white)
///
/// Props:
/// - guideId: ID of guide to display (fetched on-demand)
///
/// Example Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => GuideDetailSheet(guideId: 'guide_123'),
/// );
/// ```
class GuideDetailSheet extends ConsumerWidget {
  final String guideId;

  const GuideDetailSheet({
    super.key,
    required this.guideId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// 📡 Fetch Guide Detail Data
    ///
    /// Watches guideDetailProvider with guideId parameter
    /// Provider family: Different cache entry per guideId
    /// AsyncValue handles loading/error/data states
    final guideAsync = ref.watch(guideDetailProvider(guideId));

    /// 🔄 Handle Three States: Loading, Error, Data
    ///
    /// AsyncValue.when() provides pattern matching:
    /// 1. loading: Show spinner in container
    /// 2. error: Show error message + close button
    /// 3. data: Show full guide content
    return guideAsync.when(
      /// ⏳ Loading State: Fetching guide content
      ///
      /// Shown while API request in progress
      /// Spinner with orange color (theme color)
      /// Fixed height container with white background
      loading: () => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF9800)),
        ),
      ),

      /// ❌ Error State: Failed to load guide
      ///
      /// Displayed if API request failed
      /// Shows: error icon, error message, close button
      /// User can close sheet and try again
      error: (error, stack) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading guide',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),

      /// ✅ Success State: Guide loaded successfully
      ///
      /// Show full guide content
      /// Delegate to _buildContent() for layout
      data: (guide) => _buildContent(context, guide),
    );
  }

  /// 🏗️ Build Guide Content Layout
  ///
  /// Uses DraggableScrollableSheet for bottom sheet behavior
  /// User can drag sheet up/down to resize
  /// Scrollable content area in middle
  ///
  /// Structure:
  /// 1. Handle bar (visual indicator for dragging)
  /// 2. Fixed header (title, metadata, close button)
  /// 3. Scrollable content (description + full article)
  ///
  /// Props:
  /// - initialChildSize: Start at 90% of screen
  /// - minChildSize: Can compress to 50%
  /// - maxChildSize: Can expand to 95%
  Widget _buildContent(BuildContext context, HealthGuide guide) {
    return DraggableScrollableSheet(
      /// 📐 Sizing Configuration
      /// start: 90% of screen height
      /// min: 50% when dragged down
      /// max: 95% when dragged up
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,

      /// 🎨 Build Content
      ///
      /// builder receives:
      /// - context: Current build context
      /// - scrollController: Controller for scroll area
      ///   (important: must be passed to SingleChildScrollView)
      builder: (context, scrollController) {
        return Container(
          /// ✨ Container Styling
          /// - White background
          /// - Rounded top corners (20px)
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),

          /// 📐 Content Layout: Column of 3 sections
          ///
          /// 1. Handle bar (visual drag indicator)
          /// 2. Header (title, metadata, close button)
          /// 3. Scrollable content (description + article)
          child: Column(
            children: [
              /// ═══ Handle Bar ═══
              ///
              /// Visual indicator that sheet is draggable
              /// Small gray bar at top center
              /// User recognizes this as drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              /// 📌 Header Section (Fixed, Non-Scrolling)
              ///
              /// Contains: title, difficulty, read time, tags, close button
              /// Stays visible when user scrolls content
              /// Border separator between header and content
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),

                /// Content structure:
                /// Row 1: Icon container (left) + Title+difficulty (middle) + Close button (right)
                /// Row 2: Read time + tags metadata
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🎯 Row 1: Icon + Title + Difficulty + Close
                    Row(
                      children: [
                        /// 💡 Icon Container
                        ///
                        /// Orange background (#FFF3E0)
                        /// Shows lightbulb icon
                        /// Fixed 10px padding
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.lightbulb,
                            size: 24,
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                        const SizedBox(width: 16),

                        /// 📝 Title + Difficulty Column
                        ///
                        /// Expanded to take remaining space
                        /// Title: 20pt bold, 2-line max
                        /// Difficulty: Color-coded badge (optional)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                guide.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              if (guide.difficulty != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _getDifficultyColor(guide.difficulty!),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    guide.difficulty!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        /// ✕ Close Button
                        ///
                        /// Right side of header
                        /// Allows user to dismiss sheet
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    /// 🏷️ Row 2: Read Time + Tags Metadata
                    ///
                    /// Inline metadata display
                    /// Shows: ⏱ read time, followed by tags
                    Row(
                      children: [
                        /// ⏱️ Read Time
                        ///
                        /// Clock icon + formatted time text
                        /// Example: "⏱ 8 min read"
                        Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          guide.readTimeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),

                        /// 🏷️ Tags Display
                        ///
                        /// Show first 2 tags in gray boxes
                        /// Separated from read time by 16px gap
                        /// Optional: hide if no tags
                        if (guide.tags.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Wrap(
                            spacing: 4,
                            children: guide.tags.take(2).map((tag) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                child: Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              /// 📄 Content Section (Scrollable)
              ///
              /// Expanded: Takes remaining vertical space
              /// SingleChildScrollView: Makes content scrollable
              /// Note: MUST pass scrollController from parent
              ///       (required for DraggableScrollableSheet)
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),

                  /// Content structure:
                  /// 1. Description (short preview)
                  /// 2. Full content/article (if available)
                  /// 3. Bottom padding (40px for breathing room)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 📋 Description Section
                      ///
                      /// Short preview text from guide
                      /// Gray text (15pt), 1.6x line height for readability
                      /// Example: "Learn the basics of 16:8 intermittent fasting..."
                      Text(
                        guide.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),

                      /// 📰 Full Content Section
                      ///
                      /// Complete article text from guide
                      /// Only shown if content exists and is not empty
                      /// Larger vertical spacing (24px) separates from description
                      /// Dark gray text (14pt), 1.8x line height for article reading
                      if (guide.content != null &&
                          guide.content!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          guide.content!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.8,
                          ),
                        ),
                      ],

                      /// 🔲 Bottom Padding
                      ///
                      /// 40px of space at bottom
                      /// Ensures last line of content not too close to bottom
                      /// Improves scroll experience (more breathing room)
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
  /// Used in: Difficulty badge in header
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
