import 'package:pharmed_core/pharmed_core.dart';

class PrescriptionItemMovement {
  final int id;
  final int prescriptionItemId;
  final int? cabinDrawerDetailId;
  final PrescriptionMovementType type;
  final DateTime createdAt;
  final User? performedBy;
  final double? quantity;
  final int? stationId;

  const PrescriptionItemMovement({
    required this.id,
    required this.prescriptionItemId,
    this.cabinDrawerDetailId,
    required this.type,
    required this.createdAt,
    this.performedBy,
    this.quantity,
    this.stationId,
  });
}
