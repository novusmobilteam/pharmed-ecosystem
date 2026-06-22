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

  Future<Result<UserDto?>> getCurrentUser() async {
    return await fetchRequest(
      path: '/CurrentUser',
      parser: BaseRemoteDataSource.singleParser(UserDto.fromJson),
      successLog: 'Kullanıcı getirildi.',
    );
  }

  Future<Result<ApiResponse<List<UserDto>>?>> getUsers({
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
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(UserDto.fromJson),
      successLog: 'Kişiler getirildi',
      emptyLog: 'Kişi bulunamadı',
    );
  }

  Future<Result<void>> createUser(UserDto dto) {
    return postRequest(
      path: _base,
      body: dto.toJson(),
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kişi oluşturuldu',
    );
  }

  Future<Result<ApiResponse<List<UserDto>>?>> getDoctors({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) async {
    return await fetchRequest(
      path: '$_base/roleDoctor',
      skip: skip,
      take: take,
      searchText: search,
      searchFields: const ['name'],
      envelope: ResponseEnvelope.raw,
      parser: BaseRemoteDataSource.apiResponseListParser(UserDto.fromJson),
      successLog: 'Doktorlar getirildi',
      emptyLog: 'Doktor bulunamadı',
    );
  }

  Future<Result<void>> updateUser(UserDto dto) {
    return putRequest(
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
    return putRequest(
      path: '$_base/bulkUpdateTimeBasedDate',
      body: {"dateTime": date.toIso8601String(), "userIds": ids},
      parser: BaseRemoteDataSource.voidParser(),
      successLog: 'Kişiler güncellendi',
    );
  }

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) {
    return postRequest(
      path: '$_base/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      parser: BaseRemoteDataSource.voidParser(),
    );
  }

  Future<Result<UserDto?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    return postRequest(
      path: '$_base/otherLogin',
      parser: BaseRemoteDataSource.singleParser(UserDto.fromJson),
      body: {"email": email, "password": password, "macAddress": macAddress},
    );
  }
}
