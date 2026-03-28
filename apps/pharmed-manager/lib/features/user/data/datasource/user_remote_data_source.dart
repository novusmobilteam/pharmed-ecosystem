import '../../../../core/utils/device_info.dart';

import '../../../../core/core.dart';
import '../model/user_dto.dart';
import 'user_data_source.dart';

class UserRemoteDataSource extends BaseRemoteDataSource implements UserDataSource {
  final String _basePath = '/User';

  UserRemoteDataSource({required super.apiManager});

  @override
  Future<Result<ApiResponse<List<UserDTO>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) async {
    final res = await fetchRequest<ApiResponse<List<UserDTO>>>(
      path: '$_basePath/type/${type?.id ?? 0}',
      skip: skip,
      take: take,
      searchText: search,
      //searchField: 'name',
      envelope: ResponseEnvelope.raw,
      parser: apiResponseListParser(UserDTO.fromJson),
      successLog: 'Users fetched',
      emptyLog: 'No users',
      searchFields: searchFields,
    );
    return res.when(
      ok: (data) {
        return Result.ok(data ?? const ApiResponse(data: [], totalCount: 0));
      },
      error: (error) {
        return Result.error(error);
      },
    );
  }

  @override
  Future<Result<void>> createUser(UserDTO dto) {
    return createRequest(
      path: _basePath,
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'User created',
    );
  }

  @override
  Future<Result<void>> updateUser(UserDTO dto) {
    return updateRequest(
      path: '$_basePath/${dto.id}',
      body: dto.toJson(),
      parser: voidParser(),
      successLog: 'User updated',
    );
  }

  @override
  Future<Result<void>> deleteUser(int id) {
    return deleteRequest<void>(
      path: '$_basePath/$id',
      parser: voidParser(),
      successLog: 'User deleted',
    );
  }

  @override
  Future<Result<UserDTO?>> getCurrentUser() async {
    final res = await fetchRequest<UserDTO>(
      path: '/CurrentUser',
      parser: singleParser(UserDTO.fromJson),
      successLog: 'Current user fetched',
    );
    return res.when(
      ok: (data) => Result.ok(data),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) {
    return updateRequest(
      path: '$_basePath/bulkUpdateTimeBasedDate',
      body: {
        "dateTime": date.toIso8601String(),
        "userIds": ids,
      },
      parser: voidParser(),
      successLog: 'User updated',
    );
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) {
    return createRequest(
      path: '$_basePath/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      parser: voidParser(),
    );
  }

  @override
  Future<Result<UserDTO?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    final macAddress = await DeviceInfo.getMacAddress();
    final res = await createRequest(
      path: '$_basePath/otherLogin',
      parser: singleParser(UserDTO.fromJson),
      body: {
        "email": email,
        "password": password,
        "macAddress": macAddress,
      },
    );
    return res.when(
      ok: (data) => Result.ok(data),
      error: Result.error,
    );
  }
}
