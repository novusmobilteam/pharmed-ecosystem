// footer/operation_dialog_footer.dart
import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Footer içeriği — her dialog kendi state'inden hesaplar.
class FooterContent {
  const FooterContent({required this.hint, required this.actions});
  final String hint;
  final List<Widget> actions;
}

/// Tüm kabin işlem dialog'larında ortak footer kabuğu.
class OperationDialogFooter extends StatelessWidget {
  const OperationDialogFooter({super.key, required this.content});

  final FooterContent content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: MedColors.bg,
        border: Border(top: BorderSide(color: MedColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(content.hint, style: MedTextStyles.bodySm(color: MedColors.text3)),
          ),
          if (content.actions.isNotEmpty) const SizedBox(width: MedSpacing.sm),
          ...content.actions,
        ],
      ),
    );
  }
}

/// Footer action butonu kısayolları — dört dialog'da tekrar eden kalıplar.
class FooterActions {
  /// Primary aksiyon (tamamla). [onPressed] null ise disabled.
  static Widget primary(String label, VoidCallback? onPressed) =>
      MedButton(label: label, size: MedButtonSize.sm, onPressed: onPressed);

  static Widget secondary(String label, VoidCallback? onPressed) =>
      MedButton(label: label, size: MedButtonSize.sm, onPressed: onPressed, variant: MedButtonVariant.secondary);

  /// "Tekrar Dene" — Error state'inde.
  static Widget retry(VoidCallback onPressed) =>
      MedButton(label: 'Tekrar Dene', size: MedButtonSize.sm, onPressed: onPressed);

  /// "Tamam" — FatalError dismiss.
  static Widget dismiss(VoidCallback onPressed) =>
      MedButton(label: 'Tamam', size: MedButtonSize.sm, variant: MedButtonVariant.danger, onPressed: onPressed);

  /// Loading butonu — Saving.
  static Widget saving() =>
      MedButton(label: 'Kaydediliyor...', size: MedButtonSize.sm, isLoading: true, onPressed: null);
}
