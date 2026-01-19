import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> login(String email, String password) async {
    // TODO: Implement login logic
    throw UnimplementedError();
  }

  @override
  Future<User> register(String email, String password, String name) async {
    // TODO: Implement register logic
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    // TODO: Implement logout logic
    throw UnimplementedError();
  }

  @override
  Future<bool> isAuthenticated() async {
    // TODO: Implement authentication check
    throw UnimplementedError();
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: Implement get current user
    throw UnimplementedError();
  }

  @override
  Future<void> refreshToken() async {
    // TODO: Implement token refresh
    throw UnimplementedError();
  }
}
