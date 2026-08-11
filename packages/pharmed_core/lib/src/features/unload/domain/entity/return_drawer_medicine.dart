// packages/pharmed_core/lib/src/unload/entity/return_drawer_medicine.dart

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

class ReturnDrawerMedicine extends Equatable {
  const ReturnDrawerMedicine({
    this.id,
    this.prescriptionItemId,
    this.prescriptionItem,
    this.materialId,
    this.material,
    this.quantity,
    this.returnUserId,
    this.returnUser,
    this.returnDate,
  });

  final int? id;
  final int? prescriptionItemId;
  final PrescriptionItem? prescriptionItem;
  final int? materialId;
  final Medicine? material;
  final double? quantity;
  final int? returnUserId;
  final User? returnUser;
  final DateTime? returnDate;

  @override
  List<Object?> get props => [
    id,
    prescriptionItemId,
    prescriptionItem,
    materialId,
    material,
    quantity,
    returnUserId,
    returnUser,
    returnDate,
  ];
}
