import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/nutrition_summary.dart';
import '../repositories/meal_logging_repository.dart';

/// Use case for getting nutrition summary.
class GetNutritionSummaryUseCase
    implements UseCase<NutritionSummary, DateTime> {
  final MealLoggingRepository repository;

  GetNutritionSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, NutritionSummary>> call(DateTime params) {
    return repository.getNutritionSummary(params);
  }
}
