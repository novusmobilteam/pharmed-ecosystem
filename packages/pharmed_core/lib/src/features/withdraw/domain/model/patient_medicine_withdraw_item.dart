// İlaç alım işleminde hastanın kendi getirmiş olduğu ve sisteme sonradan tanımlanan ilaçlar
// için kullanılan model.
import 'package:pharmed_core/pharmed_core.dart';

class PatientMedicineWithdrawItem {
  final int id;
  final int hospitalizationId;
  final int patientId;
  final int compartmentNo;
  final String medicineName;
  final String barcode;
  final DateTime time;
  final int dosePiece;
  final String description;
  final DateTime? applicationDate;
  final User? applicationUser;

  final CabinAssignment assignment;

  PatientMedicineWithdrawItem({
    required this.id,
    required this.hospitalizationId,
    required this.patientId,
    required this.compartmentNo,
    required this.medicineName,
    required this.barcode,
    required this.time,
    required this.description,
    required this.dosePiece,
    required this.assignment,
    this.applicationDate,
    this.applicationUser,
  });
}

extension MedicineWithdrawMapper on PatientMedicineWithdrawItemDTO {
  /// KRİTİK NOKTA: DrawerStatusNotifier'ın beklediği nesneyi manuel oluşturuyoruz.
}
