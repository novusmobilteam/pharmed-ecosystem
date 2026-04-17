// pharmed_data/src/cabin/dto/patient_assignment_dto.dart
//
// Sınıf: Class B

import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';

class PatientAssignmentDto extends Equatable {
  const PatientAssignmentDto({
    this.id,
    this.cabinId,
    this.cabinDrawrDetailId,
    this.cabinDrawrDetail,
    this.bedId,
    this.bed,
    this.hospitalization,
  });

  final int? id;
  final int? cabinId;
  final int? cabinDrawrDetailId;
  final MobileDrawerCellDto? cabinDrawrDetail;
  final int? bedId;
  final BedDto? bed;
  final HospitalizationDTO? hospitalization;

  factory PatientAssignmentDto.fromJson(Map<String, dynamic> json) {
    return PatientAssignmentDto(
      id: json['id'] as int?,
      cabinId: json['cabinId'] as int?,
      cabinDrawrDetailId: json['cabinDrawrDetailId'] as int?,
      cabinDrawrDetail: json['cabinDrawrDetail'] != null
          ? MobileDrawerCellDto.fromJson(json['cabinDrawrDetail'] as Map<String, dynamic>)
          : null,
      bedId: json['bedId'] as int?,
      bed: json['bed'] != null ? BedDto.fromJson(json['bed'] as Map<String, dynamic>) : null,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDTO.fromJson(json['patientHospitalization'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    //'cabinId': cabinId,
    'cabinDrawrDetailId': cabinDrawrDetailId,
    'bedId': bedId,
  };

  @override
  List<Object?> get props => [id, cabinId, cabinDrawrDetailId, bedId];
}
