import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:collection/collection.dart';

// ═════════════════════════════════════════════════════════════════
// AppSubNav
// [SWREQ-UI-NAV-001]
// Alt navigasyon çubuğu. Giriş yapılmamışsa menüler kilitli görünür.
// 'cabin' id'li menü öğesi tıklandığında KabinMegaMenu overlay açar.
// ═════════════════════════════════════════════════════════════════

class DashboardNavBar extends StatefulWidget {
  const DashboardNavBar({
    super.key,
    required this.menuTree,
    required this.flattenedMenus,
    required this.isLoggedIn,
    this.onItemTap,
    required this.currentRoute,
  });

  final bool isLoggedIn;
  final String currentRoute;
  final List<MenuItem> menuTree;
  final List<MenuItem> flattenedMenus;
  final void Function(int id)? onItemTap;

  @override
  State<DashboardNavBar> createState() => _DashboardNavBarState();
}

class _DashboardNavBarState extends State<DashboardNavBar> {
  final Map<int, GlobalKey> _itemKeys = {};
  OverlayEntry? _overlay;
  int? _openMenuId; // Hangi menünün açık olduğunu takip eder

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  void _toggleMenu(int id) {
    if (!widget.isLoggedIn) {
      // Görsel bir geri bildirim istersen SnackBar veya Toast atabilirsin
      return;
    }
    // 1. Tıklanan öğeyi bul
    final item = widget.menuTree.firstWhereOrNull((m) => m.id == id);

    // 2. Eğer alt menüsü yoksa (Anasayfa gibi) direkt yönlendir ve menü açma
    if (item != null && item.children.isEmpty) {
      if (_openMenuId != null) _closeMenu();
      widget.onItemTap?.call(id); // Bu tetikleyici Notifier'daki navigateTo'ya gider
      return;
    }

    // 3. Alt menüsü varsa eski toggle mantığı
    if (_openMenuId == id) {
      _closeMenu();
    } else {
      if (_openMenuId != null) _closeMenu();
      _openMenu(id);
    }
  }

  void _openMenu(int id) {
    final key = _itemKeys[id];
    final ctx = key?.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);

    setState(() => _openMenuId = id);

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Bariyer
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          // Dinamik Mega Menü
          Positioned(
            top: pos.dy + box.size.height + 2,
            left: pos.dx,
            child: _buildMenuContent(id), // ID'ye göre farklı içerik dönebilir
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  // ID'ye göre hangi menünün açılacağına karar veren yardımcı metod
  Widget _buildMenuContent(int id) {
    // Burada istersen ID'ye göre farklı widgetlar dönebilirsin
    // Örn: if (id == 52) return KabinMegaMenu(...) else return GenericSubMenu(...)
    return DashboardNavbarMenu(
      parentId: id,
      flattenedMenus: widget.flattenedMenus,
      onCardTap: (childId) {
        _closeMenu();
        widget.onItemTap?.call(childId);
      },
    );
  }

  void _closeMenu() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _openMenuId = null);
  }

  bool _isMenuOrChildActive(MenuItem item, String currentRoute) {
    // 1. Kendisi doğrudan aktif mi?
    if (item.route == currentRoute) return true;

    // 2. Çocuklarından herhangi biri aktif mi? (Recursive kontrol)
    if (item.children.isNotEmpty) {
      return item.children.any((child) => _isMenuOrChildActive(child, currentRoute));
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(color: MedColors.surface),
      child: Row(
        children: [
          const SizedBox(width: 10),
          ...widget.menuTree.map((item) {
            final id = item.id ?? 0;
            final key = _itemKeys.putIfAbsent(id, () => GlobalKey());

            final bool isSelected = _isMenuOrChildActive(item, widget.currentRoute);

            return KeyedSubtree(
              key: key,
              child: _NavItem(
                item: item,
                isMenuOpen: _openMenuId == id,
                onTap: () => _toggleMenu(id),
                isSelected: isSelected,
                isLoggedIn: widget.isLoggedIn,
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    this.isMenuOpen = false,
    this.onTap,
    required this.isSelected,
    required this.isLoggedIn,
  });

  final MenuItem item;
  final bool isMenuOpen;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    final bool highlight = isMenuOpen || isSelected;

    return Opacity(
      opacity: isLoggedIn ? 1.0 : 0.4,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: EdgeInsets.only(right: 4.0),
          decoration: BoxDecoration(
            //color: Colors.red,
            border: Border(bottom: BorderSide(color: highlight ? MedColors.blue : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.name ?? '',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: highlight ? MedColors.blue : MedColors.text3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════
// QuickActionsGrid
// [SWREQ-UI-QUICK-001]
// 2x2 hızlı işlem grid'i. Giriş gerekenler kilitli görünür.
// ═════════════════════════════════════════════════════════════════

// class QuickActionsGrid extends StatelessWidget {
//   const QuickActionsGrid({super.key, required this.actions, required this.isLoggedIn, this.onActionTap});

//   final List<QuickAction> actions;
//   final bool isLoggedIn;
//   final void Function(String id)? onActionTap;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: MedColors.border),
//         borderRadius: MedRadius.lgAll,
//         boxShadow: MedShadows.sm,
//       ),
//       child: Column(
//         children: [
//           _WidgetHeader(title: 'HIZLI İŞLEMLER', dotColor: MedColors.amber),
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//               childAspectRatio: 1.4,
//               children: actions.map((action) {
//                 final locked = action.requiresAuth && !isLoggedIn;
//                 return _QuickActionButton(
//                   action: action,
//                   isLocked: locked,
//                   onTap: locked ? null : () => onActionTap?.call(action.id),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _QuickActionButton extends StatelessWidget {
//   const _QuickActionButton({required this.action, required this.isLocked, this.onTap});

//   final QuickAction action;
//   final bool isLocked;
//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         decoration: BoxDecoration(
//           color: MedColors.surface2,
//           border: Border.all(color: MedColors.border, width: 1.5),
//           borderRadius: MedRadius.mdAll,
//         ),
//         child: Opacity(
//           opacity: isLocked ? 0.5 : 1.0,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(action.icon, size: 18, color: MedColors.text3),
//               const SizedBox(height: 6),
//               Text(
//                 action.label.toUpperCase(),
//                 style: TextStyle(
//                   fontFamily: MedFonts.sans,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   letterSpacing: 0.5,
//                   color: MedColors.text3,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ═════════════════════════════════════════════════════════════════
// AlertsList
// [SWREQ-UI-ALERT-001] [HAZ-008]
// Kritik/uyarı/bilgi tipi uyarılar listesi.
// ═════════════════════════════════════════════════════════════════

// class AlertsList extends StatelessWidget {
//   const AlertsList({super.key, required this.alerts});

//   final List<AlertItem> alerts;

//   @override
//   Widget build(BuildContext context) {
//     final criticalCount = alerts.where((a) => a.severity == AlertSeverity.critical).length;

//     return Container(
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: MedColors.border),
//         borderRadius: MedRadius.lgAll,
//         boxShadow: MedShadows.sm,
//       ),
//       child: Column(
//         children: [
//           _WidgetHeader(
//             title: 'UYARILAR',
//             dotColor: MedColors.red,
//             badge: MedBadge(label: '$criticalCount kritik', variant: MedBadgeVariant.red),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(children: alerts.map((a) => _AlertRow(item: a)).toList()),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AlertRow extends StatelessWidget {
//   const _AlertRow({required this.item});

//   final AlertItem item;

//   @override
//   Widget build(BuildContext context) {
//     final (bg, border, iconColor) = switch (item.severity) {
//       AlertSeverity.critical => (MedColors.redLight, const Color(0xFFF2B3AE), MedColors.red),
//       AlertSeverity.warning => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
//       AlertSeverity.info => (MedColors.blueLight, const Color(0xFFC4D9F5), MedColors.blue),
//     };

//     final icon = switch (item.severity) {
//       AlertSeverity.critical => Icons.warning_amber_rounded,
//       AlertSeverity.warning => Icons.info_outline_rounded,
//       AlertSeverity.info => Icons.info_outline_rounded,
//     };

//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: bg,
//         border: Border.all(color: border),
//         borderRadius: MedRadius.smAll,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 13, color: iconColor),
//           const SizedBox(width: 9),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(item.message, style: MedTextStyles.bodySm(color: MedColors.text)),
//                 if (item.detail != null) ...[
//                   const SizedBox(height: 2),
//                   MedLabel(text: item.detail!, variant: MedLabelVariant.monoDetail),
//                 ],
//                 const SizedBox(height: 2),
//                 MedLabel(text: item.time, variant: MedLabelVariant.monoDetail),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// ═════════════════════════════════════════════════════════════════
// ActivityFeed
// [SWREQ-UI-ACT-001]
// Son aktiviteler zaman çizelgesi.
// ═════════════════════════════════════════════════════════════════

// class ActivityFeed extends StatelessWidget {
//   const ActivityFeed({super.key, required this.activities});

//   final List<ActivityItem> activities;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: MedColors.border),
//         borderRadius: MedRadius.lgAll,
//         boxShadow: MedShadows.sm,
//       ),
//       child: Column(
//         children: [
//           _WidgetHeader(
//             title: 'SON AKTİVİTELER',
//             dotColor: MedColors.green,
//             badge: const MedBadge(label: 'Canlı', variant: MedBadgeVariant.green),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 for (int i = 0; i < activities.length; i++)
//                   _ActivityRow(item: activities[i], isLast: i == activities.length - 1),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActivityRow extends StatelessWidget {
//   const _ActivityRow({required this.item, required this.isLast});

//   final ActivityItem item;
//   final bool isLast;

//   @override
//   Widget build(BuildContext context) {
//     final (dotBg, dotBorder, dotColor) = switch (item.type) {
//       ActivityType.distribution => (MedColors.greenLight, const Color(0xFFB5DDD4), MedColors.green),
//       ActivityType.cabinOpen => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
//       ActivityType.prescription => (MedColors.blueLight, const Color(0xFFC4D9F5), MedColors.blue),
//       ActivityType.return_ => (MedColors.amberLight, const Color(0xFFF5D79E), MedColors.amber),
//       ActivityType.fill => (MedColors.greenLight, const Color(0xFFB5DDD4), MedColors.green),
//     };

//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 28,
//             child: Column(
//               children: [
//                 Container(
//                   width: 20,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: dotBg,
//                     border: Border.all(color: dotBorder),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(_iconFor(item.type), size: 8, color: dotColor),
//                 ),
//                 if (!isLast)
//                   Expanded(
//                     child: Center(child: Container(width: 1, color: MedColors.border2)),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(item.message, style: MedTextStyles.bodySm(color: MedColors.text)),
//                   const SizedBox(height: 1),
//                   MedLabel(text: item.meta, variant: MedLabelVariant.monoDetail),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   IconData _iconFor(ActivityType type) => switch (type) {
//     ActivityType.distribution => Icons.check_rounded,
//     ActivityType.cabinOpen => Icons.lock_open_rounded,
//     ActivityType.prescription => Icons.add,
//     ActivityType.return_ => Icons.replay_rounded,
//     ActivityType.fill => Icons.inventory_2_outlined,
//   };
// }
