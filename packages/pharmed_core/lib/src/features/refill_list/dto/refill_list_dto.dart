import 'package:pharmed_core/pharmed_core.dart';

class RefillListDto {
  final int? id;
  final int? stationId;
  final StationDTO? station;
  final UserDto? user;
  final String? status;
  final int? statusId;
  final bool isCancel;
  final bool isFilled;
  final DateTime? date;

  const RefillListDto({
    this.id,
    this.stationId,
    this.station,
    this.user,
    this.status,
    this.statusId,
    this.isCancel = false,
    this.isFilled = false,
    this.date,
  });

  RefillListDto copyWith({
    int? id,
    int? stationId,
    StationDTO? station,
    UserDto? user,
    String? status,
    int? statusId,
    bool? isCancel,
    bool? isFilled,
    DateTime? date,
  }) {
    return RefillListDto(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      station: station ?? this.station,
      user: user ?? this.user,
      status: status ?? this.status,
      statusId: statusId ?? this.statusId,
      isCancel: isCancel ?? this.isCancel,
      isFilled: isFilled ?? this.isFilled,
      date: date ?? this.date,
    );
  }

  factory RefillListDto.fromJson(Map<String, dynamic> json) {
    return RefillListDto(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      status: json['status'] as String?,
      statusId: json['statusId'] as int?,
      isCancel: (json['isCancel'] as bool?) ?? false,
      isFilled: (json['isFilled'] as bool?) ?? false,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      //'id': id,
      'stationId': stationId,
      'station': station,
      'user': user,
      'status': status,
      'statusId': statusId,
      'isCancel': isCancel,
      'isFilled': isFilled,
      'date': date?.toIso8601String(),
    };
  }
}
