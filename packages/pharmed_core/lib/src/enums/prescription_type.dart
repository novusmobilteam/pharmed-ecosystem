enum PrescriptionType {
  white(1),
  serumWhite(2),
  red(3),
  green(4),
  orange(5),
  purple(6);

  final int id;

  const PrescriptionType(this.id);

  static PrescriptionType fromId(int? id) {
    return PrescriptionType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PrescriptionType.white,
    );
  }

  String get label {
    switch (this) {
      case PrescriptionType.white:
        return 'Beyaz Reçete';
      case PrescriptionType.serumWhite:
        return 'Serum(Beyaz Reçete)';

      case PrescriptionType.red:
        return 'Kırmızı Reçete';

      case PrescriptionType.green:
        return 'Yeşil Reçete';

      case PrescriptionType.orange:
        return 'Turuncu Reçete';

      case PrescriptionType.purple:
        return 'Mor Reçete';
    }
  }
}
