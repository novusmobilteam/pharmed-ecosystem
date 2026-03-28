enum PatientFilterType {
  /// 1 - Order Saati Gelenler
  ordersDue(1, 'Order Saati Gelenler'),

  /// 2 - Tüm Hastalar
  all(2, 'Tüm Hastalar'),

  /// 3 - Zamanı Gelmemiş
  upcoming(3, 'Zamanı Gelmemiş'),

  /// 4 - Zamanı Geçmiş
  overdue(4, 'Zamanı Geçmiş'),

  /// 5 - İade Yapılabilir Durumdakiler
  returnable(5, 'İade Yapılabilir'),

  /// 6 - Fire/İmha Girilebilir Durumdakiler
  destroyable(6, 'Fire/İmha Girilebilir');

  final int id;
  final String label;

  const PatientFilterType(this.id, this.label);

  /// ID'ye göre Enum'ı bulmak için yardımcı metod (Service'den gelen int değeri çevirmek için)
  static PatientFilterType fromId(int id) {
    return PatientFilterType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PatientFilterType.all, // Varsayılan değer
    );
  }
}
