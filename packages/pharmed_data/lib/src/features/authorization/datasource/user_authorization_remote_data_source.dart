import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

// [SWREQ-DATA-USERAUTHORIZATION-001]
// Sınıf: Class B
class UserAuthorizationRemoteDataSource extends BaseRemoteDataSource {
  UserAuthorizationRemoteDataSource({required super.apiManager});

  final String _basePath = '/UserAuthentication';

  @override
  String get logSwreq => 'SWREQ-DATA-USERAUTHORIZATION-001';

  @override
  String get logUnit => 'SW-UNIT-USERAUTHORIZATION';

  Future<Result<List<UserMenuAuthorizationDto>>> getAuthentications() async {
    final res = await fetchRequest(
      path: _basePath,
      parser: BaseRemoteDataSource.listParser(UserMenuAuthorizationDto.fromJson),
      successLog: 'User authentications fetched',
      emptyLog: 'No authentication',
    );

    return res.when(ok: (data) => Result.ok(data ?? const <UserMenuAuthorizationDto>[]), error: Result.error);
  }

  Future<Result<UserMenuAuthorizationDto?>> getAuthentication(int id) async {
    final res = await fetchRequest(
      path: '$_basePath/$id',
      parser: BaseRemoteDataSource.singleParser(UserMenuAuthorizationDto.fromJson),
      successLog: 'User authentications fetched',
      emptyLog: 'No authentication',
    );

    return res.when(ok: (data) => Result.ok(data), error: Result.error);
  }

  Future<Result<void>> updateAuthentication(UserMenuAuthorizationDto dto) {
    return updateRequest(
      path: '$_basePath/${dto.userId}',
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'User authentication updated',
    );
  }

  Future<Result<void>> createAuthentication(UserMenuAuthorizationDto dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'User authentication created',
    );
  }
}
