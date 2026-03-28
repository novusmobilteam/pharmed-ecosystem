import '../../../../core/core.dart';
import '../entity/token.dart';

abstract class IAuthRepository {
  Future<Result<Token>> login({required String email, required String password, String? macAddress});
}
