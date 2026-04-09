class KitDto {
  final int? id;
  final String? name;
  final String? normalizedName;
  final bool? isActive;

  KitDto({this.id, this.name, this.normalizedName, this.isActive});

  factory KitDto.fromJson(Map<String, dynamic> json) {
    return KitDto(
      id: json['id'] as int?,
      name: json['name'] as String?,
      normalizedName: json['normalizedName'] as String?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'normalizedName': normalizedName, 'isActive': isActive};
  }

  KitDto copyWith({int? id, String? name, String? normalizedName, bool? isActive}) {
    return KitDto(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      isActive: isActive ?? this.isActive,
    );
  }
}
