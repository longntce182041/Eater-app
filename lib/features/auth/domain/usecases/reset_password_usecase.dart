import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for resetting password.
class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) {
    return repository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}

/// Parameters for reset password use case.
class ResetPasswordParams {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const ResetPasswordParams({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });
}
