// pharmed_data/src/assignment/mapper/patient_assignment_mapper.dart
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

class PatientAssignmentMapper {
  const PatientAssignmentMapper({
    this.bedMapper = const BedMapper(),
    this.hospitalizationMapper = const HospitalizationMapper(),
  });

  final BedMapper bedMapper;
  final HospitalizationMapper hospitalizationMapper;

  PatientAssignment toEntity(PatientAssignmentDto dto) {
    return PatientAssignment(
      id: dto.id,
      cabinId: dto.cabinId,
      cellId: dto.cabinDrawrDetailId,
      cell: dto.cabinDrawrDetail != null ? _cellToEntity(dto.cabinDrawrDetail!) : null,
      bedId: dto.bedId,
      bed: bedMapper.toEntityOrNull(dto.bed),
      hospitalization: hospitalizationMapper.toEntityOrNull(dto.hospitalization),
    );
  }

  PatientAssignment? toEntityOrNull(PatientAssignmentDto? dto) => dto == null ? null : toEntity(dto);

  List<PatientAssignment> toEntityList(List<PatientAssignmentDto> dtos) => dtos.map(toEntity).toList();

  MobileDrawerCell _cellToEntity(MobileDrawerCellDto dto) {
    return MobileDrawerCell(id: dto.id, unitId: dto.cabinDrawrId, stepNo: dto.stepNo);
  }
}
