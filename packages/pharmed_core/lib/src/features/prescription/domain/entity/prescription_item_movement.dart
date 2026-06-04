import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class PrescriptionItemMovement implements TableData {
  final int id;
  final int? prescriptionItemId;
  final int? cabinDrawerDetailId;
  final PrescriptionMovementType type;
  final DateTime? createdAt;
  final User? performedBy;
  final double? quantity;
  final int? stationId;
  final PrescriptionItem? prescriptionItem;

  const PrescriptionItemMovement({
    required this.id,
    this.prescriptionItemId,
    this.cabinDrawerDetailId,
    required this.type,
    this.createdAt,
    this.performedBy,
    this.quantity,
    this.stationId,
    this.prescriptionItem,
  });

  @override
  List<dynamic> get content => [
    createdAt.formattedDate,
    createdAt.formattedTime,
    prescriptionItem?.prescription?.hospitalization?.patient?.fullName,
    performedBy?.fullName,
    prescriptionItem?.medicine?.name,
    quantity.formatFractional,
    type.actionLabel,
  ];

  @override
  List<dynamic> get rawContent => [
    createdAt.formattedDate,
    createdAt.formattedTime,
    prescriptionItem?.prescription?.hospitalization?.patient?.fullName,
    performedBy?.fullName,
    prescriptionItem?.medicine?.name,
    quantity.formatFractional,
    type.actionLabel,
  ];

  @override
  List<String?> get titles => ['Tarih', 'Saat', 'Hasta', 'Kullanıcı', 'Malzeme', 'Miktar', 'Hareket'];
}
