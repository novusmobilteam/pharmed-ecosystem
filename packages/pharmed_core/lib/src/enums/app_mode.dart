enum AppMode {
  admin('Admin'),
  manager('Yönetim'),
  client('İstasyon');

  final String label;

  const AppMode(this.label);

  bool get isAdmin => this == AppMode.admin;
  bool get isManager => this == AppMode.manager;
  bool get isClient => this == AppMode.client;

  static List<AppMode> selectableModes = [AppMode.manager, AppMode.client];
}
