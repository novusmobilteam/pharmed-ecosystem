enum WarningSubject {
  /// Zamansız Alım
  untimelyIntake(1),

  /// Tutarsızlık Çözümü
  inconsistencyResolution(2),

  /// İmha
  destruction(3),

  /// Fire
  wastage(4);

  final int id;

  const WarningSubject(this.id);

  static WarningSubject fromId(int? id) {
    return WarningSubject.values.firstWhere(
      (e) => e.id == id,
      orElse: () => WarningSubject.untimelyIntake,
    );
  }

  String get label {
    switch (this) {
      case WarningSubject.untimelyIntake:
        return 'Zamansız Alım';
      case WarningSubject.wastage:
        return 'Fire';
      case WarningSubject.inconsistencyResolution:
        return 'Tutarsızlık Çözümü';
      case WarningSubject.destruction:
        return 'İmha';
    }
  }
}
