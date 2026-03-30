import 'package:pharmed_manager/core/core.dart';

import '../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../hospitalization/domain/entity/hospitalization.dart';

// İlaç Alım İşleminde hastaya reçete edilmiş ilaçlar için kullanılan model
class MedicineWithdrawItem {
  final int id;
  final int prescriptionId;
  final String medicineName;
  final String medicineBarcode;
  final num dosePiece;
  final DateTime? time;
  final bool firstDoseEmergency;
  final bool askDoctor;
  final bool inCaseOfNecessity;
  final Medicine? medicine;
  final Hospitalization? hospitalization;
  final CabinAssignment cabinAssignment;
  final User? approvalUser;
  final DateTime? applicationDate;
  final User? applicationUser;
  final CabinStock? stock;

  MedicineWithdrawItem({
    required this.id,
    required this.prescriptionId,
    required this.medicineName,
    required this.medicineBarcode,
    required this.dosePiece,
    required this.cabinAssignment,
    this.hospitalization,
    this.medicine,
    this.firstDoseEmergency = false,
    this.askDoctor = false,
    this.inCaseOfNecessity = false,
    this.time,
    this.approvalUser,
    this.applicationUser,
    this.applicationDate,
    this.stock,
  });

  factory MedicineWithdrawItem.empty(CabinAssignment? assignment) {
    return MedicineWithdrawItem(
      id: 0,
      prescriptionId: 0,
      medicineName: "Bilinmeyen İlaç",
      medicineBarcode: "",
      dosePiece: 0,
      cabinAssignment: assignment ?? CabinAssignment.empty(cabinId: 0, cabinDrawerId: 0),
    );
  }
}

extension MedicineWithdrawItemExtension on MedicineWithdrawItem {
  // Klinik miktar gösterimi (Örn: "1000 ml" veya "10 Adet")
  // Sayıyı stringe çevirirken eğer .0 ise tam sayı, değilse olduğu gibi gösterir
  String _formatNumber(double value) {
    // Eğer sayı tam sayıya eşitse (örn: 76.0 == 76) küsuratsız yazdır
    return value == value.toInt() ? value.toInt().toString() : value.toString();
  }

  String get totalQuantityLabel {
    final medicine = this.medicine;
    final drug = medicine is Drug ? medicine : null;

    if (drug != null && drug.isMeasureUnit == true) {
      final double doseValue = drug.dose?.toDouble() ?? 1.0;

      final String unit = drug.doseUnit?.name ?? "birim";

      return "${_formatNumber(doseValue)} $unit";
    } else {
      // Ölçü birimi yoksa direkt adet göster (76.0 -> 76 Adet)
      return "${_formatNumber(dosePiece.toDouble())} Adet";
    }
  }
}
