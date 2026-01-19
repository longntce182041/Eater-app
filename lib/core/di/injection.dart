import 'package:get_it/get_it.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures all dependencies for the application.
/// 
/// This function should be called once at app startup.
Future<void> configureDependencies() async {
  // Register core services
  await _registerCoreServices();
  
  // Register feature-specific dependencies
  await _registerAuthDependencies();
  await _registerUserProfileDependencies();
  await _registerDietaryPreferencesDependencies();
  await _registerMealPlansDependencies();
  await _registerRecipesDependencies();
  await _registerMealLoggingDependencies();
  await _registerShoppingListDependencies();
}

Future<void> _registerCoreServices() async {
  // TODO: Register Dio, SharedPreferences, SecureStorage, etc.
  // Example:
  // getIt.registerLazySingleton<Dio>(() => DioClient.createDio());
  // getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
}

Future<void> _registerAuthDependencies() async {
  // TODO: Register AuthRepository, AuthRemoteDataSource, use cases, etc.
  // Example:
  // getIt.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(dio: getIt()),
  // );
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(remoteDataSource: getIt()),
  // );
  // getIt.registerLazySingleton(() => LoginUseCase(getIt()));
}

Future<void> _registerUserProfileDependencies() async {
  // TODO: Register UserProfileRepository, data sources, use cases
}

Future<void> _registerDietaryPreferencesDependencies() async {
  // TODO: Register DietaryPreferencesRepository, data sources, use cases
}

Future<void> _registerMealPlansDependencies() async {
  // TODO: Register MealPlansRepository, data sources, use cases
}

Future<void> _registerRecipesDependencies() async {
  // TODO: Register RecipesRepository, data sources, use cases
}

Future<void> _registerMealLoggingDependencies() async {
  // TODO: Register MealLoggingRepository, data sources, use cases
}

Future<void> _registerShoppingListDependencies() async {
  // TODO: Register ShoppingListRepository, data sources, use cases
}
