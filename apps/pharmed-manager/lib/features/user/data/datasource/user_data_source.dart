import '../../../../core/core.dart';
import '../model/user_dto.dart';

/// Kullanıcı (User) işlemleri için veri kaynağı arayüzü.
abstract class UserDataSource {
  /// Kullanıcıları sayfalı bir şekilde listeler.
  Future<Result<ApiResponse<List<UserDTO>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  });
  Future<Result<UserDTO?>> getCurrentUser();
  Future<Result<void>> createUser(UserDTO dto);
  Future<Result<void>> updateUser(UserDTO dto);
  Future<Result<void>> deleteUser(int id);
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids);
  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  Future<Result<UserDTO?>> witnessUserLogin({
    required String email,
    required String password,
    required String macAddress,
  });
}
