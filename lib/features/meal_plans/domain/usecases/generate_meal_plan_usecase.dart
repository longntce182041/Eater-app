import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

/// Use case for generating AI meal plan.
class GenerateMealPlanUseCase
    implements UseCase<MealPlan, GenerateMealPlanParams> {
  final MealPlanRepository repository;

  GenerateMealPlanUseCase(this.repository);

  @override
  Future<Either<Failure, MealPlan>> call(GenerateMealPlanParams params) {
    return repository.generateMealPlan(
      date: params.date,
      planType: params.planType,
      targetCalories: params.targetCalories,
    );
  }
}

/// Parameters for generating meal plan.
class GenerateMealPlanParams {
  final DateTime date;
  final String planType;
  final int? targetCalories;

  const GenerateMealPlanParams({
    required this.date,
    required this.planType,
    this.targetCalories,
  });
}
