import 'package:pharmed_manager/core/core.dart';

class ServiceDTO {
  final int? id;
  final String? name;
  final int? branchId;
  final BranchDTO? branch;
  final int? userId;
  final UserDTO? user;
  final bool isActive;
  final List<RoomDto>? rooms;

  const ServiceDTO({
    this.id,
    this.name,
    this.branchId,
    this.branch,
    this.user,
    this.userId,
    this.isActive = true,
    this.rooms,
  });

  factory ServiceDTO.fromJson(Map<String, dynamic> json) {
    return ServiceDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      branchId: json['branchId'] as int?,
      branch: json['branch'] != null ? BranchDTO.fromJson(json['branch']) : null,
      userId: json['userId'] as int?,
      user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
      isActive: (json['isActive'] as bool?) ?? false,
      rooms: json['rooms'] != null
          ? (json['rooms'] as List).map((e) => RoomDto.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'branchId': branchId,
    'userId': userId,
    'isActive': isActive,
    'roomModels': rooms?.map((r) => r.toJson()).toList(),
  };
}
