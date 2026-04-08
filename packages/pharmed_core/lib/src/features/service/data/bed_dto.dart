class BedDto {
  final int? id;
  final int? roomId;
  final String? name;

  const BedDto({this.id, this.name, this.roomId});

  factory BedDto.fromJson(Map<String, dynamic> json) {
    return BedDto(id: json['id'] as int?, name: json['name'] as String?, roomId: json['roomId'] as int?);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'roomId': roomId};
}
