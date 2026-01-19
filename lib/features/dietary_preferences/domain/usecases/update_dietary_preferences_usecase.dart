import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/dietary_preferences.dart';
import '../repositories/dietary_preferences_repository.dart';

/// Use case for updating dietary preferences.
class UpdateDietaryPreferencesUseCase
    implements UseCase<DietaryPreferences, DietaryPreferences> {
  final DietaryPreferencesRepository repository;

  UpdateDietaryPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, DietaryPreferences>> call(
    DietaryPreferences params,
  ) {
    return repository.updateDietaryPreferences(params);
  }
}
