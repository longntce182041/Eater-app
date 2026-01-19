import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/meal_log.dart';
import '../repositories/meal_logging_repository.dart';

/// Use case for getting meal logs for a date.
class GetMealLogsUseCase implements UseCase<List<MealLog>, DateTime> {
  final MealLoggingRepository repository;

  GetMealLogsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MealLog>>> call(DateTime params) {
    return repository.getMealLogs(params);
  }
}
