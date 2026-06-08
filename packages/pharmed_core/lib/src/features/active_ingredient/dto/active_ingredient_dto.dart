class ActiveIngredientDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const ActiveIngredientDTO({this.id, this.name, this.isActive = true});

  factory ActiveIngredientDTO.fromJson(Map<String, dynamic> json) {
    return ActiveIngredientDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
