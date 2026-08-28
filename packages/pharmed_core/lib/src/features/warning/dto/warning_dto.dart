class WarningDto {
  final int? id;
  final int? warningSubjectId;
  final String? text;
  final bool isActive;
  final DateTime? createdDate;

  const WarningDto({this.id, this.warningSubjectId, this.text, this.isActive = true, this.createdDate});

  factory WarningDto.fromJson(Map<String, dynamic> json) => WarningDto(
    id: json['id'] as int?,
    warningSubjectId: json['warningSubjectId'] as int?,
    text: json['text'] as String?,
    isActive: (json['isActive'] as bool?) ?? false,
    createdDate: json['createdDate'] != null ? DateTime.tryParse(json['createdDate']) : null,
  );

  Map<String, dynamic> toJson() => {'id': id, 'warningSubjectId': warningSubjectId, 'text': text, 'isActive': isActive};
}
