class PrescriptionTemplate {
  final int? id;
  final String? name;
  final int? createdUserId;
  final DateTime? createdDate;

  PrescriptionTemplate({this.id, this.name, this.createdUserId, this.createdDate});

  PrescriptionTemplate copyWith({int? id, String? name, int? createdUserId, DateTime? createdDate}) {
    return PrescriptionTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      createdUserId: createdUserId ?? this.createdUserId,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
