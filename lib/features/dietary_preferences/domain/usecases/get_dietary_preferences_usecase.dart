import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/dietary_preferences.dart';
import '../repositories/dietary_preferences_repository.dart';

/// Use case for getting dietary preferences.
class GetDietaryPreferencesUseCase
    implements UseCase<DietaryPreferences, NoParams> {
  final DietaryPreferencesRepository repository;

  GetDietaryPreferencesUseCase(this.repository);

  @override
  Future<Either<Failure, DietaryPreferences>> call(NoParams params) {
    return repository.getDietaryPreferences();
  }
}
