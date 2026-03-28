import '../../../../core/core.dart';
import '../model/user_menu_authentication_dto.dart';

abstract class UserAuthenticationDataSource {
  Future<Result<List<UserMenuAuthenticationDTO>>> getAuthentications();
  Future<Result<UserMenuAuthenticationDTO?>> getAuthentication(int id);
  Future<Result<void>> updateAuthentication(UserMenuAuthenticationDTO dto);
  Future<Result<void>> createAuthentication(UserMenuAuthenticationDTO dto);
}
