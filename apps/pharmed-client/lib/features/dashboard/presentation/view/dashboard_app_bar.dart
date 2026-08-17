// [SWREQ-UI-TOP-001] [IEC 62304 §5.5]
// Dashboard üst çubuğu — appbar + navigasyon tek widget'ta.
// Giriş yapılmamışsa menüler disabled, giriş yap butonu gösterilir.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
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
    required this.isActiveRouteDashboard,
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
  final bool isActiveRouteDashboard;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();
}

class _DashboardAppBarState extends State<DashboardAppBar> {
  late String _timeStr;
  late final Stream<String> _clockStream;

  OverlayEntry? _overlay;

  @override
  void initState() {
    super.initState();
    _timeStr = DateTime.now().formattedTime;
    _clockStream = Stream.periodic(const Duration(seconds: 1), (_) => _timeStr);
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border, width: 1.5)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          _AppLogo(onTap: widget.onHomeTap),
          const Spacer(),
          StreamBuilder<String>(
            stream: _clockStream,
            initialData: _timeStr,
            builder: (_, snap) => _ClockLabel(time: snap.data ?? _timeStr),
          ),

          SizedBox(width: 10),
          if (!widget.isLoggedIn && widget.isActiveRouteDashboard)
            MedRectangleButton(
              height: 35,
              width: 150,
              foregroundColor: Colors.white,
              suffixIcon: PhosphorIcons.signIn(),
              onTap: widget.onLoginTap,
              label: context.l10n.auth_loginButton,
            )
          else if (widget.user != null)
            _UserInfo(user: widget.user!),

          const SizedBox(width: 16),

          if (widget.isLoggedIn && widget.isActiveRouteDashboard) ...[
            MedRectangleIconButton(
              iconData: PhosphorIcons.gearSix(),
              tooltip: context.l10n.settings_title,
              onPressed: widget.onSettingsTap,
              borderColor: MedColors.border,
              size: 40,
            ),
            const SizedBox(width: 10),
            MedRectangleIconButton(
              tooltip: context.l10n.dashboard_logoutTooltip,
              borderColor: MedColors.red,
              iconData: PhosphorIcons.signOut(),
              color: MedColors.red,
              iconColor: Colors.white,
              onPressed: widget.onLogoutTap,
              size: 40,
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
