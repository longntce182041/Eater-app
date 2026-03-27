import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../../data/view_recipe_detail_service.dart';

/// Provider for ViewRecipeDetailService (meal plan recipe viewing)
final viewRecipeDetailServiceProvider = Provider<ViewRecipeDetailService>((ref) {
  final dio = ref.watch(dioProvider);
  return ViewRecipeDetailService(dio: dio);
});

/// Provider for fetching full recipe details (meal plan view)
/// Usage: ref.watch(viewRecipeDetailProvider(recipeId))
final viewRecipeDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, recipeId) async {
  final service = ref.watch(viewRecipeDetailServiceProvider);
  return service.getFullRecipeDetails(recipeId);
});

/// Provider for recipe basic info only
final viewRecipeBasicInfoProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, recipeId) async {
  final service = ref.watch(viewRecipeDetailServiceProvider);
  return service.getRecipeBasicInfo(recipeId);
});
