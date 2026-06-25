class PrescriptionTemplateDto {
  final int? id;
  final String? name;
  final int? createdUserId;
  final DateTime? createdDate;

  PrescriptionTemplateDto({this.id, this.name, this.createdUserId, this.createdDate});

  factory PrescriptionTemplateDto.fromJson(Map<String, dynamic> json) {
    return PrescriptionTemplateDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      createdUserId: json['userId'] as int?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  PrescriptionTemplateDto copyWith({int? id, String? name, int? createdUserId, DateTime? createdDate}) {
    return PrescriptionTemplateDto(
      id: id ?? this.id,
      name: name ?? this.name,
      createdUserId: createdUserId ?? this.createdUserId,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
