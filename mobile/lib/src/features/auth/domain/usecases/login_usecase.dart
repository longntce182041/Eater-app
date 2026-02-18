import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import '../../presentation/providers/auth_providers.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return LoginUseCase(repo);
});

class LoginUseCase {
  final AuthRepository _repo;
  LoginUseCase(this._repo);

  Future<Map<String, dynamic>> execute({
    required String email,
    required String password,
  }) {
    return _repo.login(email: email, password: password);
  }
}
