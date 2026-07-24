// Master kabin dolum/sayım execution ekranlarının ortak form gövdesi.
// MasterRefillExecutionPanel._FillForm + MasterCensusExecutionPanel._CensusForm
// birleştirildi. İki bağımsız eksen parametreleştirildi:
//   - Çekmece tipi (kübik = tek giriş, birim doz = N giriş) → isKubik
//   - Operasyon tipi (dolum vs sayım) → showFilling (dolum alanının olup
//     olmadığı, kart seviyesinde uygulanır)
//
// Kartların kendisini de burada çiziyoruz (CabinCellInputCard) — çağıran
// panel yalnızca CabinCellEntry listesi + index bazlı callback'ler verir,
// widget ağacıyla hiç uğraşmaz. Tek-SKT (isPerCellMiadEnabled=false) header'ı
// da burada kurulur — çağıran yalnızca singleMiadDate + onSingleMiadChanged verir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../cabin_shell_widgets.dart';
import 'cabin_cell_input_card.dart';

/// Tek bir kübik gözün (ya da birim doz gözünün) mevcut giriş değerlerini
/// taşıyan generic veri sözleşmesi. RefillFillTarget/CensusTarget gibi farklı
/// domain modellerinin ortak paydası — çağıran panel kendi target'ını buna
/// map'ler.
class CabinCellEntry {
  const CabinCellEntry({
    required this.assignment,
    required this.current,
    this.countQuantity,
    this.fillingQuantity,
    required this.miadDate,
  });

  final MedicineAssignment assignment;
  final double current;
  final double? countQuantity;

  /// showFilling=false olan formlarda hiç okunmaz.
  final double? fillingQuantity;
  final DateTime? miadDate;
}

class CabinCellOperationForm extends StatelessWidget {
  const CabinCellOperationForm({
    super.key,
    required this.maxWidth,
    required this.isLocked,
    required this.isKubik,
    required this.entries,
    required this.onCountChanged,
    this.showFilling = false,
    this.onFillingChanged,
    this.isPerCellMiadEnabled = true,
    this.onMiadChanged,
    this.singleMiadDate,
    this.onSingleMiadChanged,
    this.stepLabelBuilder,
    required this.canConfirm,
    required this.isSaving,
    required this.confirmLabel,
    required this.onConfirm,
  }) : assert(!showFilling || onFillingChanged != null, 'showFilling true ise onFillingChanged zorunlu'),
       assert(
         isPerCellMiadEnabled || onSingleMiadChanged != null,
         'isPerCellMiadEnabled false ise onSingleMiadChanged zorunlu',
       );

  final double maxWidth;

  /// Kayıt/işlem sürerken (ör. isSaving) true — içerik kilitlenir, footer
  /// kilitlenmez (footer kendi loading/disabled durumunu kendi yönetir).
  final bool isLocked;

  /// true → tek göz (kübik, entries[0] kullanılır), false → N göz (birim doz).
  final bool isKubik;

  /// Kübikte tek elemanlı, birim dozda çekmecenin göz sayısı kadar.
  final List<CabinCellEntry> entries;

  /// (index, yeni sayım değeri).
  final void Function(int index, double value) onCountChanged;

  /// false ise kartlarda dolum alanı hiç gösterilmez (sayım ekranı).
  final bool showFilling;

  /// showFilling=true iken zorunlu. (index, yeni dolum değeri).
  final void Function(int index, double value)? onFillingChanged;

  /// false ise (tek-SKT fallback açıksa) kartların miad alanı gizlenir, üstte
  /// tek bir SKT header'ı gösterilir. Dolum'a özel; sayımda her zaman true.
  final bool isPerCellMiadEnabled;

  /// isPerCellMiadEnabled true iken kullanılır. (index, yeni SKT).
  final void Function(int index, DateTime? date)? onMiadChanged;

  /// isPerCellMiadEnabled false iken geçerli tek-SKT değeri.
  final DateTime? singleMiadDate;

  /// isPerCellMiadEnabled false iken zorunlu — tek-SKT değişince çağrılır.
  final ValueChanged<DateTime?>? onSingleMiadChanged;

  /// Birim dozda her kartın üstündeki göz etiketi ("1", "2" ...). Kübikte
  /// çağrılmaz.
  final String Function(int index)? stepLabelBuilder;

  final bool canConfirm;
  final bool isSaving;
  final String confirmLabel;
  final Future<void> Function() onConfirm;

  bool get _hasAnyFilling => showFilling && entries.any((e) => (e.fillingQuantity ?? 0) > 0);

  Widget _buildCard(BuildContext context, int index) {
    final entry = entries[index];
    return CabinCellInputCard(
      density: isKubik ? MedValueCardDensity.comfortable : MedValueCardDensity.compact,
      assignment: entry.assignment,
      current: entry.current,
      countQuantity: entry.countQuantity,
      onCountChanged: (v) => onCountChanged(index, v),
      fillingQuantity: showFilling ? entry.fillingQuantity : null,
      onFillingChanged: showFilling ? (v) => onFillingChanged!(index, v) : null,
      miadDate: entry.miadDate,
      onMiadChanged: isPerCellMiadEnabled ? (d) => onMiadChanged?.call(index, d) : null,
      stepLabel: isKubik ? null : stepLabelBuilder?.call(index),
    );
  }

  Future<void> _openSingleMiadPicker(BuildContext context) async {
    final onChanged = onSingleMiadChanged;
    if (onChanged == null) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: singleMiadDate.clampedForPicker(),
      firstDate: todayDateOnly(),
      lastDate: DateTime(2099, 12, 31),
    );
    if (picked != null) onChanged(picked);
  }

  Widget _buildSingleMiadHeader(BuildContext context) {
    final hasValue = singleMiadDate != null;
    final hasError = (_hasAnyFilling && singleMiadDate == null) || singleMiadDate.isExpiredMiad;

    return MedValueCard(
      density: MedValueCardDensity.compact,
      label: context.l10n.dateField_placeholder,
      value: hasValue ? singleMiadDate.formattedDate : context.l10n.dateField_placeholder,
      placeholder: !hasValue,
      hasError: hasError,
      trailingIcon: PhosphorIcons.calendarBlank(),
      onTap: () => _openSingleMiadPicker(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (isKubik) {
      if (entries.isEmpty) return const SizedBox.shrink();
      return SingleChildScrollView(child: _buildCard(context, 0));
    }

    Widget cellGrid() {
      return CabinOperationCellGrid(
        itemCount: entries.length,
        targetItemWidth: 300,
        itemBuilder: _buildCard,
        shrinkWrap: !isPerCellMiadEnabled,
        physics: isPerCellMiadEnabled ? null : const NeverScrollableScrollPhysics(),
      );
    }

    if (isPerCellMiadEnabled) {
      return cellGrid();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _buildSingleMiadHeader(context),
        Expanded(child: cellGrid()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: isLocked ? 0.55 : 1.0,
                child: IgnorePointer(ignoring: isLocked, child: _buildContent(context)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MedButton(
                label: confirmLabel,
                size: MedButtonSize.lg,
                isLoading: isSaving,
                onPressed: canConfirm ? () => onConfirm() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
