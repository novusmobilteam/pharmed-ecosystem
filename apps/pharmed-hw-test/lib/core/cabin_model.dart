// Test uygulamasının kabin modeli: client cache'inden okunan tanım ile
// fiziksel taramanın sonucu AYNI yapıda tutulur, böylece ekran, rapor ve
// karşılaştırma tek modelle çalışır.
//
// Sınıflandırma client ile aynı kuralı izler (#195):
//   • Adres A → master kabin. Bir satırında serum kartı (.250) olabilir;
//     o zaman master'da tek bir serum bölmesi vardır.
//   • A dışındaki adreste serum kartı satır 26'da master gibi davranır:
//       – başka satırlarda çekmece varsa → serum kartına bağlı kabin
//         (satır 26 kabinin kartıdır, çekmece sayılmaz)
//       – yoksa → serum kabini (kapak sayısı karttan okunamaz, tanımlanır)
//
// Bu dosya yalnızca bellekte yaşar; hiçbir şey client cache'ine yazılmaz.

import 'package:pharmed_core/pharmed_core.dart';

/// Tanımın nereden geldiği.
enum CabinSource {
  clientCache('Client tanımı'),
  scan('Tarama');

  const CabinSource(this.label);

  final String label;
}

enum CabinKind {
  master('Master kabin'),
  serumBound('Serum kartına bağlı kabin'),
  serumCabinet('Serum kabini'),
  mobile('Mobil kabin'),
  noSerumCard('Ek kabin — serum kartı yok');

  const CabinKind(this.label);

  final String label;
}

enum UnitKind {
  kubik('Kübik'),
  unitDose('Birim doz'),
  serum('Serum'),
  mobile('Mobil çekmece'),
  unknown('Tanımsız');

  const UnitKind(this.label);

  final String label;
}

/// Bir kabindeki test edilebilir birim: çekmece, serum bölmesi / kapağı ya da
/// mobil çekmece.
class CabinUnit {
  const CabinUnit({
    required this.row,
    required this.kind,
    required this.name,
    this.compartmentCount,
    this.typeNo,
    this.rawResponse,
    this.lidNo,
    this.port,
    this.problem,
    this.slotId,
    this.config,
    this.cells = const [],
  });

  /// Kart satırı (01–26). Serum kabini kapakları ve mobil çekmeceler satır 26'dadır.
  final int row;
  final UnitKind kind;

  /// Ekranda görünen anlamlı ad ("Kübik 4×4", "Serum kapağı 2" …).
  final String name;

  /// Göz sayısı (kübik / birim doz).
  final int? compartmentCount;

  /// Kartın bildirdiği tip numarası (taramada).
  final int? typeNo;

  /// Kartın ham tip cevabı (taramada) — ayrıntıda gösterilir.
  final String? rawResponse;

  /// Serum kabini kapak numarası (1–4) = port.
  final int? lidNo;

  /// Mobil çekmece portu.
  final int? port;

  /// Tanım eşleşmesinde sorun (ör. tip numarası hiçbir tanımla eşleşmedi).
  final String? problem;

  /// Client tanımındaki çekmece kaydı (DrawerSlot.id). Serum raf yerleşimi
  /// servisten bu numarayla (salt okunur) çekilir. Taramada null.
  final int? slotId;

  /// Çekmece tanımı (adım sayısı, çarpan, tip). Açma adresi client'taki
  /// `calculateAddressFromAssignment` ile bundan hesaplanır.
  final DrawerConfig? config;

  /// Gözler (DrawerUnit). Client tanımında backend kayıtları (kübikte kapak
  /// adresi: port = compartmentNo, sıra = orderNo); taramada birim doz için
  /// client taramasıyla aynı şekilde üretilir, kübikte boştur (kapaklar
  /// test sırasında karttan yoklanır).
  final List<DrawerUnit> cells;

  String get rowLabel => row.toString().padLeft(2, '0');

  /// "Satır 03" / "Kapak 2 · port 2" / "Port 4".
  String get locationLabel {
    if (lidNo != null) return 'Kapak $lidNo · port $lidNo';
    if (port != null) return 'Port $port';
    return 'Satır $rowLabel';
  }

  /// Tanım ile tarama karşılaştırmasında aynı birimi bulmak için anahtar.
  String get matchKey => lidNo != null ? 'lid$lidNo' : (port != null ? 'port$port' : 'row$row');
}

class CabinInfo {
  const CabinInfo({
    required this.addressIndex,
    required this.kind,
    required this.units,
    this.name,
    this.needsLidCount = false,
    this.warnings = const [],
  });

  /// Yönetim kartı adresi (1–16 → a–p).
  final int addressIndex;
  final CabinKind kind;
  final List<CabinUnit> units;

  /// Client tanımındaki kabin adı.
  final String? name;

  /// Serum kabininde kapak sayısı henüz tanımlanmadı (karttan okunamaz).
  final bool needsLidCount;

  /// Kabin düzeyindeki uyarılar (ör. eşleşmeyen kart).
  final List<String> warnings;

  String get letter => ManagementCard(addressIndex: addressIndex).addressChar.toUpperCase();

  /// "A · Master kabin" gibi başlık.
  String get title => '$letter · ${kind.label}';

  bool get hasProblems => warnings.isNotEmpty || units.any((u) => u.problem != null);
}

class CabinSnapshot {
  CabinSnapshot({required this.source, required this.cabins, DateTime? time}) : time = time ?? DateTime.now();

  final CabinSource source;
  final List<CabinInfo> cabins;
  final DateTime time;

  /// "2 kabin · 9 çekmece · 1 serum kapağı" gibi kısa özet.
  String get summary {
    final drawers = cabins.expand((c) => c.units).where((u) => u.kind != UnitKind.serum).length;
    final serum = cabins.expand((c) => c.units).where((u) => u.kind == UnitKind.serum).length;
    return [
      '${cabins.length} kabin',
      if (drawers > 0) '$drawers çekmece',
      if (serum > 0) '$serum serum bölmesi/kapağı',
    ].join(' · ');
  }

  /// Rapor için düz metin.
  List<String> describe() => [
    for (final c in cabins) ...[
      '${c.title}${c.name != null ? ' (${c.name})' : ''}',
      if (c.needsLidCount) '  Kapak sayısı tanımlanmalı (karttan okunamaz)',
      for (final w in c.warnings) '  UYARI: $w',
      for (final u in c.units)
        '  ${u.locationLabel}  ${u.name}'
            '${u.compartmentCount != null && u.kind != UnitKind.serum ? ' (${u.compartmentCount} göz)' : ''}'
            '${u.rawResponse != null ? '  ham ${u.rawResponse}' : ''}'
            '${u.problem != null ? '  [${u.problem}]' : ''}',
    ],
  ];
}

// ── Adlandırma ve sınıflandırma (cache ve tarama ortak) ────────────────

abstract final class CabinRules {
  static const int serumTypeNo = 250;

  /// Servisteki çekmece tipinden anlamlı ad. Servis adı varsa o kullanılır
  /// ("Kübik 4×4", "Birim Doz 3 Göz"); yoksa tipten türetilir.
  static String drawerName(DrawerType? type) {
    final name = type?.name?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (type == null) return 'Tanımsız çekmece';
    final n = type.compartmentCount;
    if (type.isMobileDrawer) return 'Mobil çekmece';
    if (type.isKubik) return n != null && n % 4 == 0 ? 'Kübik 4×${n ~/ 4}' : 'Kübik çekmece';
    return n != null ? 'Birim doz $n göz' : 'Birim doz çekmece';
  }

  static UnitKind drawerKind(DrawerType? type) {
    if (type == null) return UnitKind.unknown;
    if (type.isMobileDrawer) return UnitKind.mobile;
    return type.isKubik ? UnitKind.kubik : UnitKind.unitDose;
  }

  /// Serum birimi: kabin kartı satırı (26) + A dışı adres → kapak; aksi halde
  /// master içindeki tek serum bölmesi.
  static CabinUnit serumUnit({required int row, int? lidNo, String? rawResponse, int? slotId}) => CabinUnit(
    row: row,
    kind: UnitKind.serum,
    name: lidNo != null ? 'Serum kapağı $lidNo' : 'Serum bölmesi',
    typeNo: serumTypeNo,
    lidNo: lidNo,
    rawResponse: rawResponse,
    slotId: slotId,
  );

  static bool _isCabinSerumCard(CabinUnit u) => u.kind == UnitKind.serum && u.row == DeviceConstants.serumSlaveRow;

  /// Kart dizilişinden kabin sınıfı. [units] satır 26'daki serum kartını
  /// içerebilir; dönen listede kabinin kendi kartı çekmece olarak yer almaz.
  static (CabinKind, List<CabinUnit>) classify({required int addressIndex, required List<CabinUnit> units}) {
    if (addressIndex == 1) return (CabinKind.master, units);
    final hasCabinSerumCard = units.any(_isCabinSerumCard);
    if (!hasCabinSerumCard) return (CabinKind.noSerumCard, units);
    final others = units.where((u) => !_isCabinSerumCard(u)).toList();
    if (others.isEmpty) return (CabinKind.serumCabinet, units);
    return (CabinKind.serumBound, others);
  }
}

// ── Karşılaştırma ──────────────────────────────────────────────────────

class CabinDifference {
  const CabinDifference(this.cabinLetter, this.message);

  final String cabinLetter;
  final String message;

  @override
  String toString() => '$cabinLetter: $message';
}

/// Client tanımı ([defined]) ile taramayı ([scanned]) karşılaştırır.
/// Serum kabini kapakları karttan okunamadığı için karşılaştırılmaz.
List<CabinDifference> compareSnapshots(CabinSnapshot defined, CabinSnapshot scanned) {
  final diffs = <CabinDifference>[];
  final scannedByAddress = {for (final c in scanned.cabins) c.addressIndex: c};
  final definedByAddress = {for (final c in defined.cabins) c.addressIndex: c};

  for (final d in defined.cabins) {
    final s = scannedByAddress[d.addressIndex];
    if (s == null) {
      diffs.add(CabinDifference(d.letter, 'Tanımda var, karttan cevap gelmedi'));
      continue;
    }
    if (d.kind != s.kind && d.kind != CabinKind.mobile) {
      diffs.add(CabinDifference(d.letter, 'Tanımda ${d.kind.label}, taramada ${s.kind.label}'));
    }
    if (d.kind == CabinKind.serumCabinet || d.kind == CabinKind.mobile) continue;

    final sUnits = {for (final u in s.units) u.matchKey: u};
    final dUnits = {for (final u in d.units) u.matchKey: u};
    for (final u in d.units) {
      final other = sUnits[u.matchKey];
      if (other == null) {
        diffs.add(CabinDifference(d.letter, '${u.locationLabel} ${u.name}: tanımda var, kart cevap vermedi'));
      } else if (other.name != u.name) {
        diffs.add(CabinDifference(d.letter, '${u.locationLabel}: tanımda ${u.name}, kartta ${other.name}'));
      }
    }
    for (final u in s.units) {
      if (!dUnits.containsKey(u.matchKey)) {
        diffs.add(CabinDifference(d.letter, '${u.locationLabel} ${u.name}: kartta var, tanımda yok'));
      }
    }
  }
  for (final s in scanned.cabins) {
    if (!definedByAddress.containsKey(s.addressIndex)) {
      diffs.add(CabinDifference(s.letter, '${s.kind.label} hatta var, tanımda yok'));
    }
  }
  return diffs;
}
