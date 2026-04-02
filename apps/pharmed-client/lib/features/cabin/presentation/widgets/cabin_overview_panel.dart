// lib/features/cabin/presentation/widgets/cabin_overview_panel.dart
//
// [SWREQ-UI-CAB-002]
// Kabin işlemleri ekranının sol paneli.
// Kabindeki tüm çekmeceleri liste halinde gösterir,
// seçili çekmece highlight edilir, tıklama ile orta panel güncellenir.
//
// KULLANIM:
//   CabinOverviewPanel(
//     groups: drawerGroups,
//     selectedSlotId: _selectedSlotId,
//     mode: CabinOperationMode.fill,
//     onDrawerTap: (group) => setState(() => _selected = group),
//   )
//
// BAĞIMLILIK:
//   - pharmed_core: DrawerGroup, DrawerSlot, DrawerUnit, CabinWorkingStatus
//   - pharmed_ui: MedColors, MedFonts, MedTextStyles, MedRadius, LedIndicator
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_client/features/cabin/presentation/state/cabin_operation_mode.dart';
import 'package:pharmed_ui/src/widgets/atoms/led_indicator.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// CabinOverviewPanel
// ─────────────────────────────────────────────────────────────────

/// Kabin işlemleri sol paneli — tıklanabilir çekmece listesi.
///
/// Her çekmece yekpare bir kart olarak gösterilir.
/// Çekmece tipi etiketi (Kübik / B.Doz / Serum), stok durum noktası
/// ve çekmece kolu gösterilir.
///
/// Arızalı unit içeren çekmeceler özel bir uyarı noktası ile işaretlenir.
/// [CabinWorkingStatus.faulty] → kırmızı, [CabinWorkingStatus.maintenance] → sarı.
///
/// [mode], çekmeceye hover rengini belirler:
/// - assign  → mavi
/// - fill    → yeşil
/// - count   → amber
/// - fault   → kırmızı
class CabinOverviewPanel extends StatelessWidget {
  const CabinOverviewPanel({
    super.key,
    required this.groups,
    required this.mode,
    required this.onDrawerTap,
    this.cabinId = 'CB-304',
    this.selectedSlotId,
    this.powerStatus = LedStatus.on,
    this.alertStatus = LedStatus.off,
  });

  /// Kabindeki tüm çekmece grupları — [DrawerGroup.slot.orderNumber]'a göre sıralı.
  final List<DrawerGroup> groups;

  /// Aktif işlem modu — hover rengini ve stok gösterimini etkiler.
  final CabinOperationMode mode;

  /// Tıklanan çekmeceyi üst widget'a bildirir.
  final void Function(DrawerGroup group) onDrawerTap;

  /// Kabin kimlik etiketi
  final String cabinId;

  /// Seçili çekmecenin slot ID'si — highlight için
  final int? selectedSlotId;

  final LedStatus powerStatus;
  final LedStatus alertStatus;

  @override
  Widget build(BuildContext context) {
    // Bölümleri grupla: aynı orderNumber prefix'ine sahip çekmeceler yan yana
    final sections = _groupBySections(groups);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8E0EC),
        border: Border.all(color: MedColors.border2, width: 2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1F1E3C64), blurRadius: 40, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x141E3C64), blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CabinPanelHeader(cabinId: cabinId, powerStatus: powerStatus, alertStatus: alertStatus),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final section in sections) ...[
                  if (section.label != null) ...[_SectionLabel(label: section.label!), const SizedBox(height: 3)],
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < section.groups.length; i++) ...[
                        Expanded(
                          child: _DrawerItem(
                            group: section.groups[i],
                            mode: mode,
                            isSelected: section.groups[i].slot.id == selectedSlotId,
                            onTap: () => onDrawerTap(section.groups[i]),
                          ),
                        ),
                        if (i < section.groups.length - 1) const SizedBox(width: 4),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                ],
              ],
            ),
          ),
          _CabinPanelFooter(),
        ],
      ),
    );
  }

  /// Çekmeceleri bölümlere ayırır.
  ///
  /// Şu an her çekmece kendi bölümünde — ileride bölüm bilgisi
  /// API'den geldiğinde bu metod güncellenecek.
  List<_Section> _groupBySections(List<DrawerGroup> groups) {
    // TODO: Bölüm bilgisi API'den geldiğinde burayı güncelle
    // Şimdilik her çekmece tek başına bir satır
    return groups.map((g) => _Section(groups: [g])).toList();
  }
}

// ─────────────────────────────────────────────────────────────────
// Bölüm modeli
// ─────────────────────────────────────────────────────────────────

class _Section {
  const _Section({required this.groups, this.label});
  final List<DrawerGroup> groups;
  final String? label;
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _CabinPanelHeader extends StatelessWidget {
  const _CabinPanelHeader({required this.cabinId, required this.powerStatus, required this.alertStatus});

  final String cabinId;
  final LedStatus powerStatus;
  final LedStatus alertStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC4CEDF), Color(0xFFB4C0D4)],
        ),
        border: Border(bottom: BorderSide(color: MedColors.border2, width: 2)),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          LedIndicator(status: powerStatus),
          const SizedBox(width: 5),
          LedIndicator(status: alertStatus),
          const Spacer(),
          Text(
            cabinId,
            style: TextStyle(
              fontFamily: MedFonts.mono,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3A4D66),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────

class _CabinPanelFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB4C0D4), Color(0xFFA0AEC0)],
        ),
        border: Border(top: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_Wheel(), const SizedBox(width: 18), _Wheel()],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFF6A7A90),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF505E72)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Bölüm etiketi
// ─────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontFamily: MedFonts.mono, fontSize: 7, letterSpacing: 1.2, color: const Color(0xFF8090A8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DrawerItem — tek bir çekmece kartı
// ─────────────────────────────────────────────────────────────────

/// Sol paneldeki tek bir çekmece görseli.
///
/// Tip etiketi (Kübik / B.Doz / Serum), çekmece adresi,
/// stok durum noktası ve çekmece kolu içerir.
///
/// Arızalı unit varsa kırmızı yanıp sönen nokta gösterilir.
/// Bakım modundaki unit varsa sarı nokta gösterilir.
class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.group, required this.mode, required this.isSelected, required this.onTap});

  final DrawerGroup group;
  final CabinOperationMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final workingStatus = _resolveWorkingStatus(group.units);
    final stockStatus = _resolveStockDot(group);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _resolveHeight(group),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFDCEEFF), Color(0xFFCEE0F7)],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFEDF1F8), Color(0xFFDDE5F0)],
                ),
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2, width: isSelected ? 2 : 1.5),
          borderRadius: BorderRadius.circular(7),
          boxShadow: isSelected
              ? [const BoxShadow(color: Color(0x4D1A6FD8), blurRadius: 12, offset: Offset(0, 3))]
              : [const BoxShadow(color: Color(0x1F1E3C64), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // İçerik
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tip etiketi
                  Text(
                    _typeLabel(group),
                    style: TextStyle(
                      fontFamily: MedFonts.mono,
                      fontSize: 7,
                      letterSpacing: 0.8,
                      color: MedColors.text3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Adres + durum noktası
                  Row(
                    children: [
                      Text(
                        group.slot.address ?? '—',
                        style: TextStyle(
                          fontFamily: MedFonts.mono,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A5F78),
                        ),
                      ),
                      const Spacer(),
                      _StatusDot(workingStatus: workingStatus, stockStatus: stockStatus),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Çekmece kolu
            _DrawerHandle(),
          ],
        ),
      ),
    );
  }

  /// Çekmece tipi kısa etiket
  String _typeLabel(DrawerGroup group) {
    if (group.isSerum) return 'SERUM';
    if (group.isKubik) return 'KÜBİK';
    return 'B.DOZ';
  }

  /// Çekmece yüksekliği — serum 2x, diğerleri normal
  double _resolveHeight(DrawerGroup group) {
    if (group.isSerum) return 88;
    return 54;
  }

  /// Çekmeceye ait en kötü working status'u döndürür.
  /// Herhangi bir unit arızalıysa [CabinWorkingStatus.faulty] döner.
  CabinWorkingStatus _resolveWorkingStatus(List<DrawerUnit> units) {
    if (units.any((u) => u.workingStatus == CabinWorkingStatus.faulty)) {
      return CabinWorkingStatus.faulty;
    }
    if (units.any((u) => u.workingStatus == CabinWorkingStatus.maintenance)) {
      return CabinWorkingStatus.maintenance;
    }
    return CabinWorkingStatus.working;
  }

  /// Stok durum noktası rengi için özet status.
  ///
  /// En kötü stok durumunu döndürür.
  /// [DrawerGroup]'tan stok bilgisi olmadığı için şimdilik
  /// [_DrawerStockStatus.normal] döndürülür.
  ///
  /// TODO: DrawerGroup'a stok özet bilgisi eklenince güncelle
  _DrawerStockStatus _resolveStockDot(DrawerGroup group) {
    return _DrawerStockStatus.normal;
  }
}

// ─────────────────────────────────────────────────────────────────
// Stok özet enum — sol panel nokta rengi için
// ─────────────────────────────────────────────────────────────────

enum _DrawerStockStatus { normal, low, critical, empty }

// ─────────────────────────────────────────────────────────────────
// Durum noktası
// ─────────────────────────────────────────────────────────────────

/// Çekmece kartının sağ üst köşesindeki durum göstergesi.
///
/// Arıza/bakım durumu stok durumundan önce gelir:
/// - [CabinWorkingStatus.faulty]      → kırmızı, yanıp söner
/// - [CabinWorkingStatus.maintenance] → sarı
/// - stok critical                    → kırmızı
/// - stok low                         → amber
/// - stok empty                       → soluk mavi
/// - normal                           → mavi
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.workingStatus, required this.stockStatus});

  final CabinWorkingStatus workingStatus;
  final _DrawerStockStatus stockStatus;

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    final shouldBlink = workingStatus == CabinWorkingStatus.faulty || stockStatus == _DrawerStockStatus.critical;

    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
      ),
    );

    if (!shouldBlink) return dot;

    return _BlinkingWidget(child: dot);
  }

  Color _resolveColor() {
    if (workingStatus == CabinWorkingStatus.faulty) return MedColors.red;
    if (workingStatus == CabinWorkingStatus.maintenance) return MedColors.amber;
    return switch (stockStatus) {
      _DrawerStockStatus.critical => MedColors.red,
      _DrawerStockStatus.low => MedColors.amber,
      _DrawerStockStatus.empty => MedColors.surface,
      _DrawerStockStatus.normal => MedColors.blue,
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// Yanıp sönen widget
// ─────────────────────────────────────────────────────────────────

class _BlinkingWidget extends StatefulWidget {
  const _BlinkingWidget({required this.child});
  final Widget child;

  @override
  State<_BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<_BlinkingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

// ─────────────────────────────────────────────────────────────────
// Çekmece kolu
// ─────────────────────────────────────────────────────────────────

/// Çekmecelerin alt kısmındaki fiziksel kol görseli.
class _DrawerHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA0B0C4), Color(0xFF9AADC0), Color(0xFFA0B0C4)],
          stops: [0, 0.4, 1],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF7A90A8)),
        boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 2, offset: Offset(0, 1))],
      ),
    );
  }
}
