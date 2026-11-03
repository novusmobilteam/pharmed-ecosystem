part of '../view/drug_form_panel.dart';

/// [SWREQ-MGR-MEDICINE-001] İlacın muadilleri — salt okunur liste.
///
/// Kaynak: `Material/equivalentMaterials/{id}` (kayıtlı muadil koduna göre).
/// Formda muadil kodu değiştirilip henüz kaydedilmediyse liste eski kodu yansıtır.
class _EquivalentMedicinesSection extends StatelessWidget {
  const _EquivalentMedicinesSection();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DrugFormNotifier>();
    final l10n = context.l10n;

    if (vm.isLoadingEquivalents) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: MedSpacing.lg),
        child: Center(child: MedLoadingIndicator()),
      );
    }

    final error = vm.equivalentsError;
    if (error != null) {
      return _EquivalentsMessage(
        icon: Icons.error_outline,
        color: MedColors.red,
        text: l10n.medicine_equivalents_loadErrorMessage,
        action: TextButton(onPressed: vm.loadEquivalents, child: Text(l10n.common_retryButton)),
      );
    }

    final items = vm.equivalents;
    if (items.isEmpty) {
      return _EquivalentsMessage(
        icon: Icons.info_outline,
        color: MedColors.text3,
        text: l10n.medicine_equivalents_emptyMessage,
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: MedColors.border2),
        borderRadius: MedRadius.smAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, m) in items.indexed) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: MedColors.border2),
            _EquivalentMedicineRow(medicine: m),
          ],
        ],
      ),
    );
  }
}

class _EquivalentMedicineRow extends StatelessWidget {
  const _EquivalentMedicineRow({required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context) {
    final drug = medicine is Drug ? medicine as Drug : null;
    final details = [
      medicine.barcode,
      drug?.firm?.name,
      drug?.dosageForm?.name,
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' · ');
    final isActive = drug?.isActive ?? true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.md, vertical: 10),
      child: Row(
        spacing: MedSpacing.md,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  medicine.name ?? '-',
                  style: MedTextStyles.bodyMd(color: MedColors.text, weight: FontWeight.w600),
                ),
                if (details.isNotEmpty) Text(details, style: MedTextStyles.bodySm(color: MedColors.text3)),
              ],
            ),
          ),
          if (!isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: MedColors.surface3, borderRadius: MedRadius.smAll),
              child: Text(
                context.l10n.medicine_equivalents_inactiveBadge,
                style: MedTextStyles.bodySm(color: MedColors.text3),
              ),
            ),
        ],
      ),
    );
  }
}

class _EquivalentsMessage extends StatelessWidget {
  const _EquivalentsMessage({required this.icon, required this.color, required this.text, this.action});

  final IconData icon;
  final Color color;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: MedSpacing.sm,
      children: [
        Icon(icon, size: 18, color: color),
        Expanded(
          child: Text(text, style: MedTextStyles.bodySm(color: color)),
        ),
        ?action,
      ],
    );
  }
}
