class StationTransactionStepDto {
  final int? id;
  final int? cabinDrawrDetailId;
  final int? stepNo;
  final double? quantity;

  StationTransactionStepDto({this.id, this.cabinDrawrDetailId, this.stepNo, this.quantity});

  factory StationTransactionStepDto.fromJson(Map<String, dynamic> json) {
    return StationTransactionStepDto(
      id: json['id'] as int?,
      cabinDrawrDetailId: json['cabinDrawrDetailId'] as int?,
      stepNo: json['stepNo'] as int?,
      quantity: (json['quantity'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (cabinDrawrDetailId != null) 'cabinDrawrDetailId': cabinDrawrDetailId,
      if (stepNo != null) 'stepNo': stepNo,
      if (quantity != null) 'quantity': quantity,
    };
  }
}
