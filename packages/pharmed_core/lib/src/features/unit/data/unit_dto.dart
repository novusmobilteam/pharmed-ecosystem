class UnitDTO {
  final int? id;
  final String? name;
  final bool? isActive;

  UnitDTO({this.id, this.name, this.isActive});

  factory UnitDTO.fromJson(Map<String, dynamic> json) {
    return UnitDTO(id: json['id'] as int?, name: json['name'] as String?, isActive: json['isActive'] as bool?);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }

  UnitDTO copyWith({int? id, String? name, bool? isActive}) {
    return UnitDTO(id: id ?? this.id, name: name ?? this.name, isActive: isActive ?? this.isActive);
  }
}
