// pharmed_core/src/cabin/entity/drawer_type.dart

import 'package:pharmed_ui/pharmed_ui.dart';

/// ÇEKMECE TİPİ ENTITY'Sİ
/// -----------------------
/// Çekmece tipini tanımlar (Kübik 4×4, Birim Doz 3 Göz vb.).
/// DB'de tanımlanan sabit şablonlardır.
///
/// İLİŞKİLER:
///   DrawerConfig.drawerTypeId → DrawerType.id
///
/// KULLANIM:
///   - Tarama sonucu eşleştirme (config üzerinden tip belirleme)
///   - Kabin görsel çiziminde tip bilgisi
///   - compartmentCount → DrawerUnit sayısı üretimi
class DrawerType {
  const DrawerType({
    this.id,
    this.name,
    this.compartmentCount,
    this.isMultipleMaterialInput = false,
    this.isKubik = false,
    this.isMobileDrawer = false,
    this.isActive = true,
  });

  final int? id;
  final String? name; // "Kübik 4×4", "Birim Doz 3 Göz"
  final int? compartmentCount; // 16 (4×4), 20 (4×5), 3, 6, ...
  final bool isMultipleMaterialInput; // Çoklu ilaç girişine izin var mı
  final bool isKubik; // Kübik mi (kapaklı göz)
  final bool isMobileDrawer; // Mobil kabin çekmecesi mi
  final bool isActive;

  DrawerType copyWith({
    int? id,
    String? name,
    int? compartmentCount,
    bool? isMultipleMaterialInput,
    bool? isKubik,
    bool? isMobileDrawer,
    bool? isActive,
  }) {
    return DrawerType(
      id: id ?? this.id,
      name: name ?? this.name,
      compartmentCount: compartmentCount ?? this.compartmentCount,
      isMultipleMaterialInput: isMultipleMaterialInput ?? this.isMultipleMaterialInput,
      isKubik: isKubik ?? this.isKubik,
      isMobileDrawer: isMobileDrawer ?? this.isMobileDrawer,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Kullanıcıya gösterilen çekmece tipi adı (servisteki `name` tek harflik bir koddur).
  ///
  /// Öncelik: mobil → kübik → çoklu malzeme girişli (serum/dolap rafı, "Dolap") → birim doz.
  String get displayName {
    final l10n = contextlessL10n();
    if (isMobileDrawer) return l10n.cabin_mobileDrawerName;
    if (isKubik) return l10n.cabin_kubikDrawerName;
    if (isMultipleMaterialInput) return l10n.cabin_closetDrawerName;
    return l10n.cabin_unitDoseDrawerName;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is DrawerType && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DrawerType(id: $id, name: $name, compartmentCount: $compartmentCount, isKubik: $isKubik, isMobileDrawer: $isMobileDrawer)';
}
