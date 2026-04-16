import 'package:pharmed_core/pharmed_core.dart';

class BedDto {
  final int? id;
  final int? roomId;
  final String? name;
  final RoomDto? room;

  const BedDto({this.id, this.name, this.roomId, this.room});

  factory BedDto.fromJson(Map<String, dynamic> json) {
    return BedDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      roomId: json['roomId'] as int?,
      room: json['room'] != null ? RoomDto.fromJson(json['room'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
