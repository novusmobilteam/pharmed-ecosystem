// packages/pharmed_data/lib/src/user/datasource/user_remote_datasource.dart
//
// [SWREQ-DATA-USER-001]
// APIManager üzerinden çalışır.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class UserRemoteDataSource {
  const UserRemoteDataSource({required APIManager apiManager}) : _api = apiManager;

  final APIManager _api;

  static const _base = '/User';

  Future<Result<UserDTO?>> getCurrentUser() {
    return _api.get(
      '$_base/getCurrentUser',
      parser: (data) => data != null ? UserDTO.fromJson(Map<String, dynamic>.from(data as Map)) : null,
    );
  }

  Future<Result<ApiResponse<List<UserDTO>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) {
    return _api.get(
      '$_base/getUsers',
      queryParameters: {
        if (type != null) 'type': type.id,
        if (skip != null) 'skip': skip,
        if (take != null) 'take': take,
        if (search != null) 'search': search,
        if (searchFields != null) 'searchFields': searchFields,
      },
      parser: (data) => ApiResponse<List<UserDTO>>.fromJson(
        data as Map<String, dynamic>,
        (json) => (json as List).map((e) => UserDTO.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      ),
    );
  }

  Future<Result<void>> createUser(UserDTO dto) {
    return _api.post('$_base/createUser', data: dto.toJson());
  }

  Future<Result<void>> updateUser(UserDTO dto) {
    return _api.put('$_base/updateUser', data: dto.toJson());
  }

  Future<Result<void>> deleteUser(int id) {
    return _api.delete('$_base/deleteUser/$id');
  }

  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) {
    return _api.patch('$_base/bulkUpdateValidDate', data: {'date': date.toIso8601String(), 'ids': ids});
  }

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) {
    return _api.patch('$_base/changePassword', data: {'currentPassword': currentPassword, 'newPassword': newPassword});
  }

  Future<Result<UserDTO?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) {
    return _api.post(
      '$_base/witnessUserLogin',
      data: {'email': email, 'password': password, 'macAddress': macAddress},
      parser: (data) => data != null ? UserDTO.fromJson(Map<String, dynamic>.from(data as Map)) : null,
    );
  }
}
