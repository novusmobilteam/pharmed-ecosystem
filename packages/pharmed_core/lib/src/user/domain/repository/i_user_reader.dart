// packages/pharmed_core/lib/src/user/domain/repository/i_user_reader.dart
//
// [SWREQ-CORE-USER-001]
// Her iki app tarafından kullanılan minimal kullanıcı okuma arayüzü.
// AuthRepositoryImpl bu interface'i alır — delete/update görmez.
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────────────────

import 'package:pharmed_core/pharmed_core.dart';

abstract interface class IUserReader {
  /// Oturum açmış kullanıcının bilgilerini döndürür.
  /// Token interceptor tarafından header'a eklenen token ile çağrılır.
  Future<Result<User?>> getCurrentUser();
}
