import 'package:pharmed_core/pharmed_core.dart';

class MyPatientDTO {
  final int? id;
  final int? userId;
  final UserDTO? user;
  final HospitalizationDTO? hospitalization;

  MyPatientDTO({this.id, this.userId, this.user, this.hospitalization});

  factory MyPatientDTO.fromJson(Map<String, dynamic> json) {
    return MyPatientDTO(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      user: json['user'] != null ? UserDTO.fromJson(json['user']) : null,
      hospitalization: json['patientHospitalization'] != null
          ? HospitalizationDTO.fromJson(json['patientHospitalization'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'userId': userId, 'user': user?.toJson(), 'hospitalization': hospitalization?.toJson()};
  }

  MyPatientDTO copyWith({int? id, int? userId, UserDTO? user, HospitalizationDTO? hospitalization}) {
    return MyPatientDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      hospitalization: hospitalization ?? this.hospitalization,
    );
  }
}
