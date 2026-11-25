// [SWREQ-SETUP-RESTORE-001] [IEC 62304 §5.5]
// `GET /Station/byMac/{macAddress}` yanıtı: MAC'e kayıtlı istasyon ve ona bağlı
// kabinler (master + slave). Sözleşme: "PharMed İstasyon Kurulum Geri Yükleme —
// Backend API Sözleşmesi".
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

class StationInstallationDTO {
  const StationInstallationDTO({this.station, this.cabins = const [], this.cabinHasDesign = const {}});

  final StationDTO? station;
  final List<CabinDTO> cabins;

  /// Kabin ID → kayıtlı çekmece tasarımı var mı. Alan gelmezse kabin listede
  /// yer almaz ve tasarımı var kabul edilir.
  final Map<int, bool> cabinHasDesign;

  factory StationInstallationDTO.fromJson(Map<String, dynamic> json) {
    final stationJson = json['station'];
    final cabinsJson = json['cabins'];

    final cabins = <CabinDTO>[];
    final hasDesign = <int, bool>{};

    if (cabinsJson is List) {
      for (final raw in cabinsJson.whereType<Map<String, dynamic>>()) {
        final dto = CabinDTO.fromJson(_normalizeCabinJson(raw));
        cabins.add(dto);
        final id = dto.id;
        final design = raw['hasDesign'];
        if (id != null && design is bool) hasDesign[id] = design;
      }
    }

    return StationInstallationDTO(
      station: stationJson is Map<String, dynamic> ? StationDTO.fromJson(stationJson) : null,
      cabins: cabins,
      cabinHasDesign: hasDesign,
    );
  }

  /// Sözleşmedeki alan adlarını (`comPortId`, `status`, metin `type`) mevcut
  /// [CabinDTO] alan adlarına (`comPortsId`, `isActive`, sayısal `type`)
  /// çevirir. Backend `Cabin` DTO'sunun kendi adlarıyla dönerse onlar aynen
  /// kullanılır.
  static Map<String, dynamic> _normalizeCabinJson(Map<String, dynamic> raw) {
    final json = Map<String, dynamic>.of(raw);

    json['comPortsId'] ??= json['comPortId'];
    json['baudRatesId'] ??= json['baudRateId'];
    json['paritiesId'] ??= json['parityId'];

    if (json['isActive'] == null && json['status'] is String) {
      json['isActive'] = (json['status'] as String).toLowerCase() != 'passive';
    }

    final type = json['type'];
    if (type is String) {
      final match = CabinType.values.where((t) => t.name.toLowerCase() == type.toLowerCase()).firstOrNull;
      json['type'] = match?.id ?? int.tryParse(type);
    }

    final rfidPort = json['rfidPort'];
    if (rfidPort is num) json['rfidPort'] = rfidPort.toString();

    return json;
  }
}
