import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

// ─────────────────────────────────────────────────────────────────
// CabinActionBar
// [SWREQ-UI-003] [HAZ-009]
// Kabin üzerindeki Aç / Kilitle / İlaç Ata butonları.
//
// KRİTİK KURAL: Hiçbir callback doğrudan tetiklenemez.
// Her aksiyon dışarıda MedConfirmationDialog geçirmek zorundadır.
// Bu organism yalnızca kullanıcı niyetini bildirir (onOpen, onLock, onAssign).
// Aksiyon tetikleme kararı ve onay sorumluluğu çağıran taraftadır.
//
// isEnabled: false → tüm butonlar disabled (error/stale state'de)
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class CabinActionBar extends StatelessWidget {
  const CabinActionBar({super.key, required this.isEnabled, this.onOpen, this.onLock, this.onAssign});

  /// [HAZ-009] false → tüm butonlar devre dışı
  /// UiState.error(canProceed: false) → isEnabled: false geçilmeli
  final bool isEnabled;

  /// Kullanıcı "Aç" butonuna bastı sinyali.
  /// Çağıran taraf MedConfirmationDialog göstermekle yükümlü.
  final VoidCallback? onOpen;

  /// Kullanıcı "Kilitle" butonuna bastı sinyali.
  final VoidCallback? onLock;

  /// Kullanıcı "İlaç Ata" butonuna bastı sinyali.
  final VoidCallback? onAssign;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Aç + Kilitle — yan yana
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: 'Aç',
                icon: Icons.lock_open_outlined,
                variant: _ActionVariant.green,
                isEnabled: isEnabled,
                onTap: onOpen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                label: 'Kilitle',
                icon: Icons.lock_outlined,
                variant: _ActionVariant.red,
                isEnabled: isEnabled,
                onTap: onLock,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // İlaç Ata — tam genişlik
        _ActionButton(
          label: 'İlaç Ata',
          icon: Icons.add,
          variant: _ActionVariant.blue,
          isEnabled: isEnabled,
          onTap: onAssign,
          fullWidth: true,
        ),
      ],
    );
  }
}

// ── Buton varyantları ─────────────────────────────────────────────

enum _ActionVariant { green, red, blue }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.variant,
    required this.isEnabled,
    this.onTap,
    this.fullWidth = false,
  });

  final String label;
  final IconData icon;
  final _ActionVariant variant;
  final bool isEnabled;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);
    final effectiveEnabled = isEnabled && onTap != null;

    return AnimatedOpacity(
      opacity: effectiveEnabled ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: effectiveEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: colors.border, width: 1.5),
            borderRadius: MedRadius.mdAll,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: colors.foreground),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: MedFonts.title,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: colors.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _ActionColors _resolveColors(_ActionVariant variant) {
    return switch (variant) {
      _ActionVariant.green => _ActionColors(MedColors.green, MedColors.green),
      _ActionVariant.red => _ActionColors(MedColors.red, MedColors.red),
      _ActionVariant.blue => _ActionColors(MedColors.blue, MedColors.blue),
    };
  }
}

final class _ActionColors {
  const _ActionColors(this.border, this.foreground);
  final Color border;
  final Color foreground;
}
