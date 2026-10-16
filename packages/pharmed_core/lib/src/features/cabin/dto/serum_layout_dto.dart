// [SWREQ-CORE-CABIN-SERUM-001] [IEC 62304 §5.5]
// Serum kabini raf/avadanlık DTO'su — istek ve cevap aynı şekildedir.
//   GET  /CabinDrawr/serum/details?cabinDesignId=X → kayıtlı yerleşim
//   POST /CabinDrawr/serum → yeni kayıt (id'ler GÖNDERİLMEZ)
//   PUT  /CabinDrawr/serum → güncelleme (mevcut id'ler gönderilir)
// Sınıf: Class B

/// Serum kabininin (DrawerSlot) rafları ve avadanlıkları.
class SerumLayoutDTO {
  const SerumLayoutDTO({required this.cabinDesignId, required this.shelves});

  /// Serum kabininin DrawerSlot.id'si.
  final int cabinDesignId;

  /// Raflar — kayıtlı/gönderilen yerleşimde 3 adet.
  final List<SerumShelfDTO> shelves;

  factory SerumLayoutDTO.fromJson(Map<String, dynamic> json) => SerumLayoutDTO(
    cabinDesignId: json['cabinDesignId'] as int? ?? 0,
    shelves: (json['cabinDrawrs'] as List? ?? const [])
        .map((e) => SerumShelfDTO.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'cabinDesignId': cabinDesignId,
    'cabinDrawrs': shelves.map((s) => s.toJson()).toList(),
  };
}

/// Tek raf (DrawerUnit / `cabinDrawr`).
class SerumShelfDTO {
  const SerumShelfDTO({
    this.id,
    required this.compartmentNo,
    required this.orderNo,
    required this.toolType,
    required this.trays,
    this.isTakeGiveButtonActive,
  });

  /// Yeni kayıtta null — JSON'a hiç yazılmaz.
  final int? id;
  final int compartmentNo;
  final int orderNo;

  /// SerumShelfLockType.id — 1 kilitli, 2 kilitsiz.
  final int? toolType;
  final List<SerumTrayDTO> trays;

  /// Al-Ver butonu aktif mi.
  final bool? isTakeGiveButtonActive;

  factory SerumShelfDTO.fromJson(Map<String, dynamic> json) => SerumShelfDTO(
    id: json['id'] as int?,
    compartmentNo: json['compartmentNo'] as int? ?? 0,
    orderNo: json['orderNo'] as int? ?? 0,
    toolType: json['toolType'] as int?,
    isTakeGiveButtonActive: json['isTakeGiveButtonActive'] as bool?,
    trays: (json['cabinDrawrDetails'] as List? ?? const [])
        .map((e) => SerumTrayDTO.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'compartmentNo': compartmentNo,
    'orderNo': orderNo,
    'toolType': toolType,
    'isTakeGiveButtonActive': isTakeGiveButtonActive ?? false,
    'cabinDrawrDetails': trays.map((t) => t.toJson()).toList(),
  };
}

/// Tek avadanlık (DrawerCell / `cabinDrawrDetail`).
class SerumTrayDTO {
  const SerumTrayDTO({this.id, required this.stepNo, required this.toolSize});

  /// Yeni kayıtta null — JSON'a hiç yazılmaz.
  final int? id;

  /// Raftaki sıra — sağdan sola 1, 2, 3…
  final int stepNo;

  /// SerumTraySize.id — 1 küçük, 2 orta, 3 büyük.
  final int? toolSize;

  factory SerumTrayDTO.fromJson(Map<String, dynamic> json) => SerumTrayDTO(
    id: json['id'] as int?,
    stepNo: json['stepNo'] as int? ?? 0,
    toolSize: json['toolSize'] as int?,
  );

  Map<String, dynamic> toJson() => {if (id != null) 'id': id, 'stepNo': stepNo, 'toolSize': toolSize};
}
