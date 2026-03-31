// lib/features/setup_wizard/domain/model/wizard_mobile_layout.dart
//
// [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// Mobil kabin wizard adım 4 — manuel çekmece tanım modeli.
// Kullanıcı her çekmece için satır ve sütun sayısını girer.
// Sadece wizard sürecinde kullanılır; kayıt sırasında DrawerSlot listesine dönüştürülür.
// Sınıf: Class B

import 'package:equatable/equatable.dart';

class WizardMobileLayout extends Equatable {
  const WizardMobileLayout({required this.drawerCount, required this.drawers, this.sameConfig = false});

  /// Varsayılan: 2 çekmece, 4 satır × 3 sütun, ayrı konfigürasyon
  factory WizardMobileLayout.defaultLayout() {
    return WizardMobileLayout(
      drawerCount: 2,
      drawers: List.generate(2, (i) => WizardDrawerConfig(drawerIndex: i, rows: 4, columns: 3)),
    );
  }

  final int drawerCount; // 1–8
  final List<WizardDrawerConfig> drawers;

  /// true → tüm çekmeceler aynı konfigürasyonu paylaşır (drawers[0] referans alınır)
  final bool sameConfig;

  /// Çekmece sayısı değişince listeyi yeniden oluşturur.
  /// sameConfig açıksa tüm çekmeceler drawers[0]'ın değerlerini alır.
  /// Mevcut konfigürasyonlar korunur, yeni çekmeceler varsayılan değerle eklenir.
  WizardMobileLayout withDrawerCount(int newCount) {
    final ref = drawers.isNotEmpty ? drawers[0] : WizardDrawerConfig(drawerIndex: 0, rows: 4, columns: 3);
    final updated = List.generate(newCount, (i) {
      if (sameConfig) return WizardDrawerConfig(drawerIndex: i, rows: ref.rows, columns: ref.columns);
      if (i < drawers.length) return drawers[i];
      return WizardDrawerConfig(drawerIndex: i, rows: 4, columns: 3);
    });
    return WizardMobileLayout(drawerCount: newCount, drawers: updated, sameConfig: sameConfig);
  }

  /// Belirli bir çekmecenin satır veya sütun sayısını günceller.
  /// sameConfig açıksa tüm çekmecelere aynı değer uygulanır.
  WizardMobileLayout withDrawerConfig(int drawerIndex, {int? rows, int? columns}) {
    if (sameConfig) {
      // Tüm çekmeceleri güncelle
      final updated = drawers.map((d) => d.copyWith(rows: rows, columns: columns)).toList();
      return copyWith(drawers: updated);
    }
    final updated = drawers.map((d) {
      if (d.drawerIndex != drawerIndex) return d;
      return d.copyWith(rows: rows, columns: columns);
    }).toList();
    return copyWith(drawers: updated);
  }

  /// sameConfig toggle'ı değişince:
  /// - açılırsa → tüm çekmeceler drawers[0] değerlerini alır
  /// - kapanırsa → mevcut drawers korunur
  WizardMobileLayout withSameConfig(bool value) {
    if (!value) return copyWith(sameConfig: false);
    final ref = drawers.isNotEmpty ? drawers[0] : WizardDrawerConfig(drawerIndex: 0, rows: 4, columns: 3);
    final updated = List.generate(drawerCount, (i) {
      return WizardDrawerConfig(drawerIndex: i, rows: ref.rows, columns: ref.columns);
    });
    return WizardMobileLayout(drawerCount: drawerCount, drawers: updated, sameConfig: true);
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
  const WizardDrawerConfig({required this.drawerIndex, required this.rows, required this.columns});

  final int drawerIndex;
  final int rows; // 1–8
  final int columns; // 1–8

  WizardDrawerConfig copyWith({int? rows, int? columns}) {
    return WizardDrawerConfig(drawerIndex: drawerIndex, rows: rows ?? this.rows, columns: columns ?? this.columns);
  }

  @override
  List<Object?> get props => [drawerIndex, rows, columns];
}
