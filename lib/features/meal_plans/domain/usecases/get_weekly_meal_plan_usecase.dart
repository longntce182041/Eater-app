import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

/// Use case for getting weekly meal plan.
class GetWeeklyMealPlanUseCase implements UseCase<List<MealPlan>, DateTime> {
  final MealPlanRepository repository;

  GetWeeklyMealPlanUseCase(this.repository);

  @override
  Future<Either<Failure, List<MealPlan>>> call(DateTime params) {
    return repository.getWeeklyMealPlan(params);
  }
}
