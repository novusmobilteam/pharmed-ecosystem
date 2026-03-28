enum UserType {
  normal(1),
  timeBased(2),
  temporary(3);

  final int id;

  const UserType(this.id);

  String get label {
    switch (this) {
      case UserType.normal:
        return 'Süresiz';
      case UserType.timeBased:
        return 'Süreli';
      case UserType.temporary:
        return 'Geçici';
    }
  }

  static UserType fromId(int? id) {
    return UserType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => UserType.normal,
    );
  }
}
