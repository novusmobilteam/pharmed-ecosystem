import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// [SWREQ-CORE-AUTH-002] Kullanıcının güncel istasyonda yetkisi yoksa gösterilen
/// tam ekran kilit. Tek eylem: Çıkış Yap.
///
/// Bilinçli olarak GestureDetector/onUserActivity ile sarılmadı: kiosk bu
/// ekranda bırakılırsa inactivity timer çalışmaya devam eder ve oturum
/// kendiliğinden kapanır.
class StationAccessDeniedScreen extends StatelessWidget {
  const StationAccessDeniedScreen({super.key, required this.user, required this.station, required this.onLogout});

  final AppUser user;
  final Station? station;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final fullName = '${user.name} ${user.surname}'.trim();
    final userName = fullName.isEmpty ? '—' : fullName;
    final stationName = station?.name ?? '—';

    return _LockScaffold(
      icon: Icons.lock_person_outlined,
      accent: MedColors.red,
      title: l10n.stationAccess_deniedTitle,
      description: l10n.stationAccess_deniedDescription,
      body: _InfoPanel(
        rows: [
          _InfoRow(icon: PhosphorIcons.user(), label: l10n.stationAccess_userLabel, value: userName),
          _InfoRow(
            icon: PhosphorIcons.dresser(),
            label: l10n.stationAccess_stationLabel,
            value: stationName,
            mono: true,
          ),
        ],
      ),
      actions: [
        MedButton(
          label: l10n.stationAccess_logoutButton,
          prefixIcon: Icon(PhosphorIcons.signOut()),
          variant: MedButtonVariant.error,
          onPressed: onLogout,
        ),
      ],
    );
  }
}

/// İstasyon / yetki bilgisi alınamadığında gösterilir. Yetki doğrulanamadığı
/// için kullanıcı içeri alınmaz; yalnızca tekrar dene veya çıkış.
class StationAccessVerifyErrorScreen extends StatelessWidget {
  const StationAccessVerifyErrorScreen({super.key, required this.onRetry, required this.onLogout});

  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _LockScaffold(
      icon: Icons.cloud_off_outlined,
      accent: MedColors.amber,
      title: l10n.stationAccess_verifyErrorTitle,
      description: l10n.stationAccess_verifyErrorDescription,
      actions: [
        MedButton(
          label: l10n.stationAccess_logoutButton,
          prefixIcon: Icon(PhosphorIcons.signOut()),
          variant: MedButtonVariant.error,
          onPressed: onLogout,
        ),
        MedButton(
          label: l10n.common_retryButton,
          prefixIcon: Icon(PhosphorIcons.arrowsCounterClockwise()),
          variant: MedButtonVariant.secondary,
          onPressed: onRetry,
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Ortak iskelet
// ───────────────────────────────────────────────────────────────────────────

/// Tasarım sistemindeki metin tonları. MedColors'ta karşılığı varsa
/// (ör. MedColors.text / textSecondary) onlarla değiştirin.
abstract final class _Ink {
  static const primary = Color(0xFF1A2332);
  static const secondary = Color(0xFF3D4F66);
  static const muted = Color(0xFF7A8FA8);
  static const surface2 = Color(0xFFF7F9FC);
}

class _LockScaffold extends StatelessWidget {
  const _LockScaffold({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.actions,
    this.body,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final Widget? body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MedColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MedSpacing.xl3),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Container(
                decoration: BoxDecoration(
                  color: MedColors.surface,
                  borderRadius: MedRadius.xl2All,
                  border: Border.all(color: MedColors.border),
                  boxShadow: MedShadows.md,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        MedSpacing.xl4,
                        MedSpacing.xl4,
                        MedSpacing.xl4,
                        MedSpacing.xl3,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _IconBadge(icon: icon, accent: accent),
                          const SizedBox(height: MedSpacing.xl2),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: MedTextStyles.titleLg().copyWith(color: _Ink.primary),
                          ),
                          const SizedBox(height: MedSpacing.md),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: MedTextStyles.bodyMd().copyWith(color: _Ink.secondary, height: 1.5),
                          ),
                          if (body != null) ...[const SizedBox(height: MedSpacing.xl3), body!],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(MedSpacing.xl2),
                      decoration: const BoxDecoration(
                        color: _Ink.surface2,
                        border: Border(top: BorderSide(color: MedColors.border)),
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < actions.length; i++) ...[
                            if (i > 0) const SizedBox(width: MedSpacing.lg),
                            Expanded(child: actions[i]),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 6),
      ),
      child: Icon(icon, size: 40, color: accent),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Ink.surface2,
        borderRadius: MedRadius.midAll,
        border: Border.all(color: MedColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: MedColors.border),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.mono = false});

  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _Ink.muted),
            const SizedBox(width: MedSpacing.lg),
            Text(label.toUpperCase(), style: MedTextStyles.monoSm().copyWith(color: _Ink.muted, letterSpacing: 0.8)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: MedTextStyles.bodyMd().copyWith(color: _Ink.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
