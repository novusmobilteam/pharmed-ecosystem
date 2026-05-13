// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

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
  (String label, String? value) get _activityRow {
    final label = switch (item.status) {
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

    final user = item.activityUser?.fullName;
    final date = item.activityDate?.formattedDate;

    final value = switch ((user, date)) {
      (final u?, final d?) => '$u · $d',
      (final u?, null) => u,
      (null, final d?) => d,
      _ => null,
    };

    return (label, value);
  }

  String? get _serviceName => item.physicalService?.name ?? item.inpatientService?.name;

  String? get _doctorName => item.doctor?.fullName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(MedSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected ? MedColors.blueLight : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 1.5),
          borderRadius: MedRadius.lgAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TopRow(item: item, isSelected: isSelected),
            const SizedBox(height: MedSpacing.lg),
            Divider(height: 1),
            const SizedBox(height: MedSpacing.lg),
            _MetaGrid(
              item: item,
              isSelected: isSelected,
              activityRow: _activityRow,
              serviceName: _serviceName,
              doctorName: _doctorName,
            ),
            const SizedBox(height: MedSpacing.lg),
            InfoChip(
              info: item.status?.label,
              backgroundColor: item.status?.backgroundColor,
              foregroundColor: item.status?.color,
            ),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MedCheckbox(value: isSelected, onChanged: (value) {}),
        const SizedBox(width: MedSpacing.lg),
        Expanded(
          child: Text(
            item.medicine?.name ?? '—',
            style: MedTextStyles.bodyLg(color: isSelected ? MedColors.blue : MedColors.text, weight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: MedSpacing.lg),
        MedDoseChip(item: item),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({
    required this.item,
    required this.isSelected,
    required this.activityRow,
    required this.serviceName,
    required this.doctorName,
  });

  final PrescriptionItem item;
  final bool isSelected;
  final (String, String?) activityRow;
  final String? serviceName;
  final String? doctorName;

  @override
  Widget build(BuildContext context) {
    final (actLabel, actValue) = activityRow;

    // Her zaman gösterilecek satırlar
    final entries = <(String, String?)>[
      (actLabel, actValue),
      if (item.dosePiece != null)
        ('Doz', '${item.dosePiece!.formatFractional} ${item.medicine?.operationUnit ?? 'Adet'}'),
      if (serviceName != null) ('Servis', serviceName),
      if (doctorName != null) ('Doktor', doctorName),
      if (item.prescriptionDate != null) ('Reçete Tarihi', item.prescriptionDate!.formattedDate),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: MedSpacing.xl4 * 2,
      children: entries.map((e) => _MetaItem(label: e.$1, value: e.$2, isSelected: isSelected)).toList(),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.label, required this.value, required this.isSelected});

  final String label;
  final String? value;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: MedTextStyles.monoXs(color: isSelected ? MedColors.blue.withAlpha(128) : MedColors.text4),
        ),
        const SizedBox(height: 2),
        Text(
          value ?? '—',
          style: MedTextStyles.bodySm(
            color: isSelected ? MedColors.blue.withAlpha(217) : MedColors.text2,
            weight: FontWeight.w500,
          ),
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
