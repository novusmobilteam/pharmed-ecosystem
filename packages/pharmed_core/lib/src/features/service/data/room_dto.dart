import 'package:pharmed_core/pharmed_core.dart';

class RoomDto {
  final int? id;
  final int? serviceId;
  final String? name;
  final List<BedDto>? beds;

  const RoomDto({this.id, this.name, this.serviceId, this.beds});

  factory RoomDto.fromJson(Map<String, dynamic> json) {
    return RoomDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      serviceId: json['serviceId'] as int?,
      beds: json['beds'] != null
          ? (json['beds'] as List).map((e) => BedDto.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    // 'serviceId': serviceId,
    'bedModels': beds?.map((b) => b.toJson()).toList(),
  };
}
