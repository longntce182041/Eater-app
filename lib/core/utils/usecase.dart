import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

/// Abstract base class for all use cases.
/// 
/// Type parameters:
/// - [Type]: The return type of the use case.
/// - [Params]: The parameters required by the use case.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters.
class NoParams {
  const NoParams();
}

/// Pagination parameters for list-based use cases.
class PaginationParams {
  final int page;
  final int limit;

  const PaginationParams({
    this.page = 1,
    this.limit = 20,
  });
}
