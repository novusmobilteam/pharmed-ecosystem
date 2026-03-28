import '../../../../core/core.dart';
import '../../domain/entity/user.dart';
import '../../domain/repository/i_user_repository.dart';
import '../datasource/user_data_source.dart';

class UserRepository implements IUserRepository {
  final UserDataSource _ds;

  UserRepository({required UserDataSource dataSource}) : _ds = dataSource;

  @override
  Future<Result<ApiResponse<List<User>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  }) async {
    final r = await _ds.getUsers(
      type: type,
      skip: skip,
      take: take,
      searchFields: searchFields,
      search: search,
    );
    return r.when(
      ok: (response) {
        List<User> entities = [];
        if (response.data != null) {
          entities = response.data!.map((e) => e.toEntity()).toList();
        }
        return Result.ok(ApiResponse<List<User>>(
          data: entities,
          statusCode: response.statusCode,
          isSuccess: response.isSuccess,
          totalCount: response.totalCount,
          groupCount: response.groupCount,
        ));
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<void>> createUser(User user) async {
    final dto = user.toDTO();
    final r = await _ds.createUser(dto);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> updateUser(User user) async {
    final dto = user.toDTO();
    final r = await _ds.updateUser(dto);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> deleteUser(User user) async {
    final id = user.id;
    if (id == null) {
      return Result.error(CustomException(message: 'deleteUser: id is null'));
    }
    final r = await _ds.deleteUser(id);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    final r = await _ds.getCurrentUser();
    return r.when(
      ok: (data) => Result.ok(data?.toEntity()),
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids) async {
    final r = await _ds.bulkUpdateValidDate(date, ids);
    return r.when(
      ok: (_) {
        return Result.ok(null);
      },
      error: Result.error,
    );
  }

  @override
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword}) async {
    return await _ds.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<Result<User?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  }) async {
    final res = await _ds.witnessUserLogin(
      email: email,
      password: password,
      macAddress: macAddress,
    );

    return res.when(
      ok: (data) {
        final user = data?.toEntity();
        return Result.ok(user);
      },
      error: (e) {
        return Result.error(e);
      },
    );
  }
}
