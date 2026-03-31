class DosageFormDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const DosageFormDTO({this.id, this.name, this.isActive = true});

  factory DosageFormDTO.fromJson(Map<String, dynamic> json) {
    return DosageFormDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
