import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/providers/dio_provider.dart';
import '../../data/recipe_detail_service.dart';

/// Provider for RecipeDetailService
final recipeDetailServiceProvider = Provider<RecipeDetailService>((ref) {
  final dio = ref.watch(dioProvider);
  return RecipeDetailService(dio: dio);
});

/// Provider for fetching full recipe details
/// Usage: ref.watch(recipeDetailProvider(recipeId))
final recipeDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, recipeId) async {
  final service = ref.watch(recipeDetailServiceProvider);
  return service.getRecipeFullDetails(recipeId);
});

/// Provider for recipe nutrition
final recipeNutritionProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, recipeId) async {
  final service = ref.watch(recipeDetailServiceProvider);
  return service.getRecipeNutrition(recipeId);
});
