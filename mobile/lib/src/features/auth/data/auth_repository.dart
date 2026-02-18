import 'auth_api_client.dart';
import 'token_storage.dart';

class AuthRepository {
  final AuthApiClient api;
  final TokenStorage storage;

  AuthRepository({required this.api, required this.storage});

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final res = await api.register(email: email, password: password);
    final data =
        res.data['data'] ??
        res.data; // controller returns {status,message,data}
    await _persistTokensIfPresent(data);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await api.login(email: email, password: password);
    final data = res.data['data'] ?? res.data;
    await _persistTokensIfPresent(data);
    return Map<String, dynamic>.from(data);
  }

  Future<void> verifyEmail({required String token}) async {
    await api.verifyEmail(token: token);
  }

  Future<String> requestPasswordReset({required String email}) async {
    await api.requestPasswordReset(email: email);
    // No token in production - email sent instead
    return '';
  }

  Future<void> resetPassword({
    required String otp,
    required String newPassword,
  }) async {
    await api.resetPassword(otp: otp, newPassword: newPassword);
  }

  Future<void> refresh() async {
    final rt = await storage.getRefreshToken();
    if (rt == null || rt.isEmpty) return;
    final res = await api.refresh(refreshToken: rt);
    final data = res.data['data'] ?? res.data;
    await _persistTokensIfPresent(data);
  }

  Future<void> logout() async {
    final rt = await storage.getRefreshToken();
    if (rt != null && rt.isNotEmpty) {
      await api.logout(refreshToken: rt);
    }
    await storage.clear();
  }

  Future<void> _persistTokensIfPresent(Map<String, dynamic> data) async {
    final at = data['accessToken'] as String?;
    final rt = data['refreshToken'] as String?;
    if (at != null && rt != null) {
      await storage.saveTokens(accessToken: at, refreshToken: rt);
    }
  }
}
