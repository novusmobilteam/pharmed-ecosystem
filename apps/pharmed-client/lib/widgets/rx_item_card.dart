import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/rx_movement_block.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// ─────────────────────────────────────────────────────────────────
// RxItemCard
// [SWREQ-UI-CARD-RX-001]
// Kullanım: İade, fire/imha gibi reçete işlem ekranlarındaki ilaç listesi
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Bir [PrescriptionItem]'ı seçilebilir kart olarak gösterir.
///
/// - İlaç adı, doz chip'i, status chip'i ve status'a göre ilgili
///   aktivite kullanıcısı + tarihi gösterilir.
/// - [showStepper] true olduğunda ve kart seçili iken [DoseStepper.compact]
///   inline olarak açılır; [onQuantityChanged] ile miktar değişimleri
///   iletilir.
/// - Seçim davranışı tamamen çağırana bırakılmıştır: [onTap] tetiklenince
///   [isSelected] toggle edilir.
///
/// ## Örnek
///
/// ```dart
/// RxItemCard(
///   item: prescriptionItem,
///   isSelected: state.selectedItem?.id == item.id,
///   isBusy: state.isBusy,
///   onTap: () => notifier.onDrugTap(item),
///   showStepper: true,
///   quantity: state.quantity ?? 0,
///   maxQuantity: item.refundableQuantity?.toDouble() ?? 0,
///   onQuantityChanged: notifier.onQuantityChanged,
/// )
/// ```
class RxItemCard extends StatelessWidget {
  const RxItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.isSelected = false,
    this.isBusy = false,
    this.showStepper = false,
    this.quantity = 0,
    this.maxQuantity,
    this.onQuantityChanged,
  }) : assert(!showStepper || onQuantityChanged != null, 'showStepper=true iken onQuantityChanged sağlanmalıdır.');

  /// Gösterilecek reçete kalemi.
  final PrescriptionItem item;

  /// Dokunma callback'i — seçim toggle'ı çağıran tarafından yönetilir.
  final VoidCallback onTap;

  /// Kartın seçili görünüp görünmeyeceği.
  final bool isSelected;

  /// Kontrol/kaydetme işlemi sırasında etkileşimi kilitler.
  final bool isBusy;

  /// Seçili durumda stepper gösterilsin mi?
  ///
  /// false (varsayılan) olduğunda stepper hiçbir zaman render edilmez;
  /// sadece meta bilgiler gösterilir. Reçete listesi gibi salt-okunur
  /// ekranlar için false bırakın.
  final bool showStepper;

  /// Stepper'ın mevcut değeri. [showStepper] true ise gereklidir.
  final double quantity;

  /// Stepper'ın maksimum değeri.
  ///
  /// null ise sınır yoktur.
  final double? maxQuantity;

  /// Stepper değeri değiştiğinde tetiklenir.
  ///
  /// [showStepper] true ise zorunludur.
  final ValueChanged<double>? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl4, vertical: MedSpacing.xl2),
        decoration: BoxDecoration(
          color: MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
          borderRadius: MedRadius.lgAll,
        ),
        child: Column(
          spacing: 12.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(item: item, isSelected: isSelected),
            MedDottedDivider(),
            RxMovementBlock(lastMovement: item.lastMovement, medicine: item.medicine),
            const SizedBox(height: MedSpacing.lg),
            if (showStepper && isSelected) ...[
              const SizedBox(height: MedSpacing.lg),
              Divider(height: 1),
              const SizedBox(height: MedSpacing.lg),
              _StepperRow(item: item, quantity: quantity, maxQuantity: maxQuantity, onChanged: onQuantityChanged!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.item, required this.isSelected});

  final PrescriptionItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final dose = '${item.dosePiece?.formatFractional} ${item.medicine?.operationUnit}';
    final hour = item.prescription?.prescriptionDate?.shortRelativeLabel ?? '-';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        MedRectangleIcon(
          backgroundColor: item.status?.backgroundColor ?? MedColors.blue,
          foregroundColor: item.status?.foregroundColor ?? Colors.white,
          icon: PhosphorIcons.pill(),
        ),

        const SizedBox(width: MedSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item.medicine?.name} ($hour)', style: MedTextStyles.titleMd(), overflow: TextOverflow.ellipsis),
            Text(dose, style: MedTextStyles.titleSm()),
          ],
        ),
        Spacer(),
        MedInfoChip(
          info: item.status?.label,
          backgroundColor: item.status?.backgroundColor,
          foregroundColor: item.status?.foregroundColor,
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({required this.item, required this.quantity, required this.maxQuantity, required this.onChanged});

  final PrescriptionItem item;
  final double quantity;
  final double? maxQuantity;
  final ValueChanged<double> onChanged;

  String _unit(BuildContext context) => item.medicine?.operationUnit ?? context.l10n.common_defaultUnitFallback;

  @override
  Widget build(BuildContext context) {
    final unit = _unit(context);
    return Row(
      children: [
        Text(context.l10n.movement_quantityLabel, style: MedTextStyles.bodySm(color: MedColors.text3)),
        const SizedBox(width: MedSpacing.lg),
        MedDoseStepper.compact(
          value: quantity,
          onChanged: onChanged,
          unit: unit,
          min: 0,
          max: maxQuantity,
          platform: DoseStepperPlatform.touch,
        ),
        if (maxQuantity != null) ...[
          const SizedBox(width: MedSpacing.md),
          Text(
            context.l10n.rxItemCard_maxQuantitySuffix(maxQuantity!.formatFractional, unit),
            style: MedTextStyles.monoXs(color: MedColors.text4),
          ),
        ],
      ],
    );
  }
}
