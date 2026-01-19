import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/auth_tokens.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user registration.
class RegisterUseCase implements UseCase<(User, AuthTokens), RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, (User, AuthTokens)>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
      username: params.username,
    );
  }
}

/// Parameters for register use case.
class RegisterParams {
  final String email;
  final String password;
  final String confirmPassword;
  final String? username;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.username,
  });
}
