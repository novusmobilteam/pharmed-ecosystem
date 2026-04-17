class MobileFaultDto {
  const MobileFaultDto({
    this.id,
    this.cabinDesignId,
    this.startDate,
    this.endDate,
    this.description,
    this.workingStatusId,
    this.createdDate,
  });

  final int? id;
  final int? cabinDesignId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? description;
  final int? workingStatusId;
  final DateTime? createdDate;

  factory MobileFaultDto.fromJson(Map<String, dynamic> json) {
    return MobileFaultDto(
      id: json['id'] as int?,
      cabinDesignId: json['cabinDesignId'] as int?,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      description: json['description'] as String?,
      workingStatusId: json['workingStatusId'] as int?,
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'cabinDesignId': cabinDesignId,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'description': description,
    'workingStatusId': workingStatusId,
  };
}
