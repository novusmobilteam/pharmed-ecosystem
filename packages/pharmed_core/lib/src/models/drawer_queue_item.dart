// [SWREQ-CORE-DRAWERQUEUE-001] [IEC 62304 §5.5]
// Kabin konum rehberi widget'ının kullandığı ekrandan bağımsız kuyruk öğesi.
//
// Her ekran (dolum, alım, sayım, iade, imha) kendi job modelinden
// [DrawerQueueItem] listesi üretir; [CabinLocationGuide] yalnızca bu modeli bilir.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';

/// Kuyruk öğesinin görsel durumu.
enum DrawerQueueStatus {
  /// Henüz işlenmedi (bu işlemde seçildi, sıra gelmedi).
  pending,

  /// Şu an işleniyor (çekmece açık veya açılıyor).
  active,

  /// Tamamlandı.
  completed,

  /// Hata ile sonuçlandı.
  failed,

  /// Bu işleme dahil değil (seçilmedi / kuyruğa girmedi).
  notInQueue,
}

/// Kabin konum rehberinde gösterilecek tek bir çekmece öğesi.
///
/// [group]  → Fiziksel çekmece yapısı (adres, tip, unit listesi).
/// [status] → Kuyruktaki görsel durum.
///
/// Kübik çekmece için ek alanlar:
///   [activeTargetIndex]       → O an açık lid'in index'i (0-tabanlı).
///   [completedTargetIndexes]  → Tamamlanan lid index'leri (0-tabanlı).
///
/// Birim doz çekmece için ek alan:
///   [activeUnitIndexes] → Dolum yapılacak bölme index'leri (0-tabanlı).
///   Boşsa tüm bölmeler eşit gösterilir (serbest dolum).
class DrawerQueueItem {
  const DrawerQueueItem({
    required this.group,
    required this.status,
    this.activeTargetIndex,
    this.completedTargetIndexes = const {},
    this.activeUnitIndexes = const {},
  });

  final DrawerGroup group;
  final DrawerQueueStatus status;

  /// Kübik: aktif lid index'i. Birim doz ve notInQueue'da null.
  final int? activeTargetIndex;

  /// Kübik: tamamlanan lid index'leri. Birim doz'da boş.
  final Set<int> completedTargetIndexes;

  /// Birim doz: bu işlemde hedef olan bölme index'leri (0-tabanlı, units listesine göre).
  /// Boş set → tüm bölmeler eşit (serbest dolum).
  final Set<int> activeUnitIndexes;

  // ── Türetilen ─────────────────────────────────────────────────────────────

  bool get isKubik => group.isKubik;
  bool get isInQueue => status != DrawerQueueStatus.notInQueue;
  String get address => group.slot.address ?? '?';
  List<DrawerUnit> get units => group.units;
  int get numberOfSteps => group.slot.drawerConfig?.numberOfSteps ?? 0;
}
