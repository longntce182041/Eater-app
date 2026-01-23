import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

final loginControllerProvider =
StateNotifierProvider<LoginController, AuthState>((ref) {
  final usecase = ref.watch(loginUseCaseProvider);
  return LoginController(usecase);
});

class LoginController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;

  LoginController(this._loginUseCase) : super(const AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // TODO: invoke usecase and update state
  }
}