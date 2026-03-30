enum CabinType {
  master(1),
  cabinet(2),
  freezer(3),
  openCabinet(4),
  mobile(5),
  returnCabin(6),
  openCabin(7),
  serum(8);

  final int id;

  const CabinType(this.id);

  static CabinType? fromId(int? id) {
    return CabinType.values.firstWhere((e) => e.id == id, orElse: () => CabinType.master);
  }

  String get label {
    switch (this) {
      case CabinType.master:
        return 'Standart Kabin';
      case CabinType.cabinet:
        return 'Dolap';
      case CabinType.freezer:
        return 'Buzdolabı';
      case CabinType.openCabinet:
        return 'Açık Dolap';
      case CabinType.mobile:
        return 'Mobil Kabin';
      case CabinType.returnCabin:
        return 'Harici İade Kabini';
      case CabinType.openCabin:
        return 'Açık Kabin';
      case CabinType.serum:
        return 'Serum Kabini';
    }
  }
}
