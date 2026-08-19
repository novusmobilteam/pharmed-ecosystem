import 'package:pharmed_ui/pharmed_ui.dart';

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
        return contextlessL10n().enumCore_cabinTypeStandard;
      case CabinType.cabinet:
        return contextlessL10n().enumCore_cabinTypeCloset;
      case CabinType.freezer:
        return contextlessL10n().enumCore_cabinTypeFridge;
      case CabinType.openCabinet:
        return contextlessL10n().enumCore_cabinTypeOpenCloset;
      case CabinType.mobile:
        return contextlessL10n().enumCore_cabinTypeMobile;
      case CabinType.returnCabin:
        return contextlessL10n().enumCore_cabinTypeExternalReturn;
      case CabinType.openCabin:
        return contextlessL10n().enumCore_cabinTypeOpen;
      case CabinType.serum:
        return contextlessL10n().enumCore_cabinTypeSerum;
    }
  }

  static List<CabinType> get creatableTypes =>
      CabinType.values.where((t) => t != CabinType.master && t != CabinType.mobile).toList();
}

extension CabinTypeExt on CabinType {
  bool get isMobile => this == CabinType.mobile;
  bool get isVisualizable => this == CabinType.master || this == CabinType.mobile;
}
