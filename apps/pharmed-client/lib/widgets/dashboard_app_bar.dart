// lib/features/dashboard/presentation/widgets/dashboard_app_bar.dart
//
// [SWREQ-UI-TOP-001] [IEC 62304 §5.5]
// Dashboard üst çubuğu — appbar + navigasyon tek widget'ta.
// Giriş yapılmamışsa menüler disabled, giriş yap butonu gösterilir.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:collection/collection.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.menuTree,
    required this.flattenedMenus,
    required this.currentRoute,
    required this.isLoggedIn,
    this.user,
    this.onHomeTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onUserTap,
    this.onSettingsTap,
    this.onMenuItemTap,
  });

  final List<MenuItem> menuTree;
  final List<MenuItem> flattenedMenus;
  final String currentRoute;
  final bool isLoggedIn;
  final AppUser? user;

  final VoidCallback? onHomeTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onSettingsTap;
  final void Function(int id)? onMenuItemTap;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  late String _timeStr;
  late final Stream<String> _clockStream;

  final Map<int, GlobalKey> _itemKeys = {};
  OverlayEntry? _overlay;
  int? _openMenuId;

  @override
  void initState() {
    super.initState();
    _timeStr = _formatTime(DateTime.now());
    _clockStream = Stream.periodic(const Duration(seconds: 1), (_) => _formatTime(DateTime.now()));
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Menü overlay ──────────────────────────────────────────────

  void _toggleMenu(int id) {
    if (!widget.isLoggedIn) return;

    final item = widget.menuTree.firstWhereOrNull((m) => m.id == id);

    if (item != null && item.children.isEmpty) {
      if (_openMenuId != null) _closeMenu();
      widget.onMenuItemTap?.call(id);
      return;
    }

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
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeMenu,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: pos.dy + box.size.height + 2,
            left: pos.dx,
            child: DashboardNavbarMenu(
              parentId: id,
              flattenedMenus: widget.flattenedMenus,
              onCardTap: (childId) {
                _closeMenu();
                widget.onMenuItemTap?.call(childId);
              },
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  void _closeMenu() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _openMenuId = null);
  }

  bool _isMenuOrChildActive(MenuItem item) {
    if (item.route == widget.currentRoute) return true;
    if (item.children.isNotEmpty) {
      return item.children.any(_isMenuOrChildActive);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          // ── Logo / Anasayfa ──────────────────────────────────
          _AppLogo(onTap: widget.onHomeTap),
          _Separator(),

          // ── Navigasyon menüleri ──────────────────────────────
          ...widget.menuTree.map((item) {
            final id = item.id ?? 0;
            final key = _itemKeys.putIfAbsent(id, () => GlobalKey());
            return KeyedSubtree(
              key: key,
              child: _NavItem(
                item: item,
                isActive: _isMenuOrChildActive(item),
                isMenuOpen: _openMenuId == id,
                isLoggedIn: widget.isLoggedIn,
                onTap: () => _toggleMenu(id),
              ),
            );
          }),

          const Spacer(),

          // ── Saat ─────────────────────────────────────────────
          StreamBuilder<String>(
            stream: _clockStream,
            initialData: _timeStr,
            builder: (_, snap) => _ClockLabel(time: snap.data ?? _timeStr),
          ),
          _Separator(),

          // ── Kullanıcı alanı ──────────────────────────────────
          if (!widget.isLoggedIn)
            _LoginButton(onTap: widget.onLoginTap)
          else if (widget.user != null)
            _UserChip(user: widget.user!, onTap: widget.onUserTap),

          const SizedBox(width: 6),

          // ── Çıkış (sadece giriş yapılmışsa) ──────────────────
          if (widget.isLoggedIn) ...[
            _IconButton(icon: PhosphorIcons.signOut(), tooltip: 'Çıkış Yap', danger: true, onTap: widget.onLogoutTap),
            const SizedBox(width: 4),
          ],

          if (widget.isLoggedIn)
            _IconButton(icon: PhosphorIcons.gearSix(), tooltip: 'Ayarlar', onTap: widget.onSettingsTap),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Logo
// ─────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  const _AppLogo({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: MedFonts.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: MedColors.text,
                ),
                children: [
                  const TextSpan(text: 'PHAR'),
                  TextSpan(
                    text: 'MED',
                    style: TextStyle(color: MedColors.blue),
                  ),
                ],
              ),
            ),
            Text(
              'İLAÇ KABİN YÖNETİMİ',
              style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Nav item
// ─────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isMenuOpen,
    required this.isLoggedIn,
    this.onTap,
  });

  final MenuItem item;
  final bool isActive;
  final bool isMenuOpen;
  final bool isLoggedIn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool highlight = isActive || isMenuOpen;

    return Opacity(
      opacity: isLoggedIn ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: isLoggedIn ? onTap : null,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 13),

          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.name ?? '',
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: highlight ? MedColors.blue : MedColors.text3,
                ),
              ),
              if (!isLoggedIn) ...[
                const SizedBox(width: 4),
                Icon(Icons.lock_outline_rounded, size: 10, color: MedColors.text3),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Saat
// ─────────────────────────────────────────────

class _ClockLabel extends StatelessWidget {
  const _ClockLabel({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: MedColors.text2,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Kullanıcı chip
// ─────────────────────────────────────────────

class _UserChip extends StatelessWidget {
  const _UserChip({required this.user, this.onTap});

  final AppUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: MedColors.surface2,
          border: Border.all(color: MedColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.fullName,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: MedColors.text,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              user.role,
              style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Giriş yap butonu
// ─────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: MedColors.blue,
          borderRadius: MedRadius.mdAll,
          boxShadow: const [BoxShadow(color: Color(0x4D1A6BD8), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.signIn(), size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              'Giriş Yap',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// İkon buton (çıkış, ayarlar)
// ─────────────────────────────────────────────

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.tooltip, this.onTap, this.danger = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: danger ? MedColors.red : Colors.transparent,
            border: Border.all(color: danger ? MedColors.red : MedColors.border),
            borderRadius: MedRadius.mdAll,
          ),
          child: Icon(icon, size: 15, color: danger ? MedColors.bg : MedColors.text),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Separator
// ─────────────────────────────────────────────

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: MedColors.border2,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
