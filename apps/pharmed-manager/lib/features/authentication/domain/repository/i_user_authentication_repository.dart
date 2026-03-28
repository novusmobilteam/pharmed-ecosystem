import '../../../../core/core.dart';
import '../../../user/user.dart';
import '../entity/user_menu_authentication.dart';

abstract class IUserAuthenticationRepository {
  Future<Result<UserMenuAuthentication>> getAuthentication(User user);
  Future<Result<void>> saveAuthentication(UserMenuAuthentication auth);
}
