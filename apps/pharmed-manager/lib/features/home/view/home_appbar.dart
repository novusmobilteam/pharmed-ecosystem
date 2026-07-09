// lib/shared/widgets/manager_app_bar.dart
//
// PharMed Manager — Uygulama üst çubuğu.
// Menü navigasyonu sidebar'da olduğundan bu widget sadece:
//   - Marka / anasayfa butonu
//   - Canlı saat
//   - Kullanıcı bilgisi (ad + rol)
//   - Çıkış butonu
//   - Ayarlar butonu (opsiyonel, kDebugMode'da ek aksiyonlar için)
//
// KULLANIM (HomeScreen içinde):
//   Column(
//     children: [
//       HomeAppBar(
//         user: notifier.currentUser,
//         isLoggedIn: notifier.isLoggedIn,
//         onHomeTap: () => notifier.navigateHome(),
//         onLogoutTap: () => context.read<AuthNotifier>().logout(),
//         onSettingsTap: () => _openSettingsDialog(context),
//       ),
//       Expanded(child: Row(children: [AppSidebar(), ...])),
//     ],
//   )
//
// Sınıf: Class A

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
  Size get preferredSize => const Size.fromHeight(62); // 52 + 10 padding üst

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
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
            // ── Marka ───────────────────────────────────────────
            _AppLogo(onTap: widget.onHomeTap),
            _Divider(),

            // ── Uygulama etiketi ─────────────────────────────────
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

            // ── Canlı saat ───────────────────────────────────────
            StreamBuilder<String>(
              stream: Stream.periodic(const Duration(seconds: 1), (_) => _formatTime(DateTime.now())),
              initialData: _formatTime(DateTime.now()),
              builder: (_, snap) => _ClockLabel(time: snap.data!),
            ),

            _Divider(),

            // ── Kullanıcı alanı ──────────────────────────────────
            if (!widget.isLoggedIn)
              _LoginButton(onTap: widget.onLoginTap) // 🆕 artık çalışıyor
            else if (widget.user != null)
              _UserInfo(user: widget.user!),

            const SizedBox(width: 10),

            // ── Debug ayarlar ────────────────────────────────────
            if (kDebugMode && widget.isLoggedIn) ...[
              _BarIconButton(
                icon: PhosphorIcons.wrench(),
                tooltip: context.l10n.home_devSettingsTooltip,
                onTap: widget.onSettingsTap,
              ),
              const SizedBox(width: 4),
            ],

            // ── Çıkış ────────────────────────────────────────────
            if (widget.isLoggedIn)
              _BarIconButton(
                icon: PhosphorIcons.signOut(),
                tooltip: context.l10n.dashboard_logoutTooltip,
                danger: true,
                onTap: widget.onLogoutTap,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Alt bileşenler (değişmeyen) ───────────────────────────────────────────────

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

class _LoginButton extends StatelessWidget {
  const _LoginButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.signIn(), size: 13, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              context.l10n.dashboard_loginBarButton,
              style: const TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
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

class _BarIconButton extends StatelessWidget {
  const _BarIconButton({required this.icon, required this.tooltip, this.onTap, this.danger = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? MedColors.red : MedColors.text2;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.mdAll,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: danger ? MedColors.redLight : Colors.transparent,
            border: Border.all(color: danger ? const Color(0x33DC2626) : MedColors.border),
            borderRadius: MedRadius.mdAll,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 20,
      color: MedColors.border2,
      margin: const EdgeInsets.symmetric(horizontal: 14),
    );
  }
}
