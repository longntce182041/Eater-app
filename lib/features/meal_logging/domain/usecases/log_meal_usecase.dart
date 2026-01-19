import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/meal_log.dart';
import '../repositories/meal_logging_repository.dart';

/// Use case for logging a meal.
class LogMealUseCase implements UseCase<MealLog, MealLog> {
  final MealLoggingRepository repository;

  LogMealUseCase(this.repository);

  @override
  Future<Either<Failure, MealLog>> call(MealLog params) {
    return repository.logMeal(params);
  }
}
