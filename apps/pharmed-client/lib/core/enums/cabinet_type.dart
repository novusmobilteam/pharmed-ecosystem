enum CabinetType {
  standard, // Sabit, 5 bölümlü
  mobile, // Tekerlekli, 4 sıralı
}

extension CabinetTypeExt on CabinetType {
  String get label => switch (this) {
    CabinetType.standard => 'Standart Kabin',
    CabinetType.mobile => 'Mobil Kabin',
  };

  String get description => switch (this) {
    CabinetType.standard => 'Sabit, kübik / birim doz çekmeceli kabin',
    CabinetType.mobile => 'Tekerlekli, 4 sıralı taşınabilir ünite',
  };
}
