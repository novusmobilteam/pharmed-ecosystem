// packages/pharmed_data/lib/src/auth/repository/mock/auth_mock_repository.dart
//
// [SWREQ-DATA-AUTH-MOCK-001]
// Mock flavor için auth repository implementasyonu.
// Gerçek datasource'lara, Hive'a ve API'ye hiç çıkılmaz.
// Ağ gecikmesi simüle edilir.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class AuthMockRepository implements IAuthRepository {
  static const _delay = Duration(milliseconds: 600);

  static const _mockUsers = {
    'ayse.kara@hastane.com': (
      password: '123',
      name: 'Ayşe Kara',
      role: 'Sorumlu Hemşire',
      isAdmin: false,
      isNotOrdered: false,
    ),
    'admin': (password: 'admin', name: 'Sistem Yöneticisi', role: 'Admin', isAdmin: true, isNotOrdered: false),
    'dr.celik@hastane.com': (
      password: 'dr123',
      name: 'Dr. Ahmet Çelik',
      role: 'Hekim',
      isAdmin: false,
      isNotOrdered: true,
    ),
  };

  @override
  Future<Result<AuthToken>> login({required String email, required String password, String? macAddress}) async {
    await Future.delayed(_delay);

    final u = email.trim().toLowerCase();
    final userData = _mockUsers[u];

    if (userData == null || userData.password != password) {
      return Result.error(ServiceException(message: 'Kullanıcı adı veya şifre hatalı.', statusCode: 401));
    }

    return Result.ok(
      AuthToken(
        accessToken: 'mock_token_${u.hashCode}',
        user: AppUser(
          id: u.hashCode.abs(),
          email: u,
          name: userData.name,
          surname: userData.name,
          fullName: userData.name,
          role: userData.role,
          isAdmin: userData.isAdmin,
          isNotOrdered: userData.isNotOrdered,
        ),
      ),
    );
  }

  @override
  Future<Result<void>> logout() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const Result.ok(null);
  }

  @override
  Future<String?> getStoredToken() async => null;
}
