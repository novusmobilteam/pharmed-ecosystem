import 'package:pharmed_core/pharmed_core.dart';

class StationTransactionDto {
  final int? id;
  final String? cabinName;
  final int? transactionId;
  final String? transaction;
  final String? code;
  final String? barcode;
  final String? material;
  final DateTime? transactionDate;
  final double? quantity;
  final String? performedBy;
  final String? protocolCode;
  final String? patient;
  final int? order;
  final int? compartment;
  final String? witness;

  /// Hareket öncesi stok miktarı (servis: beforeQuantity).
  final double? beforeQuantity;

  /// Hareket gören kalemin RFID etiket numarası. Servis henüz göndermiyor —
  /// alan adı backend'le netleşince [_rfidTagOf] güncellenmeli.
  final String? rfidTagNo;
  final bool? hasSteps;
  final int? stationId;
  final int? cabinId;

  /// İşlemin operasyon kimliği — kabin işlemi kamera kaydı bu id ile izlenir.
  final int? operationId;

  /// Malzeme detayı (servis `material` alanında Medicine nesnesi döner).
  final MedicineDto? medicine;

  StationTransactionDto({
    this.id,
    this.cabinName,
    this.transactionId,
    this.transaction,
    this.code,
    this.barcode,
    this.material,
    this.transactionDate,
    this.quantity,
    this.performedBy,
    this.protocolCode,
    this.patient,
    this.order,
    this.compartment,
    this.witness,
    this.beforeQuantity,
    this.rfidTagNo,
    this.hasSteps,
    this.stationId,
    this.cabinId,
    this.operationId,
    this.medicine,
  });

  factory StationTransactionDto.fromJson(Map<String, dynamic> json) {
    return StationTransactionDto(
      id: json['id'] as int?,
      cabinName: json['cabinName'] as String?,
      transactionId: json['transactionId'] as int?,
      transaction: json['transaction'] as String?,
      code: json['code'] as String?,
      barcode: json['barcode'] as String?,
      // Eski yanıtlarda `material` düz isimdi; yenilerde Medicine nesnesi.
      material: json['material'] is String ? json['material'] as String : null,
      medicine: json['material'] is Map<String, dynamic>
          ? MedicineDto.fromJson(json['material'] as Map<String, dynamic>)
          : null,
      transactionDate: json['transactionDate'] != null ? DateTime.tryParse(json['transactionDate'].toString()) : null,
      quantity: (json['quantity'] as num?)?.toDouble(),
      performedBy: json['userName'] as String?,
      // Servis alanı 'hospitalProtocolCode'; eski ad da desteklenir.
      protocolCode: (json['hospitalProtocolCode'] ?? json['protocolCode']) as String?,
      patient: json['patient'] as String?,
      order: json['order'] as int?,
      compartment: json['compartment'] as int?,
      witness: _witnessOf(json),
      beforeQuantity: (json['beforeQuantity'] as num?)?.toDouble(),
      rfidTagNo: _rfidTagOf(json),
      hasSteps: json['hasSteps'] as bool?,
      stationId: json['stationId'] as int?,
      cabinId: json['cabinId'] as int?,
      operationId: json['operationId'] as int?,
    );
  }

  /// Şahit: servis 'witnessUser' gönderiyor — ad (String) ya da kullanıcı
  /// nesnesi ({name, surname}) olabilir. Eski 'witness' alanı da desteklenir.
  static String? _witnessOf(Map<String, dynamic> json) {
    final value = json['witnessUser'] ?? json['witness'];
    if (value is String) return value.trim().isEmpty ? null : value;
    if (value is Map<String, dynamic>) {
      final fullName = [value['name'], value['surname']].whereType<String>().join(' ').trim();
      return fullName.isEmpty ? null : fullName;
    }
    return null;
  }

  /// RFID etiket no — olası alan adları sırayla denenir.
  static String? _rfidTagOf(Map<String, dynamic> json) {
    final value = json['rfidTagNo'] ?? json['rfidTag'] ?? json['epc'];
    return value?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (cabinName != null) 'cabinName': cabinName,
      if (transaction != null) 'transaction': transaction,
      if (code != null) 'code': code,
      if (barcode != null) 'barcode': barcode,
      if (material != null) 'material': material,
      if (transactionDate != null) 'transactionDate': transactionDate!.toIso8601String(),
      if (quantity != null) 'quantity': quantity,
      if (performedBy != null) 'performedBy': performedBy,
      if (protocolCode != null) 'protocolCode': protocolCode,
      if (patient != null) 'patient': patient,
      if (order != null) 'order': order,
      if (compartment != null) 'compartment': compartment,
      if (witness != null) 'witness': witness,
      if (beforeQuantity != null) 'beforeQuantity': beforeQuantity,
      if (rfidTagNo != null) 'rfidTagNo': rfidTagNo,
      if (hasSteps != null) 'hasSteps': hasSteps,
      if (stationId != null) 'stationId': stationId,
      if (cabinId != null) 'cabinId': cabinId,
      if (operationId != null) 'operationId': operationId,
    };
  }
}
