import '../../../../features/user/user.dart';
import '../../../core.dart';

abstract class AuthPersistence {
  String? get accessToken;
  Future<void> saveToken(String? token);

  String? get email;
  String? get password;
  Future<void> saveCredentials(String email, String password);

  User? get user;
  Future<void> saveUser(User? user);

  // Ordersız işlem yapma durumu
  OrderStatus get orderStatus;

  Future<void> clearAuth(); // Logout işlemleri için
}
