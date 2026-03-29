// packages/pharmed_data/lib/src/user/repository/user_repository_impl.dart
//
// [SWREQ-DATA-USER-002]
// Tek implementasyon, hem IUserReader hem IUserManager implement eder.
// DI katmanında hangi interface'in inject edileceği app'e göre belirlenir:
//   pharmed_client  → IUserReader
//   pharmed_manager → IUserManager
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_data/src/user/datasource/user_remote_datasource.dart';
import 'package:pharmed_data/src/user/mapper/user_mapper.dart';

class UserRepositoryImpl implements IUserManager {
  const UserRepositoryImpl({required UserRemoteDataSource dataSource, required UserMapper mapper})
    : _dataSource = dataSource,
      _mapper = mapper;

  final UserRemoteDataSource _dataSource;
  final UserMapper _mapper;

  // ── IUserReader ───────────────────────────────────────────────

  @override
  Future<Result<User?>> getCurrentUser() async {
    final result = await _dataSource.getCurrentUser();
    return result.when(ok: (dto) => Result.ok(_mapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }

  // ── IUserManager ─────────────────────────────────────────────

  @override
  Future<Result<ApiResponse<List<User>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) async {
    final result = await _dataSource.getUsers(
      type: type,
      skip: skip,
      take: take,
      search: search,
      searchFields: searchFields,
    );
    return result.when(
      ok: (apiResponse) => Result.ok(
        ApiResponse<List<User>>(
          data: apiResponse.data != null ? _mapper.toEntityList(apiResponse.data!) : null,
          isSuccess: apiResponse.isSuccess,
          totalCount: apiResponse.totalCount,
        ),
      ),
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createUser(User user) => _dataSource.createUser(_mapper.toDto(user));

  @override
  Future<Result<void>> updateUser(User user) => _dataSource.updateUser(_mapper.toDto(user));

  @override
  Future<Result<void>> deleteUser(int id) => _dataSource.deleteUser(id);

  @override
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) => _dataSource.bulkUpdateValidDate(date, ids);

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) =>
      _dataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword);

  @override
  Future<Result<User?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    final result = await _dataSource.witnessUserLogin(email: email, password: password, macAddress: macAddress);
    return result.when(ok: (dto) => Result.ok(_mapper.toEntityOrNull(dto)), error: (e) => Result.error(e));
  }
}
