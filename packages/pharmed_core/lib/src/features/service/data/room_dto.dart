class RoomDto {
  final int? id;
  final int? serviceId;
  final String? name;

  const RoomDto({this.id, this.name, this.serviceId});

  factory RoomDto.fromJson(Map<String, dynamic> json) {
    return RoomDto(id: json['id'] as int?, name: json['name'] as String?, serviceId: json['serviceId'] as int?);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'serviceId': serviceId};
}
