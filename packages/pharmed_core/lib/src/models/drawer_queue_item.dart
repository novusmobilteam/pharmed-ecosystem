// [SWREQ-CORE-DRAWERQUEUE-001] [IEC 62304 §5.5]
// Kabin konum rehberi widget'ının kullandığı ekrandan bağımsız kuyruk öğesi.
//
// Her ekran (dolum, alım, sayım, iade, imha) kendi job modelinden
// [DrawerQueueItem] üretir; [CabinLocationGuide] yalnızca bu modeli bilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kuyruk öğesinin görsel durumu.
enum DrawerQueueStatus {
  /// Henüz işlenmedi.
  pending,

  /// Şu an işleniyor (çekmece açık veya açılıyor).
  active,

  /// Tamamlandı.
  completed,

  /// Hata ile sonuçlandı.
  failed,
}

/// Kabin konum rehberinde gösterilecek tek bir çekmece kuyruğu öğesi.
///
/// [group] → Fiziksel çekmece yapısı (adres, tip, unit listesi).
/// [status] → Kuyruktaki görsel durum.
/// [activeTargetIndex] → Kübik çekmecede o an açık olan lid'in index'i.
///   Birim doz çekmecede kullanılmaz (null).
/// [completedTargetIndexes] → Kübik çekmecede tamamlanan lid index'leri.
///   Birim doz çekmecede kullanılmaz (boş set).
class DrawerQueueItem {
  const DrawerQueueItem({
    required this.group,
    required this.status,
    this.activeTargetIndex,
    this.completedTargetIndexes = const {},
  });

  final DrawerGroup group;
  final DrawerQueueStatus status;

  /// Kübik: aktif lid index'i (0-tabanlı). Birim doz ve pending/completed'da null.
  final int? activeTargetIndex;

  /// Kübik: tamamlanan lid index'leri (0-tabanlı). Birim doz'da boş.
  final Set<int> completedTargetIndexes;

  // ── Türetilen ─────────────────────────────────────────────────────────────

  bool get isKubik => group.isKubik;
  String get address => group.slot.address ?? '?';
  List<DrawerUnit> get units => group.units;

  /// Birim doz: her unit'in kaç step'i olduğu.
  /// DrawerConfig.numberOfSteps tüm unit'ler için ortaktır.
  int get numberOfSteps => group.slot.drawerConfig?.numberOfSteps ?? 0;
}
