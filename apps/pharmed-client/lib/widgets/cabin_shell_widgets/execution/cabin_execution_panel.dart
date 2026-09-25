// [SWREQ-UI-CABINEXEC-001]
// Kabin işlem ekranlarının (dolum listesi, dolum, sayım) sağ panel iskeleti:
// üstte ilaç başlığı, ortada işleme özgü gövde, altta sabit footer.
// Ekrana göre değişen her şey parametreyle gelir; iskelet ve butonlar sabit.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Header, body ve footer'ı standart aralıkla dizer.
class CabinExecutionPanel extends StatelessWidget {
  const CabinExecutionPanel({super.key, required this.header, required this.body, required this.footer});

  final CabinExecutionHeader header;
  final Widget body;
  final CabinExecutionFooter footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12.0,
      children: [
        header,
        Expanded(child: CabinExecutionBody(child: body)),
        footer,
      ],
    );
  }
}

/// Başlıkta gösterilecek tek bir etiket/değer çifti.
class CabinExecutionInfoValue {
  const CabinExecutionInfoValue({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;

  /// Verilirse değer bu renkte ve bold çizilir (örn. dolum durumu rengi).
  final Color? valueColor;
}

class CabinExecutionHeader extends StatelessWidget {
  const CabinExecutionHeader({super.key, required this.medicineName, this.values = const [], this.trailing});

  final String medicineName;

  /// İşleme özgü bilgiler — dolumda hedef/doldurulan, sayımda mevcut miktar vb.
  /// Boş liste geçilebilir (örn. miktarı gösterilmeyen sayım tipleri).
  final List<CabinExecutionInfoValue> values;

  /// En sağda opsiyonel ek (örn. durum badge'i).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetXl,
      decoration: MedDecoration.panelDecoration,
      child: Row(
        spacing: 24.0,
        children: [
          Expanded(
            child: Text(medicineName, maxLines: 1, overflow: TextOverflow.ellipsis, style: MedTextStyles.titleLg()),
          ),
          for (final v in values) _InfoValueView(value: v),
          ?trailing,
        ],
      ),
    );
  }
}

class _InfoValueView extends StatelessWidget {
  const _InfoValueView({required this.value});

  final CabinExecutionInfoValue value;

  @override
  Widget build(BuildContext context) {
    final color = value.valueColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      spacing: 2,
      children: [
        Text(value.label, style: MedTextStyles.bodySm(color: MedColors.text3)),
        Text(
          value.value,
          style: color != null
              ? MedTextStyles.titleMd(color: color).copyWith(fontWeight: FontWeight.w700)
              : MedTextStyles.titleMd(),
        ),
      ],
    );
  }
}

/// Gövde çerçevesi — içerik (birim doz tablosu, kübik kart) ekrandan gelir.
class CabinExecutionBody extends StatelessWidget {
  const CabinExecutionBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.panelInsetPadding,
      decoration: MedDecoration.panelDecoration,
      child: child,
    );
  }
}

class CabinExecutionFooter extends StatelessWidget {
  const CabinExecutionFooter({
    super.key,
    required this.currentDrawer,
    required this.totalDrawers,
    this.onStop,
    this.onConfirm,
    this.isSaving = false,
  });

  /// Kaçıncı çekmecede olunduğu (1'den başlar) ve toplam çekmece sayısı.
  final int currentDrawer;
  final int totalDrawers;

  /// Onay dialog'undan SONRA çağrılır. null → durdurma pasif.
  final Future<void> Function()? onStop;

  /// null → onay pasif (çekmece açık değil, geçersiz giriş vb.).
  final VoidCallback? onConfirm;

  final bool isSaving;

  bool get _isLastDrawer => currentDrawer >= totalDrawers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetXl,
      decoration: MedDecoration.panelDecoration,
      child: Row(
        spacing: 12.0,
        children: [
          Expanded(
            child: Text(
              context.l10n.cabinExecution_queueProgress(currentDrawer, totalDrawers),
              style: MedTextStyles.titleSm(color: MedColors.text2),
            ),
          ),
          MedButton(
            label: context.l10n.cabinExecution_stopButton,
            variant: MedButtonVariant.error,
            onPressed: onStop == null || isSaving ? null : () => _confirmStop(context),
          ),
          MedButton(
            label: _isLastDrawer
                ? context.l10n.cabinExecution_saveAndFinishButton
                : context.l10n.cabinExecution_saveAndNextButton,
            variant: MedButtonVariant.success,
            isLoading: isSaving,
            onPressed: isSaving ? null : onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmStop(BuildContext context) async {
    MessageUtils.showConfirmDialog(
      context: context,
      onConfirm: () => onStop?.call(),
      action: ConfirmAction.delete,
      customTitle: context.l10n.cabinExecution_stopConfirmTitle,
      customMessage: context.l10n.cabinExecution_stopConfirmMessage,
      color: MedColors.red,
    );
  }
}
