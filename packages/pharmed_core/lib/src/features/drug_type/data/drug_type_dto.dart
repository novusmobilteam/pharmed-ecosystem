class DrugTypeDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const DrugTypeDTO({this.id, this.name, this.isActive = true});

  factory DrugTypeDTO.fromJson(Map<String, dynamic> json) {
    return DrugTypeDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }

  DrugTypeDTO copyWith({int? id, String? name, bool? isActive}) {
    return DrugTypeDTO(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }
}
