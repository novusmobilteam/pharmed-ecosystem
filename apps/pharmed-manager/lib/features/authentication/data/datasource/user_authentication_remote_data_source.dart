import '../../../../core/core.dart';
import '../model/user_menu_authentication_dto.dart';
import 'user_authentication_data_source.dart';

class UserAuthenticationRemoteDataSource extends BaseRemoteDataSource implements UserAuthenticationDataSource {
  final String _basePath = '/UserAuthentication';

  UserAuthenticationRemoteDataSource({required super.apiManager});

  @override
  Future<Result<List<UserMenuAuthenticationDTO>>> getAuthentications() async {
    final res = await fetchRequest(
      path: _basePath,
      parser: listParser(UserMenuAuthenticationDTO.fromJson),
      successLog: 'User authentications fetched',
      emptyLog: 'No authentication',
    );

    return res.when(
      ok: (data) => Result.ok(data ?? const <UserMenuAuthenticationDTO>[]),
      error: Result.error,
    );
  }

  @override
  Future<Result<UserMenuAuthenticationDTO?>> getAuthentication(int id) async {
    final res = await fetchRequest(
      path: '$_basePath/$id',
      parser: singleParser(UserMenuAuthenticationDTO.fromJson),
      successLog: 'User authentications fetched',
      emptyLog: 'No authentication',
    );

    return res.when(
      ok: (data) => Result.ok(data),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateAuthentication(UserMenuAuthenticationDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.userId}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'User authentication updated',
    );
  }

  @override
  Future<Result<void>> createAuthentication(UserMenuAuthenticationDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'User authentication created',
    );
  }
}
