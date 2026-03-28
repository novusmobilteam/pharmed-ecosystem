import '../../../../core/core.dart';
import '../model/user_menu_authentication_dto.dart';
import 'user_authentication_data_source.dart';

class UserAuthenticationLocalDataSource extends BaseLocalDataSource<UserMenuAuthenticationDTO, int>
    implements UserAuthenticationDataSource {
  UserAuthenticationLocalDataSource({
    required super.filePath,
  }) : super(
          fromJson: (m) => UserMenuAuthenticationDTO.fromJson(m),
          toJson: (d) => d.toJson(),
          getId: (d) => d.id ?? -1,
          assignId: (d, id) => UserMenuAuthenticationDTO.fromJson({...d.toJson(), 'id': id}),
        );

  @override
  Future<Result<List<UserMenuAuthenticationDTO>>> getAuthentications() async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data ?? []),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> updateAuthentication(UserMenuAuthenticationDTO dto) => updateRequest(dto);

  @override
  Future<Result<UserMenuAuthenticationDTO?>> getAuthentication(int id) async {
    final res = await fetchRequest();
    return res.when(
      ok: (response) => Result.ok(response.data?.first),
      error: (err) => Result.error(err),
    );
  }

  @override
  Future<Result<void>> createAuthentication(UserMenuAuthenticationDTO dto) => createRequest(dto);
}
