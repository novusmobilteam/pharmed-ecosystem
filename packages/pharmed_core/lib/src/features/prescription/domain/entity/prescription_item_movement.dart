import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionItemMovement {
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
}
