part of 'home_screen.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
    required this.isLoggedIn,
    this.user,
    this.onHomeTap,
    this.onLogoutTap,
    this.onSettingsTap,
    this.onLoginTap,
  });

  final bool isLoggedIn;
  final AppUser? user;

  final VoidCallback? onHomeTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onLoginTap;

  @override
  Size get preferredSize => const Size.fromHeight(62);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  late String _timeStr;
  late final Stream<String> _clockStream;

  @override
  void initState() {
    super.initState();
    _timeStr = DateTime.now().formattedTime;
    _clockStream = Stream.periodic(const Duration(seconds: 1), (_) => _timeStr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MedColors.bg,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: MedRadius.lgAll,
          border: Border.all(color: MedColors.border),
          boxShadow: MedShadows.sm,
        ),
        child: Row(
          children: [
            _AppLogo(onTap: widget.onHomeTap),
            SizedBox(width: 10),
            Text(
              context.l10n.home_appBarBadgeLabel,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: MedColors.text3,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            StreamBuilder<String>(
              stream: _clockStream,
              initialData: _timeStr,
              builder: (_, snap) => _ClockLabel(time: snap.data ?? _timeStr),
            ),

            SizedBox(width: 10),

            if (!widget.isLoggedIn)
              MedRectangleIconButton(
                iconData: PhosphorIcons.signIn(),
                color: MedColors.blue,
                iconColor: Colors.white,
                onPressed: widget.onLoginTap,
              )
            else if (widget.user != null)
              _UserInfo(user: widget.user!),

            const SizedBox(width: 10),

            if (kDebugMode && widget.isLoggedIn) ...[
              MedRectangleIconButton(
                iconData: PhosphorIcons.gear(),
                borderColor: MedColors.border,
                tooltip: context.l10n.home_devSettingsTooltip,
                onPressed: widget.onSettingsTap,
              ),
              const SizedBox(width: 5),
            ],

            if (widget.isLoggedIn)
              MedRectangleIconButton(
                iconData: PhosphorIcons.signOut(),
                iconColor: Colors.white,
                tooltip: context.l10n.dashboard_logoutTooltip,
                color: MedColors.red,
                onPressed: widget.onLogoutTap,
              ),
          ],
        ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(7)),
              child: Icon(PhosphorIcons.pill(), size: 15, color: Colors.white),
            ),
            const SizedBox(width: 9),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: MedFonts.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
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
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: MedColors.text3,
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
