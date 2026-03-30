class BranchDTO {
  final int? id;
  final String? name;
  final bool isActive;

  const BranchDTO({this.id, this.name, this.isActive = true});

  factory BranchDTO.fromJson(Map<String, dynamic> json) {
    return BranchDTO(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'isActive': isActive};
  }
}
