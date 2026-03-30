// [SWREQ-CORE-USER-002]
// Sadece pharmed_manager tarafından kullanılır.
// IUserReader'ı extend eder — getCurrentUser buraya da dahil.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

abstract interface class IUserManager implements IUserReader {
  Future<Result<ApiResponse<List<User>>>> getUsers({
    UserType? type,
    int? skip,
    int? take,
    String? search,
    List<String>? searchFields,
  });

  Future<Result<void>> createUser(User user);
  Future<Result<void>> updateUser(User user);
  Future<Result<void>> deleteUser(int id);
  Future<Result<void>> bulkUpdateValidDate(DateTime date, List<int> ids);

  Future<Result<void>> changePassword({required String currentPassword, required String newPassword});

  Future<Result<User?>> witnessUserLogin({required String email, required String password, required String macAddress});
}
