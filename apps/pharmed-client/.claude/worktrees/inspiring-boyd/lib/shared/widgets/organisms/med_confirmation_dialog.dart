import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

// ─────────────────────────────────────────────────────────────────
// MedConfirmationDialog
// [SWREQ-UI-008] [HAZ-009]
// Geri alınamaz tüm aksiyonlar bu dialog üzerinden geçer.
// Kapsam: kabin açma, kilitleme, dolum, sayım, boşaltma, ilaç atama.
//
// KRİTİK KURALLAR:
// 1. Dialog dışına tıklayarak kapatılamaz (barrierDismissible: false).
// 2. confirmLabel kırmızı — geri alınamaz olduğunu kullanıcıya bildirir.
// 3. onConfirm yalnızca kullanıcı açıkça onaylarsa tetiklenir.
//
// Kullanım:
//   await showDialog<bool>(
//     context: context,
//     barrierDismissible: false,          // [HAZ-009]
//     builder: (_) => MedConfirmationDialog(
//       title: 'Kabini Aç',
//       description: 'CB-304 kabini açılacak. Onaylıyor musunuz?',
//       confirmLabel: 'Evet, Aç',
//       cancelLabel: 'İptal',
//       onConfirm: () => notifier.openCabin(),
//       onCancel: () => Navigator.of(context).pop(),
//     ),
//   );
//
// Sınıf: Class B
// ─────────────────────────────────────────────────────────────────

class MedConfirmationDialog extends StatelessWidget {
  const MedConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
    this.icon,
    this.isDangerous = true,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  /// Opsiyonel ikon — varsayılan: uyarı ikonu
  final IconData? icon;

  /// true → confirm butonu kırmızı (geri alınamaz işlem)
  /// false → confirm butonu mavi (geri alınabilir işlem)
  final bool isDangerous;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: MedRadius.lgAll),
      backgroundColor: MedColors.surface,
      child: SizedBox(
        width: 400,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── İkon + Başlık ─────────────────────────────
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDangerous ? MedColors.redLight : MedColors.blueLight,
                      borderRadius: MedRadius.mdAll,
                    ),
                    child: Icon(
                      icon ?? Icons.warning_amber_rounded,
                      size: 18,
                      color: isDangerous ? MedColors.red : MedColors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: MedTextStyles.titleSm(
                        color: MedColors.text,
                      ).copyWith(fontSize: 15, letterSpacing: 0, textBaseline: TextBaseline.alphabetic),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Açıklama ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MedColors.surface2,
                  border: Border.all(color: MedColors.border2),
                  borderRadius: MedRadius.mdAll,
                ),
                child: Text(description, style: MedTextStyles.bodySm(color: MedColors.text2)),
              ),

              const SizedBox(height: 20),

              // ── Butonlar ──────────────────────────────────
              Row(
                children: [
                  // İptal
                  Expanded(
                    child: _DialogButton(label: cancelLabel, variant: _DialogButtonVariant.cancel, onTap: onCancel),
                  ),
                  const SizedBox(width: 8),
                  // Onayla
                  Expanded(
                    child: _DialogButton(
                      label: confirmLabel,
                      variant: isDangerous ? _DialogButtonVariant.danger : _DialogButtonVariant.confirm,
                      onTap: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dialog butonu ─────────────────────────────────────────────────

enum _DialogButtonVariant { cancel, confirm, danger }

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.variant, required this.onTap});

  final String label;
  final _DialogButtonVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      _DialogButtonVariant.cancel => (MedColors.surface2, MedColors.text2, MedColors.border),
      _DialogButtonVariant.confirm => (MedColors.blue, Colors.white, MedColors.blue),
      _DialogButtonVariant.danger => (MedColors.red, Colors.white, MedColors.red),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: MedRadius.mdAll,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(fontFamily: MedFonts.title, fontSize: 12, fontWeight: FontWeight.w700, color: fg),
        ),
      ),
    );
  }
}
