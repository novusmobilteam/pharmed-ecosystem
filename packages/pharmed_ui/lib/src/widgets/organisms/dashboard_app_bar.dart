// [SWREQ-UI-TOP-001]
// Sabit üst çubuk. Tüm ekranlarda kullanılır.
// Giriş yapılmamışsa login butonu, yapılmışsa kullanıcı chip + çıkış.
// Sınıf: Class A (görsel navigasyon, iş kararı vermez)

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class DashboardAppBar extends StatefulWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.cabinLocation,
    required this.cabinName,
    this.user,
    this.onLoginTap,
    this.onLogoutTap,
    this.onUserTap,
  });

  /// Örn: "Kat 3 · Koridor B"
  final String cabinLocation;
  final String cabinName;

  final AppUser? user;

  final VoidCallback? onLoginTap;
  final VoidCallback? onLogoutTap;
  final VoidCallback? onUserTap;

  @override
  State<DashboardAppBar> createState() => _DashboardAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(52);
}

class _DashboardAppBarState extends State<DashboardAppBar> {
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
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(color: MedColors.surface),
      child: Row(
        children: [
          // Logo
          _AppLogo(),
          _Separator(),

          // Kabin Bilgileri
          //_LocationChip(location: widget.cabinLocation, cabinName: widget.cabinName),
          const Spacer(),

          // Saat
          StreamBuilder<String>(
            stream: _clockStream,
            initialData: _timeStr,
            builder: (_, snap) => _ClockChip(time: snap.data ?? _timeStr),
          ),
          SizedBox(width: 14.0),

          if (widget.user == null)
            _LoginButton(onTap: widget.onLoginTap)
          else
            _UserArea(user: widget.user!, onUserTap: widget.onUserTap, onLogoutTap: widget.onLogoutTap),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
              'İLAÇ KABİN YÖNETİMİ',
              style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, color: MedColors.text3),
            ),
          ],
        ),
      ],
    );
  }
}

// ignore: unused_element
class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.location, required this.cabinName});

  final String location;
  final String cabinName;

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
            '$location · $cabinName',
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 10, letterSpacing: 0.5, color: MedColors.blue),
          ),
        ],
      ),
    );
  }
}

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
        borderRadius: MedRadius.smAll,
      ),
      child: Text(
        time,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: MedColors.text2,
          letterSpacing: 1,
        ),
      ),
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
        GestureDetector(
          onTap: onUserTap,
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: MedColors.surface2,
              border: Border.all(color: MedColors.border, width: 1.5),
              borderRadius: MedRadius.mdAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24.0,
                  height: 24.0,
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
                SizedBox(width: 12),
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
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: MedColors.red, borderRadius: MedRadius.mdAll),
            child: Row(
              spacing: 5.0,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, size: 14, color: MedColors.surface),
                Text('Çıkış Yap', style: MedTextStyles.bodySm(color: MedColors.surface)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 30, color: MedColors.border, margin: const EdgeInsets.symmetric(horizontal: 16));
  }
}
