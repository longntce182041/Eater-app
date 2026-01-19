import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/health_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_datasource.dart';
import '../datasources/user_profile_remote_datasource.dart';
import '../models/user_profile_model.dart';
import '../models/health_info_model.dart';

/// Implementation of UserProfileRepository.
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource remoteDataSource;
  final UserProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final profile = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUserProfile(profile);
        return Right(profile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedProfile = await localDataSource.getCachedUserProfile();
        if (cachedProfile != null) {
          return Right(cachedProfile);
        }
        return const Left(CacheFailure(message: 'No cached profile data'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UserProfile profile,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final profileModel = UserProfileModel(
        userId: profile.userId,
        firstName: profile.firstName,
        lastName: profile.lastName,
        avatarUrl: profile.avatarUrl,
        dateOfBirth: profile.dateOfBirth,
        gender: profile.gender,
        height: profile.height,
        weight: profile.weight,
        activityLevel: profile.activityLevel,
      );

      final updatedProfile = await remoteDataSource.updateUserProfile(
        profileModel,
      );
      await localDataSource.cacheUserProfile(updatedProfile);
      return Right(updatedProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, HealthInfo>> getHealthInfo() async {
    if (await networkInfo.isConnected) {
      try {
        final healthInfo = await remoteDataSource.getHealthInfo();
        await localDataSource.cacheHealthInfo(healthInfo);
        return Right(healthInfo);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final cachedInfo = await localDataSource.getCachedHealthInfo();
        if (cachedInfo != null) {
          return Right(cachedInfo);
        }
        return const Left(CacheFailure(message: 'No cached health info'));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, HealthInfo>> updateHealthInfo(
    HealthInfo healthInfo,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final healthInfoModel = HealthInfoModel(
        userId: healthInfo.userId,
        dailyCalorieGoal: healthInfo.dailyCalorieGoal,
        dailyProteinGoal: healthInfo.dailyProteinGoal,
        dailyCarbsGoal: healthInfo.dailyCarbsGoal,
        dailyFatGoal: healthInfo.dailyFatGoal,
        dailyFiberGoal: healthInfo.dailyFiberGoal,
        medicalConditions: healthInfo.medicalConditions,
        medications: healthInfo.medications,
      );

      final updatedInfo = await remoteDataSource.updateHealthInfo(
        healthInfoModel,
      );
      await localDataSource.cacheHealthInfo(updatedInfo);
      return Right(updatedInfo);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(filePath);
      return Right(avatarUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await remoteDataSource.deleteAccount();
      await localDataSource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
