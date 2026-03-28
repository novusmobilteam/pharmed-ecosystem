/// Sayım Tipi
enum CountType {
  noCount(1), // Sayım Yok
  normalCount(2), // Normal Sayım
  blindCount(3); // Kör Sayım

  final int id;

  const CountType(this.id);

  static CountType fromId(int? id) {
    return CountType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => CountType.noCount,
    );
  }

  String get label {
    switch (this) {
      case CountType.noCount:
        return 'Sayım Yok';
      case CountType.normalCount:
        return 'Normal Sayım';
      case CountType.blindCount:
        return 'Kör Sayım';
    }
  }
}
