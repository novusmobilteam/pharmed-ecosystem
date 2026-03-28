import '../../../../core/core.dart';
import '../../../user/user.dart';
import '../../domain/entity/user_menu_authentication.dart';
import '../../domain/repository/i_user_authentication_repository.dart';
import '../datasource/user_authentication_data_source.dart';

class UserAuthenticationRepository implements IUserAuthenticationRepository {
  final UserAuthenticationDataSource _ds;

  UserAuthenticationRepository(this._ds);

  @override
  Future<Result<UserMenuAuthentication>> getAuthentication(User user) async {
    final res = await _ds.getAuthentication(user.id!);
    return res.when(
      ok: (dto) => Result.ok(
        UserMenuAuthentication.fromDTO(dto: dto, user: user),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> saveAuthentication(UserMenuAuthentication auth) async {
    final dto = auth.toDTO();

    if (auth.id != null) {
      return _ds.updateAuthentication(dto);
    } else {
      return _ds.createAuthentication(dto);
    }
  }
}
