import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/meal_plan.dart';
import '../repositories/meal_plan_repository.dart';

/// Use case for getting daily meal plan.
class GetDailyMealPlanUseCase implements UseCase<MealPlan, DateTime> {
  final MealPlanRepository repository;

  GetDailyMealPlanUseCase(this.repository);

  @override
  Future<Either<Failure, MealPlan>> call(DateTime params) {
    return repository.getDailyMealPlan(params);
  }
}
