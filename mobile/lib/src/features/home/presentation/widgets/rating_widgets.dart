import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/recipe_models.dart';
import '../providers/review_provider.dart';

// Star rating widget
class StarRating extends StatelessWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final bool isEditable;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.isEditable = false,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          GestureDetector(
            onTap: isEditable ? () => onRatingChanged(i) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                i <= rating ? Icons.star : Icons.star_border,
                color: i <= rating
                    ? const Color(0xFFFFB800)
                    : const Color(0xFFB4B4B4),
                size: size,
              ),
            ),
          ),
      ],
    );
  }
}

// Rating dialog to add/edit review
class RatingDialog extends ConsumerStatefulWidget {
  final String recipeId;
  final RecipeReview? existingReview;

  const RatingDialog({super.key, required this.recipeId, this.existingReview});

  @override
  ConsumerState<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends ConsumerState<RatingDialog> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(recipeReviewsProvider(widget.recipeId).notifier)
          .addReview(_rating, _commentController.text);

      ref.invalidate(userRecipeReviewProvider(widget.recipeId));
      await ref
          .read(userReviewsProvider.notifier)
          .loadUserReviews(refresh: true);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFBF5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rate this Recipe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 24),

            // Star rating
            Center(
              child: StarRating(
                rating: _rating,
                onRatingChanged: (newRating) {
                  setState(() => _rating = newRating);
                },
                isEditable: true,
                size: 40,
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _rating == 0 ? 'Select rating' : _getRatingLabel(_rating),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),

            // Comment field
            TextField(
              controller: _commentController,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(color: Colors.black),
              cursorColor: Colors.black,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this recipe (optional)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFE2B8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFE2B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF9800),
                    width: 1.3,
                  ),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9800),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Submit'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Excellent! 🤩';
      case 4:
        return 'Very Good 😊';
      case 3:
        return 'Good 👍';
      case 2:
        return 'Fair 😐';
      case 1:
        return 'Poor 😞';
      default:
        return '';
    }
  }
}

// Reviews list widget
class RecipeReviewsList extends ConsumerWidget {
  final String recipeId;

  const RecipeReviewsList({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(recipeReviewsProvider(recipeId));

    if (reviewsState.isLoading && reviewsState.reviews.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF9800)),
      );
    }

    if (reviewsState.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rate_review, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'No reviews yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: reviewsState.reviews.length + (reviewsState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == reviewsState.reviews.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9800)),
            ),
          );
        }

        final review = reviewsState.reviews[index];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE2B8), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.author.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(review.createdAt),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StarRating(
                        rating: review.rating,
                        onRatingChanged: (_) {},
                        isEditable: false,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Comment
                  if (review.comment.isNotEmpty)
                    Text(
                      review.comment,
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF4A4A4A),
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Rating stats widget
class RatingStatsWidget extends StatelessWidget {
  final RatingStats stats;

  const RatingStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE2B8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average rating
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${stats.avgRating}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StarRating(
                        rating: stats.avgRating.toInt(),
                        onRatingChanged: (_) {},
                        isEditable: false,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${stats.totalReviews} reviews',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Text('$i', style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value:
                                      (stats.ratingDistribution[i] ?? 0) / 100,
                                  minHeight: 4,
                                  backgroundColor: Colors.grey[200],
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFFF9800),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 30,
                              child: Text(
                                '${(stats.ratingDistribution[i] ?? 0).toInt()}%',
                                style: const TextStyle(fontSize: 11),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
