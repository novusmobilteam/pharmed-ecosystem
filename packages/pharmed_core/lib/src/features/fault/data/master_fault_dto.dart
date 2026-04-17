class MasterFaultDto {
  final int? id;

  /// DrawerSlot ile birleştiren id.
  final int? cabinDrawrId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final int? workingStatusId;
  final DateTime? createdDate;

  MasterFaultDto({
    this.id,
    this.cabinDrawrId,
    this.startDate,
    this.endDate,
    this.description,
    this.workingStatusId,
    this.createdDate,
  });

  MasterFaultDto copyWith({
    int? id,
    int? cabinDrawrId,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    int? workingStatusId,
    DateTime? createdDate,
  }) {
    return MasterFaultDto(
      id: id,
      cabinDrawrId: cabinDrawrId,
      startDate: startDate,
      endDate: endDate,
      description: description,
      workingStatusId: workingStatusId,
      createdDate: createdDate,
    );
  }

  factory MasterFaultDto.fromJson(Map<String, dynamic> json) {
    return MasterFaultDto(
      id: json['id'] as int?,
      cabinDrawrId: json['cabinDrawrId'] as int?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      description: json['description'] as String?,
      workingStatusId: json['workingStatusId'] as int?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cabinDrawrId': cabinDrawrId,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'workingStatusId': workingStatusId,
    };
  }
}
