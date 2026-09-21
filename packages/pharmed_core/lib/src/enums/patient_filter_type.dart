import 'package:pharmed_ui/pharmed_ui.dart';

enum PatientFilterType {
  /// 0 - Tüm Hastalar
  all(0),

  /// 1 - Order Saati Gelenler
  ordersDue(1),

  // /// 2 - Tüm Hastalar (Reçetesi olan)
  // allWithRx(2),

  /// 3 - Zamanı Gelmemiş
  upcoming(3),

  /// 4 - Zamanı Geçmiş
  overdue(4),

  /// 5 - İade Yapılabilir Durumdakiler
  returnable(5),

  /// 6 - Fire/İmha Girilebilir Durumdakiler
  destroyable(6);

  final int id;

  const PatientFilterType(this.id);

  String get label {
    switch (this) {
      case PatientFilterType.all:
        return contextlessL10n().enumCore_patientFilterAll;
      case PatientFilterType.ordersDue:
        return contextlessL10n().enumCore_patientFilterOrderTimeReached;
      // case PatientFilterType.allWithRx:
      //   return contextlessL10n().dashboard_kpiPendingPrescriptions;
      case PatientFilterType.upcoming:
        return contextlessL10n().enumCore_patientFilterTimeNotReached;
      case PatientFilterType.overdue:
        return contextlessL10n().enumCore_patientFilterTimePassed;
      case PatientFilterType.returnable:
        return contextlessL10n().enumCore_patientFilterReturnable;
      case PatientFilterType.destroyable:
        return contextlessL10n().enumCore_patientFilterWasteDisposable;
    }
  }

  /// ID'ye göre Enum'ı bulmak için yardımcı metod (Service'den gelen int değeri çevirmek için)
  static PatientFilterType fromId(int id) {
    return PatientFilterType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => PatientFilterType.all, // Varsayılan değer
    );
  }
}
