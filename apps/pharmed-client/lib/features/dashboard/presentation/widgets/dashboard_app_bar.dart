// [SWREQ-UI-TOP-001] [SWREQ-UI-NAV-001] [IEC 62304 §5.5]
// Dashboard üst çubuğu — appbar + navigasyon tek widget'ta.
// Giriş yapılmamışsa menüler disabled, giriş yap butonu gösterilir.
// Kabin işlemi sürerken (isNavigationLocked) menüler, logo, ayarlar ve çıkış
// kilitli görünür; dokunuşlar yalnızca onLockedTap'e gider.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart' hide MaterialType;
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:collection/collection.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/cache/app_settings_cache.dart';

part 'dashboard_navbar_menu.dart';

/// Kabin işlemi kilidindeki görünüm — design system `.locked` (opacity 0.45).
const double _kLockedOpacity = 0.45;

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.menuTree,
    required this.flattenedMenus,
    required this.currentRoute,
    required this.isLoggedIn,
    this.isNavigationLocked = false,
    this.user,
    this.onHomeTap,
    this.onLoginTap,
    this.onLogoutTap,
    this.onUserTap,
    this.onSettingsTap,
    this.onMenuItemTap,
    this.onLockedTap,
  });

  final List<MenuItem> menuTree;
  final List<MenuItem> flattenedMenus;
  final String currentRoute;
  final bool isLoggedIn;

  /// true → kabin işlemi sürüyor; navigasyon aksiyonları pasif.
  final bool isNavigationLocked;
  final AppUser? user;

  final VoidCallback? onHomeTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onUserTap;
  final VoidCallback? onSettingsTap;
  final void Function(int id)? onMenuItemTap;

  /// Kilitliyken herhangi bir navigasyon aksiyonuna dokunulduğunda çağrılır
  /// (kullanıcıya neden çalışmadığını göstermek için).
  final VoidCallback? onLockedTap;

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

  bool get _isLocked => widget.isNavigationLocked;

  @override
  void initState() {
    super.initState();
    _timeStr = DateTime.now().formattedTime;
    _clockStream = Stream.periodic(const Duration(seconds: 1), (_) => _timeStr);
  }

  @override
  void didUpdateWidget(covariant DashboardAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kilit, bir alt menü açıkken devreye girerse açık menü kapatılır —
    // ardından build zaten çalışacağı için setState gerekmez.
    if (!oldWidget.isNavigationLocked && widget.isNavigationLocked && _overlay != null) {
      _overlay?.remove();
      _overlay = null;
      _openMenuId = null;
    }
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  /// Kilitliyken [action] yerine onLockedTap çalışır.
  VoidCallback? _lockAware(VoidCallback? action) => _isLocked ? widget.onLockedTap : action;

  void _toggleMenu(int id) {
    if (!widget.isLoggedIn) return;

    if (_isLocked) {
      widget.onLockedTap?.call();
      return;
    }

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
    final actionOpacity = _isLocked ? _kLockedOpacity : 1.0;

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: MedColors.surface, borderRadius: MedRadius.lgAll, boxShadow: MedShadows.md),
      child: Row(
        children: [
          _AppLogo(onTap: _lockAware(widget.onHomeTap)),
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
                isLocked: _isLocked,
                onTap: () => _toggleMenu(id),
              ),
            );
          }),
          const Spacer(),
          StreamBuilder<String>(
            stream: _clockStream,
            initialData: _timeStr,
            builder: (_, snap) => _ClockLabel(time: snap.data ?? _timeStr),
          ),

          SizedBox(width: 10),
          if (!widget.isLoggedIn)
            MedButton(
              prefixIcon: Icon(PhosphorIcons.signIn()),
              variant: MedButtonVariant.primary,
              onPressed: widget.onLoginTap,
              label: context.l10n.auth_loginButton,
              size: MedButtonSize.sm,
            )
          else if (widget.user != null)
            _UserInfo(user: widget.user!),

          const SizedBox(width: 16),

          if (widget.isLoggedIn) ...[
            Opacity(
              opacity: actionOpacity,
              child: MedRectangleIconButton(
                iconData: PhosphorIcons.gearSix(),
                tooltip: context.l10n.settings_title,
                onPressed: _lockAware(widget.onSettingsTap),
                borderColor: MedColors.border,
                size: 40,
              ),
            ),
            const SizedBox(width: 10),
            Opacity(
              opacity: actionOpacity,
              child: MedRectangleIconButton(
                tooltip: context.l10n.dashboard_logoutTooltip,
                borderColor: MedColors.red,
                iconData: PhosphorIcons.signOut(),
                color: MedColors.red,
                iconColor: Colors.white,
                onPressed: _lockAware(widget.onLogoutTap),
                size: 40,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

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
              context.l10n.dashboard_appBarTitle,
              style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isMenuOpen,
    required this.isLoggedIn,
    required this.isLocked,
    this.onTap,
  });

  final MenuItem item;
  final bool isActive;
  final bool isMenuOpen;
  final bool isLoggedIn;

  /// Kabin işlemi kilidi — oturum kilidinden (isLoggedIn) ayrı. Dokunuş
  /// yine onTap'e gider; kilit mesajını üst widget gösterir.
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool highlight = isActive || isMenuOpen;
    final locale = Localizations.localeOf(context);
    final localizedName = item.localizedName(locale);
    final showLockIcon = !isLoggedIn || isLocked;

    final double opacity = switch ((isLoggedIn, isLocked)) {
      (false, _) => 0.3,
      (true, true) => _kLockedOpacity,
      (true, false) => 1.0,
    };

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: isLoggedIn ? onTap : null,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizedName,
                style: TextStyle(
                  fontFamily: MedFonts.sans,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: highlight ? MedColors.blue : MedColors.text3,
                ),
              ),
              if (showLockIcon) ...[
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

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(
            user.initials,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.fullName,
              style: const TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MedColors.text,
              ),
            ),
            Text(
              user.roleName.toUpperCase(),
              style: const TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                color: MedColors.text3,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
