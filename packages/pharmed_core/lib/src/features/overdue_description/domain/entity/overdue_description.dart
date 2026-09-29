class OverdueDescription {
  const OverdueDescription({this.id, this.description, this.isActive = true});

  final int? id;
  final String? description;
  final bool isActive;

  factory OverdueDescription.fromJson(Map<String, dynamic> json) {
    return OverdueDescription(
      id: json['id'] as int?,
      description: json['text'] as String?,
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'description': description};
}
