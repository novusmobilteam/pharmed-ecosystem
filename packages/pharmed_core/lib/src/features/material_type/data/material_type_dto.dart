class MaterialTypeDTO {
  final int? id;
  final String? name;
  final bool isActive;

  MaterialTypeDTO({this.id, this.name, this.isActive = true});

  factory MaterialTypeDTO.fromJson(Map<String, dynamic> json) {
    return MaterialTypeDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
