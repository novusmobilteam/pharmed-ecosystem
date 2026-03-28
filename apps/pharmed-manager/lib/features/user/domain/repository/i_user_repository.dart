import '../../../../core/core.dart';
import '../entity/user.dart';

abstract class IUserRepository {
  Future<Result<ApiResponse<List<User>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  });
  Future<Result<void>> createUser(User user);
  Future<Result<void>> updateUser(User user);
  Future<Result<void>> deleteUser(User user);

  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids);
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});
  Future<Result<User?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  });
}
