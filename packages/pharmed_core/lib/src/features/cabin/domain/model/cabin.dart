import 'package:pharmed_core/pharmed_core.dart';

class Cabin extends Selectable implements TableData {
  final int? stationId;
  final int? no;
  final String? name;
  final int? sequenceNo;
  final int? cameraNo;
  final String? dvrIp;
  final ComPort? comPort;
  final BaudRate? baudRate;
  final Status? status;
  final CabinType? type;
  //final List<CabinCardType> cardTypes;
  final StopBit? stopBit;
  final DataBit? dataBit;
  final ParityBit? parityBit;
  final CabinColor? color;
  final Station? station;

  static Cabin? fromIdAndName({int? id, String? name, int? comPortId, int? baudRateId, int? parityId}) {
    final hasId = id != null;
    final hasName = name != null && name.trim().isNotEmpty;
    if (!hasId && !hasName) return null;

    return Cabin(
      id: id,
      name: name,
      comPort: ComPort.fromId(comPortId),
      baudRate: BaudRate.fromId(baudRateId),
      parityBit: ParityBit.fromId(parityId),
    );
  }

  Cabin({
    super.id,
    this.stationId,
    this.no,
    this.name,
    this.comPort,
    this.baudRate,
    this.status,
    this.type,
    this.color,
    this.sequenceNo,
    //this.cardTypes = const [],
    this.cameraNo,
    this.dvrIp,
    this.stopBit,
    this.dataBit,
    this.parityBit,
    this.station,
  }) : super(title: name.toString(), subtitle: no?.toString());

  Cabin copyWith({
    int? id,
    int? stationId,
    int? no,
    String? name,
    Status? status,
    CabinType? type,
    ComPort? comPort,
    BaudRate? baudRate,
    StopBit? stopBit,
    ParityBit? parityBit,
    DataBit? dataBit,
    CabinColor? color,
    int? sequenceNo,
    //List<CabinCardType>? cardTypes,
    int? cameraNo,
    String? dvrIp,
    Station? station,
  }) {
    return Cabin(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      no: no ?? this.no,
      name: name ?? this.name,
      status: status ?? this.status,
      type: type ?? this.type,
      comPort: comPort ?? this.comPort,
      baudRate: baudRate ?? this.baudRate,
      stopBit: stopBit ?? this.stopBit,
      parityBit: parityBit ?? this.parityBit,
      dataBit: dataBit ?? this.dataBit,
      color: color ?? this.color,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      //cardTypes: cardTypes ?? this.cardTypes,
      cameraNo: cameraNo ?? this.cameraNo,
      dvrIp: dvrIp ?? this.dvrIp,
      station: station ?? this.station,
    );
  }

  @override
  List get content => [name, type?.label, no?.toString()];

  @override
  List<String?> get titles => ['Kabin Adı', 'Kabin Tipi', 'Kabin No'];

  @override
  List get rawContent => [name, type?.label, no];
}
