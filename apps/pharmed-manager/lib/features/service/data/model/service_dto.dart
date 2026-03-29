import 'package:pharmed_manager/core/core.dart';

import '../../../branch/data/model/branch_dto.dart';
import '../../domain/entity/service.dart';

class ServiceDTO {
  final int? id;
  final String? name;
  final int? branchId;
  final BranchDTO? branch;
  final int? userId;
  final UserDTO? user;
  final bool isActive;

  const ServiceDTO({this.id, this.name, this.branchId, this.branch, this.user, this.userId, this.isActive = true});

  factory ServiceDTO.fromJson(Map<String, dynamic> json) {
    return ServiceDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      branchId: json['branchId'] as int?,
      branch: json['branch'] != null ? BranchDTO.fromJson(json['branch']) : null,
      userId: json['userId'] as int?,
      user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
      isActive: (json['isActive'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'branchId': branchId,
    'userId': userId,
    'isActive': isActive,
  };

  HospitalService toEntity() => HospitalService(
    id: id,
    name: name,
    branch: branch?.toEntity(),
    user: const UserMapper().toEntityOrNull(user),
    isActive: isActive,
  );
}
