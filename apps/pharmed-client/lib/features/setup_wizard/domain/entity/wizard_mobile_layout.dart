// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Mobil kabin wizard adım 4 — manuel çekmece tanım modeli.
// Her çekmece için satır listesi tutulur; her satırın sütun sayısı bağımsızdır.
// Kayıt sırasında MobileDrawerRequestDTO listesine dönüştürülür.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

class WizardMobileLayout extends Equatable {
  const WizardMobileLayout({required this.drawerCount, required this.drawers, this.sameConfig = false});

  /// Varsayılan: 2 çekmece, 4 satır × 3 sütun, ayrı konfigürasyon
  factory WizardMobileLayout.defaultLayout() {
    return WizardMobileLayout(
      drawerCount: 2,
      drawers: List.generate(2, (i) => WizardDrawerConfig(drawerIndex: i, rowColumns: List.filled(4, 3))),
    );
  }

  final int drawerCount;
  final List<WizardDrawerConfig> drawers;
  final bool sameConfig;

  // ── Port keşfi yardımcıları ───────────────────────────────────────────────

  /// Keşifte yanıt veremeyen (pasif) çekmece sayısı.
  int get inactiveDrawerCount => drawers.where((d) => !d.isActive).length;

  /// Tüm çekmeceler aktif mi?
  bool get allActive => drawers.every((d) => d.isActive);

  // ── Mutasyonlar ───────────────────────────────────────────────────────────

  WizardMobileLayout withDrawerCount(int newCount) {
    final ref = drawers.isNotEmpty ? drawers[0] : WizardDrawerConfig(drawerIndex: 0, rowColumns: List.filled(4, 3));
    final updated = List.generate(newCount, (i) {
      if (sameConfig) {
        return WizardDrawerConfig(drawerIndex: i, rowColumns: List.of(ref.rowColumns));
      }
      if (i < drawers.length) return drawers[i];
      return WizardDrawerConfig(drawerIndex: i, rowColumns: List.filled(4, 3));
    });
    return WizardMobileLayout(drawerCount: newCount, drawers: updated, sameConfig: sameConfig);
  }

  /// Belirli bir çekmecenin rowColumns listesini günceller.
  /// sameConfig açıksa tüm çekmecelere aynı liste uygulanır.
  WizardMobileLayout withDrawerConfig(int drawerIndex, List<int> rowColumns) {
    if (sameConfig) {
      final updated = drawers
          .map(
            (d) => WizardDrawerConfig(
              drawerIndex: d.drawerIndex,
              rowColumns: List.of(rowColumns),
              portNumber: d.portNumber,
              isActive: d.isActive,
            ),
          )
          .toList();
      return copyWith(drawers: updated);
    }
    final updated = drawers.map((d) {
      if (d.drawerIndex != drawerIndex) return d;
      return WizardDrawerConfig(
        drawerIndex: d.drawerIndex,
        rowColumns: List.of(rowColumns),
        portNumber: d.portNumber,
        isActive: d.isActive,
      );
    }).toList();
    return copyWith(drawers: updated);
  }

  WizardMobileLayout withSameConfig(bool value) {
    if (!value) return copyWith(sameConfig: false);
    final ref = drawers.isNotEmpty ? drawers[0] : WizardDrawerConfig(drawerIndex: 0, rowColumns: List.filled(4, 3));
    final updated = List.generate(
      drawerCount,
      (i) => WizardDrawerConfig(
        drawerIndex: i,
        rowColumns: List.of(ref.rowColumns),
        portNumber: drawers.length > i ? drawers[i].portNumber : null,
        isActive: drawers.length > i ? drawers[i].isActive : true,
      ),
    );
    return WizardMobileLayout(drawerCount: drawerCount, drawers: updated, sameConfig: true);
  }

  /// Port keşfi sonucunu çekmecelere uygular.
  ///
  /// [discoveredPorts]: Keşfedilen port numaraları (sıralı, 1-tabanlı).
  /// Çekmece index'i ile port sırası eşleştirilir:
  ///   drawer[0] → discoveredPorts[0] varsa aktif, yoksa pasif
  ///   drawer[1] → discoveredPorts[1] varsa aktif, yoksa pasif
  ///   ...
  WizardMobileLayout applyDiscoveredPorts(List<int> discoveredPorts) {
    final updated = drawers.map((d) {
      final portIndex = d.drawerIndex;
      final hasPort = portIndex < discoveredPorts.length;
      return WizardDrawerConfig(
        drawerIndex: d.drawerIndex,
        rowColumns: d.rowColumns,
        portNumber: hasPort ? discoveredPorts[portIndex] : null,
        isActive: hasPort,
      );
    }).toList();
    return copyWith(drawers: updated);
  }

  /// Pasif çekmeceyi listeden kaldırır, index'leri yeniden düzenler.
  WizardMobileLayout removeInactiveDrawer(int drawerIndex) {
    final updated = drawers
        .where((d) => d.drawerIndex != drawerIndex)
        .toList()
        .asMap()
        .entries
        .map(
          (e) => WizardDrawerConfig(
            drawerIndex: e.key,
            rowColumns: e.value.rowColumns,
            portNumber: e.value.portNumber,
            isActive: e.value.isActive,
          ),
        )
        .toList();
    return WizardMobileLayout(drawerCount: updated.length, drawers: updated, sameConfig: sameConfig);
  }

  WizardMobileLayout copyWith({int? drawerCount, List<WizardDrawerConfig>? drawers, bool? sameConfig}) {
    return WizardMobileLayout(
      drawerCount: drawerCount ?? this.drawerCount,
      drawers: drawers ?? this.drawers,
      sameConfig: sameConfig ?? this.sameConfig,
    );
  }

  @override
  List<Object?> get props => [drawerCount, drawers, sameConfig];
}

class WizardDrawerConfig extends Equatable {
  const WizardDrawerConfig({
    required this.drawerIndex,
    required this.rowColumns,
    this.portNumber,
    this.isActive = true,
  });

  final int drawerIndex;

  /// Her index bir satırı, değer o satırın sütun sayısını temsil eder.
  /// Örn: [3, 2, 4, 3] → 4 satır, sütunlar sırasıyla 3, 2, 4, 3
  final List<int> rowColumns;

  /// Serum kartındaki port numarası (1-8).
  /// Port keşfi tamamlanana kadar null'dır.
  /// null → port henüz atanmadı veya keşif yapılmadı.
  final int? portNumber;

  /// Port keşfinde bu çekmeceye karşılık gelen porttan yanıt alındı mı?
  /// false → solenoid yok veya bağlantı sorunu — çekmece pasif kaydedilir.
  final bool isActive;

  int get rowCount => rowColumns.length;
  int get totalCells => rowColumns.fold(0, (sum, c) => sum + c);

  /// Belirli bir satırın sütun sayısını günceller.
  WizardDrawerConfig withRowColumns(int rowIndex, int columns) {
    final updated = List.of(rowColumns);
    updated[rowIndex] = columns;
    return WizardDrawerConfig(
      drawerIndex: drawerIndex,
      rowColumns: updated,
      portNumber: portNumber,
      isActive: isActive,
    );
  }

  /// Sona yeni satır ekler (varsayılan 3 sütun).
  WizardDrawerConfig withRowAdded({int defaultColumns = 3}) {
    return WizardDrawerConfig(
      drawerIndex: drawerIndex,
      rowColumns: [...rowColumns, defaultColumns],
      portNumber: portNumber,
      isActive: isActive,
    );
  }

  /// Belirli index'teki satırı kaldırır.
  WizardDrawerConfig withRowRemoved(int rowIndex) {
    final updated = List.of(rowColumns)..removeAt(rowIndex);
    return WizardDrawerConfig(
      drawerIndex: drawerIndex,
      rowColumns: updated,
      portNumber: portNumber,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [drawerIndex, rowColumns, portNumber, isActive];
}
