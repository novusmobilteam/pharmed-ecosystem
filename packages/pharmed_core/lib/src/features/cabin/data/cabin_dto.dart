import 'package:pharmed_core/pharmed_core.dart';

class CabinDTO {
  final int? id;
  final int? stationId;
  final int? no;
  final String? name;
  final bool? isActive;
  final int? type;
  final int? comPortsId;
  final int? baudRatesId;
  final int? paritiesId;
  final int? dataBits;
  final int? stopBits;
  final String? colorHexCode;
  final int? sequenceNo;
  final List<int> cardTypesIds;
  final int? cameraNo;
  final String? dvrIp;
  final StationDTO? station;
  final bool? isRfidEnabled;
  final String? rfidIp;
  final String? rfidPort;
  final List<int>? bedIds;

  const CabinDTO({
    this.id,
    this.stationId,
    this.no,
    this.name,
    this.isActive,
    this.type,
    this.comPortsId,
    this.baudRatesId,
    this.paritiesId,
    this.dataBits,
    this.stopBits,
    this.colorHexCode,
    this.sequenceNo,
    this.cardTypesIds = const [],
    this.cameraNo,
    this.dvrIp,
    this.station,
    this.isRfidEnabled,
    this.rfidIp,
    this.rfidPort,
    this.bedIds,
  });

  CabinDTO copyWith({
    int? id,
    int? stationId,
    int? no,
    String? name,
    bool? isActive,
    int? type,
    int? comPortsId,
    int? baudRatesId,
    int? paritiesId,
    int? dataBits,
    int? stopBits,
    String? colorHexCode,
    int? sequenceNo,
    List<int>? cardTypesIds,
    int? cameraNo,
    String? dvrIp,
    StationDTO? station,
    bool? isRfidEnabled,
    String? rfidIp,
    String? rfidPort,
    List<int>? bedIds,
  }) {
    return CabinDTO(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      no: no ?? this.no,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      comPortsId: comPortsId ?? this.comPortsId,
      baudRatesId: baudRatesId ?? this.baudRatesId,
      paritiesId: paritiesId ?? this.paritiesId,
      dataBits: dataBits ?? this.dataBits,
      stopBits: stopBits ?? this.stopBits,
      colorHexCode: colorHexCode ?? this.colorHexCode,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      cardTypesIds: cardTypesIds ?? this.cardTypesIds,
      cameraNo: cameraNo ?? this.cameraNo,
      dvrIp: dvrIp ?? this.dvrIp,
      station: station ?? this.station,
      isRfidEnabled: isRfidEnabled ?? this.isRfidEnabled,
      rfidIp: rfidIp ?? this.rfidIp,
      rfidPort: rfidPort ?? this.rfidPort,
      bedIds: bedIds ?? this.bedIds,
    );
  }

  factory CabinDTO.fromJson(Map<String, dynamic> json) {
    return CabinDTO(
      id: json['id'],
      stationId: json['stationId'],
      no: json['no'],
      name: json['name'],
      isActive: json['isActive'],
      type: json['type'],
      comPortsId: json['comPortsId'],
      baudRatesId: json['baudRatesId'],
      paritiesId: json['paritiesId'],
      dataBits: json['dataBits'],
      stopBits: json['stopBits'],
      colorHexCode: json['colorHexCode'],
      sequenceNo: json['sequenceNo'],
      cardTypesIds: (json['cardTypesIds'] as List?)?.map((e) => e as int).toList() ?? [],
      cameraNo: json['cameraNo'],
      dvrIp: json['dvrIp'],
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
      isRfidEnabled: json['isRfidEnabled'],
      rfidIp: json['rfidIp'],
      rfidPort: json['rfidPort'],
      bedIds: (json['bedIds'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no': no,
      'name': name,
      'isActive': isActive,
      'type': type,
      'comPortsId': comPortsId,
      'baudRatesId': baudRatesId,
      'paritiesId': paritiesId,
      'dataBits': dataBits,
      'stopBits': stopBits,
      'colorHexCode': colorHexCode,
      'sequenceNo': sequenceNo,
      'cardTypesId': cardTypesIds,
      'cameraNo': cameraNo,
      'dvrIp': dvrIp,
      'stationId': station?.id.toString(),
      'isRfidEnabled': isRfidEnabled,
      'rfidIp': rfidIp,
      'rfidPort': rfidPort,
      'bedIds': bedIds,
    };
  }
}
