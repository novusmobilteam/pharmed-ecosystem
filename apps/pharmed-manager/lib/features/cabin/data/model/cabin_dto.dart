import '../../../../core/core.dart';
import '../../../station/data/model/station_dto.dart';
import '../../domain/entity/cabin.dart';

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
    );
  }

  factory CabinDTO.fromJson(Map<String, dynamic> json) {
    return CabinDTO(
      id: json['id'] as int?,
      stationId: json['stationId'] as int?,
      no: json['no'] as int?,
      name: json['name'] as String?,
      isActive: json['isActive'] as bool?,
      type: json['type'] as int?,
      comPortsId: json['comPortsId'] as int?,
      baudRatesId: json['baudRatesId'] as int?,
      paritiesId: json['paritiesId'] as int?,
      dataBits: json['dataBits'] as int?,
      stopBits: json['stopBits'] as int?,
      colorHexCode: json['colorHexCode'] as String?,
      sequenceNo: json['sequenceNo'] as int?,
      cardTypesIds: (json['cardTypesIds'] as List?)?.map((e) => e as int).toList() ?? [],
      cameraNo: json['cameraNo'] as int?,
      dvrIp: json['dvrIp'] as String?,
      station: json['station'] != null ? StationDTO.fromJson(json['station']) : null,
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
    };
  }

  Cabin toEntity() {
    return Cabin(
      id: id,
      stationId: stationId,
      no: no,
      name: name,
      status: statusFromBool(isActive ?? false),
      type: CabinType.fromId(type),
      comPort: ComPort.fromId(comPortsId),
      baudRate: BaudRate.fromId(baudRatesId),
      parityBit: ParityBit.fromId(paritiesId),
      dataBit: DataBit.fromId(dataBits),
      stopBit: StopBit.fromId(stopBits),
      color: CabinColor.fromHex(colorHexCode),
      sequenceNo: sequenceNo,
      //cardTypes: cardTypesIds.map((c) => CabinCardType.fromId(c)).whereType<CabinCardType>().toList(),
      cameraNo: cameraNo,
      dvrIp: dvrIp,
      station: station?.toEntity(),
    );
  }
}
