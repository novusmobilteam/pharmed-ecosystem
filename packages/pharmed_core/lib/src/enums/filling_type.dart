/// Dolum Listesi Tip
/// Ekranda yer alan min, max, kritik radio buttonları. İstek atılırken de kullanılıyor.
enum FillingType {
  all(4),
  max(3), //  Stok maksimum seviyenin altına düşmüşse
  min(1), // Stok minimum seviyenin altına düşmüşse
  critic(2); // Stok kritik seviyenin altına düşmüşse

  final int id;

  const FillingType(this.id);

  static FillingType fromId(int? id) {
    return FillingType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => FillingType.min,
    );
  }

  String get label {
    switch (this) {
      case FillingType.min:
        return 'Minimum';
      case FillingType.critic:
        return 'Kritik';
      case FillingType.max:
        return 'Maksimum';
      case FillingType.all:
        return 'Tümü';
    }
  }
}
