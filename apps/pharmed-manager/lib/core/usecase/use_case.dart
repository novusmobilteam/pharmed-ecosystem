import 'package:pharmed_core/src/result/result.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

abstract class NoParamsUseCase<T> {
  Future<Result<T>> call();
}
