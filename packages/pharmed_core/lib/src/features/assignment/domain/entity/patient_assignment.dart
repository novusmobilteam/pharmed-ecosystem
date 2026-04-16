// pharmed_core/src/cabin/entity/patient_assignment.dart
//
// [SWREQ-CABIN-UC-XXX]
// Mobil kabin göz → hasta yatış ataması.
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class PatientAssignment {
  const PatientAssignment({this.id, this.cabinId, this.cellId, this.cell, this.bedId, this.bed, this.hospitalization});

  final int? id;
  final int? cabinId;
  final int? cellId;
  final MobileDrawerCell? cell;
  final int? bedId;
  final Bed? bed;
  final Hospitalization? hospitalization;

  PatientAssignment copyWith({
    int? id,
    int? cabinId,
    int? cabinDrawrDetailId,
    MobileDrawerCell? cabinDrawrDetail,
    int? bedId,
    Bed? bed,
    Hospitalization? hospitalization,
  }) {
    return PatientAssignment(
      id: id ?? this.id,
      cabinId: cabinId ?? this.cabinId,
      cellId: cabinDrawrDetailId ?? this.cellId,
      cell: cabinDrawrDetail ?? this.cell,
      bedId: bedId ?? this.bedId,
      bed: bed ?? this.bed,
      hospitalization: hospitalization ?? this.hospitalization,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is PatientAssignment && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PatientAssignment(id: $id, cabinDrawrDetailId: $cellId, bedId: $bedId)';
}
