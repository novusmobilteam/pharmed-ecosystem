// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
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

  // ── Yardımcılar ────────────────────────────────────────────────

  /// Status'a göre "kimin yaptığı"nı ve tarihini döner.
  ///
  /// Gösterilecek satır sayısını minimumda tutmak için
  /// [PrescriptionItem.activityUser] + [PrescriptionItem.activityDate]
  /// getter'ları kullanılır.
  String get activityLabel {
    return switch (item.status) {
      PrescriptionStatus.pendingApproval || PrescriptionStatus.filledWaiting => 'Oluşturan',
      PrescriptionStatus.purchasePending => 'Onaylayan',
      PrescriptionStatus.applied => 'Uygulayan',
      PrescriptionStatus.returned => 'İade Eden',
      PrescriptionStatus.wastaged => 'Fire Eden',
      PrescriptionStatus.destructed => 'İmha Eden',
      PrescriptionStatus.cancelled => 'İptal Eden',
      PrescriptionStatus.rejected => 'Reddeden',
      null => 'İşlem Yapan',
    };
  }

  String? get _activityUser => item.activityUser?.fullName;
  DateTime? get _activityDate => item.activityDate;
  String? get _doctorName => item.doctor?.fullName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(MedSpacing.xl),
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
            DottedDivider(),
            _MetaGrid(
              isSelected: isSelected,
              activityLabel: activityLabel,
              activityUser: _activityUser,
              doctorName: _doctorName,
              activityDate: _activityDate,
            ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: item.status?.backgroundColor, borderRadius: MedRadius.mdAll),
          child: Icon(PhosphorIcons.pill(), color: item.status?.color),
        ),
        const SizedBox(width: MedSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.medicine?.name ?? '—', style: MedTextStyles.titleMd(), overflow: TextOverflow.ellipsis),
            Text(dose, style: MedTextStyles.titleSm()),
          ],
        ),
        Spacer(),
        InfoChip(
          info: item.status?.label,
          backgroundColor: item.status?.backgroundColor,
          foregroundColor: item.status?.color,
        ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({
    required this.isSelected,
    required this.activityLabel,
    required this.activityUser,
    required this.doctorName,
    this.activityDate,
  });

  final bool isSelected;
  final String activityLabel;
  final String? activityUser;
  final String? doctorName;
  final DateTime? activityDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 24.0,
      children: [
        _MetaItem(label: 'Doktor', value: doctorName),
        _MetaItem(label: activityLabel, value: activityUser),
        Spacer(),
        if (activityDate != null) TimeChip(time: activityDate!),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: MedTextStyles.monoMd()),
        const SizedBox(height: 2),
        Text(
          value ?? '—',
          style: MedTextStyles.bodyLg(color: MedColors.text2, weight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  String get _unit => item.medicine?.operationUnit ?? 'Adet';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Miktar:', style: MedTextStyles.bodySm(color: MedColors.text3)),
        const SizedBox(width: MedSpacing.lg),
        DoseStepper.compact(
          value: quantity,
          onChanged: onChanged,
          unit: _unit,
          min: 0,
          max: maxQuantity,
          platform: DoseStepperPlatform.touch,
        ),
        if (maxQuantity != null) ...[
          const SizedBox(width: MedSpacing.md),
          Text('/ maks. ${maxQuantity!.formatFractional} $_unit', style: MedTextStyles.monoXs(color: MedColors.text4)),
        ],
      ],
    );
  }
}
