import 'package:pharmed_manager/core/core.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

abstract class NoParamsUseCase<T> {
  Future<Result<T>> call();
}
