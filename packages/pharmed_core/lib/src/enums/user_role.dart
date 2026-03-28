import 'app_mode.dart';

enum UserRole {
  admin('Admin'),
  manager('Yönetici'),
  client('İstasyon Operatörü');

  final String label;
  const UserRole(this.label);
}

extension UserRoleExtension on UserRole {
  // Bu rol hangi modlara geçiş yapabilir?
  List<AppMode> get switchableModes {
    switch (this) {
      case UserRole.admin:
        return AppMode.values; // Tüm modlara geçebilir
      case UserRole.manager:
        return [AppMode.manager, AppMode.client]; // Kendi ve client'a
      case UserRole.client:
        return [AppMode.client]; // Sadece kendi modunda
    }
  }

  // Varsayılan mod
  AppMode get defaultMode {
    switch (this) {
      case UserRole.admin:
        return AppMode.admin;
      case UserRole.manager:
        return AppMode.manager;
      case UserRole.client:
        return AppMode.client;
    }
  }

  // Rolün adını döndür (veritabanı için)
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.client:
        return 'client';
    }
  }

  // String'den UserRole'a dönüşüm
  static UserRole? fromString(String? name) {
    if (name == null) return null;
    for (final role in UserRole.values) {
      if (role.name == name) return role;
    }
    return null;
  }
}
