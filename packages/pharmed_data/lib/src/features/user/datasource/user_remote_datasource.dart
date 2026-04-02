// [SWREQ-DATA-USER-001]
// APIManager üzerinden çalışır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UserRemoteDataSource extends BaseRemoteDataSource {
  UserRemoteDataSource({required super.apiManager});

  @override
  String get logSwreq => 'SWREQ-DATA-USER-001';

  @override
  String get logUnit => 'SW-UNIT-USER';

  static const _base = '/User';

  Future<Result<UserDTO?>> getCurrentUser() async {
    return await fetchRequest(
      path: '/CurrentUser',
      parser: BaseRemoteDataSource.singleParser(UserDTO.fromJson),
      successLog: 'Kullanıcı getirildi.',
    );
  }

  Future<Result<ApiResponse<List<UserDTO>>?>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) async {
    return await fetchRequest(
      path: '$_base/type/${type?.id ?? 0}',
      skip: skip,
      take: take,
      //searchText: search,
      //searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(UserDTO.fromJson),
      successLog: 'Kişiler getirildi',
      emptyLog: 'Kişi bulunamadı',
    );
  }

  Future<Result<void>> createUser(UserDTO dto) {
    return createRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kişi oluşturuldu',
    );
  }

  Future<Result<void>> updateUser(UserDTO dto) {
    return updateRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kişi güncellendi',
    );
  }

  Future<Result<void>> deleteUser(int id) {
    return deleteRequest(path: '$_base/$id', parser: BaseRemoteDataSource.voidParser(), successLog: 'Kişi silindi');
  }

  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) {
    return updateRequest(
      path: '$_base/bulkUpdateTimeBasedDate',
      body: {"dateTime": date.toIso8601String(), "userIds": ids},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kişiler güncellendi',
    );
  }

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) {
    return createRequest(
      path: '$_base/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<UserDTO?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    return createRequest(
      path: '$_base/otherLogin',
      parser: BaseRemoteDataSource.singleParser(UserDTO.fromJson),
      body: {"email": email, "password": password, "macAddress": macAddress},
    );
  }
}
