// lib/shared/widgets/organisms/app_top_bar.dart
//
// [SWREQ-UI-TOP-001]
// Sabit üst çubuk. Tüm ekranlarda kullanılır.
// Giriş yapılmamışsa login butonu, yapılmışsa kullanıcı chip + çıkış.
// Sınıf: Class A (görsel navigasyon, iş kararı vermez)

import 'package:flutter/material.dart';
import '../../../features/dashboard/domain/model/app_model.dart';
import '../atoms/atoms.dart';

class AppTopBar extends StatefulWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.cabinCode,
    required this.cabinLocation,
    required this.isOnline,
    required this.alertCount,
    this.user,
    this.onLoginTap,
    this.onLogoutTap,
    this.onUserTap,
  });

  final String cabinCode;

  /// Örn: "Kat 3 · Koridor B"
  final String cabinLocation;

  final bool isOnline;
  final int alertCount;

  /// null → giriş yapılmamış
  final AppUser? user;

  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onUserTap;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  late String _timeStr;
  late final Stream<String> _clockStream;

  @override
  void initState() {
    super.initState();
    _timeStr = _formatTime(DateTime.now());
    // Her saniye saat güncellenir
    _clockStream = Stream.periodic(const Duration(seconds: 1), (_) => _formatTime(DateTime.now()));
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border, width: 1.5)),
        boxShadow: MedShadows.sm,
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),

          // ── Brand ───────────────────────────────────────────
          _Brand(),

          _Separator(),

          // ── Lokasyon chip ────────────────────────────────────
          _LocationChip(location: widget.cabinLocation, cabinCode: widget.cabinCode),

          // ── Sistem durumu ─────────────────────────────────────
          const SizedBox(width: 12),
          _SystemBadge(isOnline: widget.isOnline, alertCount: widget.alertCount),

          const Spacer(),

          // ── Saat ─────────────────────────────────────────────
          StreamBuilder<String>(
            stream: _clockStream,
            initialData: _timeStr,
            builder: (_, snap) => _ClockChip(time: snap.data ?? _timeStr),
          ),

          _Separator(),

          // ── Auth alanı ────────────────────────────────────────
          if (widget.user == null)
            _LoginButton(onTap: widget.onLoginTap)
          else
            _UserArea(user: widget.user!, onUserTap: widget.onUserTap, onLogoutTap: widget.onLogoutTap),

          const SizedBox(width: 20),
        ],
      ),
    );
  }
}

// ── Brand ─────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: MedColors.blue, borderRadius: MedRadius.mdAll),
          child: const Icon(Icons.add_box_outlined, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
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
              'İLAÇ KABİNİ YÖNETİMİ',
              style: TextStyle(fontFamily: MedFonts.mono, fontSize: 8, letterSpacing: 1.5, color: MedColors.text3),
            ),
          ],
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 24, color: MedColors.border, margin: const EdgeInsets.symmetric(horizontal: 16));
  }
}

// ── Lokasyon chip ─────────────────────────────────────────────────

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location, required this.cabinCode});

  final String location;
  final String cabinCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        border: Border.all(color: const Color(0xFFC4D9F5)),
        borderRadius: MedRadius.xlAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined, size: 10, color: MedColors.blue),
          const SizedBox(width: 5),
          Text(
            '$location · Kabin #$cabinCode',
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, letterSpacing: 0.5, color: MedColors.blue),
          ),
        ],
      ),
    );
  }
}

// ── Sistem durumu ─────────────────────────────────────────────────

class _SystemBadge extends StatelessWidget {
  const _SystemBadge({required this.isOnline, required this.alertCount});

  final bool isOnline;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _badge(
          dot: StatusDot(color: isOnline ? MedColors.green : MedColors.red, size: 5),
          label: isOnline ? 'Sistem Çevrimiçi' : 'Bağlantı Yok',
          bg: isOnline ? MedColors.greenLight : MedColors.redLight,
          fg: isOnline ? MedColors.green : MedColors.red,
        ),
        if (alertCount > 0) ...[
          const SizedBox(width: 8),
          _badge(
            dot: _PulsingDot(color: MedColors.amber),
            label: '$alertCount Uyarı',
            bg: MedColors.amberLight,
            fg: MedColors.amber,
          ),
        ],
      ],
    );
  }

  Widget _badge({required Widget dot, required String label, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: MedRadius.xlAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, letterSpacing: 1, color: fg),
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.4 + _c.value * 0.6,
        child: StatusDot(color: widget.color, size: 5),
      ),
    );
  }
}

// ── Saat ──────────────────────────────────────────────────────────

class _ClockChip extends StatelessWidget {
  const _ClockChip({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: MedColors.text2,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Auth alanı ────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  const _LoginButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: MedColors.blue,
          borderRadius: MedRadius.mdAll,
          boxShadow: const [BoxShadow(color: Color(0x4D1A6BD8), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.login_rounded, size: 13, color: Colors.white),
            const SizedBox(width: 7),
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

class _UserArea extends StatelessWidget {
  const _UserArea({required this.user, this.onUserTap, this.onLogoutTap});

  final AppUser user;
  final VoidCallback? onUserTap;
  final VoidCallback? onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kullanıcı chip
        GestureDetector(
          onTap: onUserTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 12, 5),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border, width: 1.5),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MedColors.blue, Color(0xFF3B8FE8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontFamily: MedFonts.title,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                    ),
                    Text(user.role.toUpperCase(), style: MedTextStyles.monoXs()),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Çıkış butonu
        GestureDetector(
          onTap: onLogoutTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: MedColors.border),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 11, color: MedColors.text3),
                const SizedBox(width: 3),
                Text('Çıkış', style: MedTextStyles.bodySm(color: MedColors.text3)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
