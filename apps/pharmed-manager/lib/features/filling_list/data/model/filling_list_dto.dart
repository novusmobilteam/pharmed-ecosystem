import '../../../../core/core.dart';
import '../../domain/entity/filling_list.dart';
import '../../../station/data/model/station_dto.dart';

class FillingListDTO {
  final int? id;
  final int? stationId;
  final StationDTO? station;
  final UserDTO? user;
  final String? status;
  final int? statusId;
  final bool isCancel;
  final bool isFilled;
  final DateTime? date;

  const FillingListDTO({
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

  FillingListDTO copyWith({
    int? id,
    int? stationId,
    StationDTO? station,
    UserDTO? user,
    String? status,
    int? statusId,
    bool? isCancel,
    bool? isFilled,
    DateTime? date,
  }) {
    return FillingListDTO(
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

  factory FillingListDTO.fromJson(Map<String, dynamic> json) {
    return FillingListDTO(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
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

  FillingList toEntity() {
    return FillingList(
      id: id,
      station: station?.toEntity(),
      user: const UserMapper().toEntityOrNull(user),
      status: FillingRecordStatus.fromId(statusId),
      isCancel: isCancel,
      isFilled: isFilled,
      date: date,
    );
  }
}
