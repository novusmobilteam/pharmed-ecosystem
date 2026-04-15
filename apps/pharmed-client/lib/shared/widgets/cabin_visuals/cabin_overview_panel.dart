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
import 'package:pharmed_client/core/enums/cabin_operation_mode.dart';
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
    this.selectedSlotId,
  });

  /// Kabindeki tüm çekmece grupları — [DrawerGroup.slot.orderNumber]'a göre sıralı.
  final List<DrawerGroup> groups;

  /// Aktif işlem modu — hover rengini ve stok gösterimini etkiler.
  final CabinOperationMode mode;

  /// Tıklanan çekmeceyi üst widget'a bildirir.
  final void Function(DrawerGroup group) onDrawerTap;

  /// Seçili çekmecenin slot ID'si — highlight için
  final int? selectedSlotId;

  @override
  Widget build(BuildContext context) {
    // Bölümleri grupla: aynı orderNumber prefix'ine sahip çekmeceler yan yana
    final sections = _groupBySections(groups);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8E0EC),
        border: Border.all(color: MedColors.border2, width: 2),
        borderRadius: MedRadius.lgAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CabinPanelHeader(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final section in sections) ...[
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
  List<_Section> _groupBySections(List<DrawerGroup> groups) {
    return groups.map((g) => _Section(groups: [g])).toList();
  }
}

class _Section {
  const _Section({required this.groups});
  final List<DrawerGroup> groups;
}

class _CabinPanelHeader extends StatelessWidget {
  const _CabinPanelHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
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
    );
  }
}

class _CabinPanelFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB4C0D4), Color(0xFFA0AEC0)],
        ),
        border: Border(top: BorderSide(color: MedColors.border2, width: 1.5)),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
    );
  }
}

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
                  Row(
                    children: [
                      Text(
                        _typeLabel(group),
                        style: TextStyle(
                          fontFamily: MedFonts.sans,
                          fontSize: 9,
                          letterSpacing: 0.8,
                          color: MedColors.text3,
                        ),
                      ),
                      const Spacer(),
                      _StatusDot(workingStatus: workingStatus, stockStatus: stockStatus),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
              ),
            ),
            const Spacer(),
            // Çekmece kolu
            _DrawerHandle(),
            SizedBox(height: 5),
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
    if (group.isSerum) return 92;
    return 60;
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

// Stok özet enum — sol panel nokta rengi için

enum _DrawerStockStatus { normal, low, critical, empty }

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
        boxShadow: [BoxShadow(color: color.withAlpha(50), blurRadius: 4)],
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

/// Çekmecelerin alt kısmındaki fiziksel kol görseli.
class _DrawerHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA0B0C4), Color(0xFF9AADC0), Color(0xFFA0B0C4)],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF7A90A8)),
      ),
    );
  }
}
