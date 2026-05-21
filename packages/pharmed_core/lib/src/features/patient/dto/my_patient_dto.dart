import 'package:pharmed_core/pharmed_core.dart';

class MyPatientDTO {
  final int? id;
  final int? userId;
  final UserDto? user;
  final HospitalizationDto? hospitalization;

  MyPatientDTO({this.id, this.userId, this.user, this.hospitalization});

  factory MyPatientDTO.fromJson(Map<String, dynamic> json) {
    return MyPatientDTO(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDto.fromJson(json['patientHospitalization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'user': user?.toJson(), 'hospitalization': hospitalization?.toJson()};
  }

  MyPatientDTO copyWith({int? id, int? userId, UserDto? user, HospitalizationDto? hospitalization}) {
    return MyPatientDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      hospitalization: hospitalization ?? this.hospitalization,
    );
  }
}
