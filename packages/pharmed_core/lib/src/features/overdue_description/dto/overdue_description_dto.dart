class OverdueDescriptionDto {
  const OverdueDescriptionDto({this.id, this.description, this.isActive = true});

  final int? id;
  final String? description;
  final bool isActive;

  factory OverdueDescriptionDto.fromJson(Map<String, dynamic> json) {
    return OverdueDescriptionDto(
      id: json['id'] as int?,
      description: json['text'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'text': description};
}
