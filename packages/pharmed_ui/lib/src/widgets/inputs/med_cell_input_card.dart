// [SWREQ-UI-CELLINPUT-001] [IEC 62304 §5.5]
// Kabin işlem ekranlarında (dolum, sayım, boşaltma, imha) tek bir gözün
// sayım / işlem miktarı / miad girişini toplayan ortak kart.
//
// Domain-bağımsızdır: MedicineAssignment yerine düz değerler alır. Üç giriş de
// (sayım, işlem, miad) MedValueCard'dır; dokununca çağıran katman ilgili
// giriş yöntemini açar (numpad ya da tarih seçici) ve değeri günceller. Böylece
// pharmed_ui katman kuralını ihlal etmez ve tüm işlem ekranlarında paylaşılır.
//
// İki yoğunluk:
//   - MedCellDensity.comfortable → dikey, geniş padding (varsayılan).
//   - MedCellDensity.compact     → sıkı yatay layout, küçük padding.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

enum MedCellDensity { comfortable, compact }

enum MedCellStockLevel { ok, low, critical }

class MedCellInputCard extends StatelessWidget {
  const MedCellInputCard({
    super.key,
    required this.title,
    required this.current,
    required this.max,
    required this.fillRatio,
    required this.stockLevel,
    required this.countLabel,
    required this.countText,
    required this.onCountTap,
    required this.fillingLabel,
    required this.fillingText,
    required this.onFillingTap,
    required this.miadLabel,
    required this.miadText,
    required this.onMiadTap,
    this.miadIcon,
    this.miadHasError = false,
    this.miadPlaceholder = false,
    this.countPlaceholder = false,
    this.fillingPlaceholder = false,
    this.subtitle,
    this.stepLabel,
    this.density = MedCellDensity.comfortable,
  });

  /// İlaç adı (ana başlık).
  final String title;

  /// İkincil satır (adres / göz no vb.).
  final String? subtitle;

  /// Mevcut / maks stok (adet gösterim).
  final String current;
  final String max;

  /// Mevcut/maks oranı (0..1) — doluluk çubuğu için.
  final double fillRatio;

  final MedCellStockLevel stockLevel;

  /// Sol küçük etiket rozeti (birim doz "1. Göz"); yoksa null.
  final String? stepLabel;

  // ── Üç giriş kartı ──────────────────────────────────────────────────────

  final String countLabel;
  final String countText;
  final VoidCallback onCountTap;
  final bool countPlaceholder;

  final String fillingLabel;
  final String fillingText;
  final VoidCallback onFillingTap;
  final bool fillingPlaceholder;

  final String miadLabel;
  final String miadText;
  final VoidCallback onMiadTap;

  /// Miad kartı için opsiyonel trailing ikon (takvim).
  final IconData? miadIcon;

  /// Miad zorunlu ama boşsa: hem miad kartını hem kart kenarını amber yapar.
  final bool miadHasError;
  final bool miadPlaceholder;

  final MedCellDensity density;

  Color get _stockColor => switch (stockLevel) {
    MedCellStockLevel.ok => MedColors.green,
    MedCellStockLevel.low => MedColors.amber,
    MedCellStockLevel.critical => MedColors.red,
  };

  bool get _isCompact => density == MedCellDensity.compact;

  MedValueCardDensity get _valueDensity => _isCompact ? MedValueCardDensity.compact : MedValueCardDensity.comfortable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _isCompact ? MedSpacing.insetLg : MedSpacing.insetXl,
      decoration: BoxDecoration(
        color: MedColors.surface,
        border: Border.all(color: miadHasError ? MedColors.amber : MedColors.border),
        borderRadius: _isCompact ? MedRadius.lgAll : MedRadius.xl2All,
        boxShadow: MedShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: _isCompact ? 10 : 14,
        children: [_header(), if (!_isCompact) _stockBar(), _inputs()],
      ),
    );
  }

  Widget _header() {
    final titleStyle = _isCompact ? MedTextStyles.bodyMd(color: MedColors.text) : MedTextStyles.titleSm();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (stepLabel != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.smAll),
            child: Text(stepLabel!, style: MedTextStyles.monoSm(color: MedColors.blue)),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null) Text(subtitle!, style: MedTextStyles.monoXs(color: MedColors.text3)),
            ],
          ),
        ),
        Text('$current / $max', style: MedTextStyles.monoMd(color: _stockColor)),
      ],
    );
  }

  Widget _stockBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: fillRatio.clamp(0.0, 1.0),
        minHeight: 8,
        backgroundColor: MedColors.surface2,
        valueColor: AlwaysStoppedAnimation(_stockColor),
      ),
    );
  }

  Widget _inputs() {
    final countCard = MedValueCard(
      density: _valueDensity,
      label: countLabel,
      value: countText,
      placeholder: countPlaceholder,
      onTap: onCountTap,
    );
    final fillingCard = MedValueCard(
      density: _valueDensity,
      label: fillingLabel,
      value: fillingText,
      placeholder: fillingPlaceholder,
      onTap: onFillingTap,
    );
    final miadCard = MedValueCard(
      density: _valueDensity,
      label: miadLabel,
      value: miadText,
      placeholder: miadPlaceholder,
      hasError: miadHasError,
      trailingIcon: miadIcon,
      onTap: onMiadTap,
    );

    if (_isCompact) {
      // Sıkı yatay: sayım | işlem | miad tek satırda (miad biraz geniş).
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Expanded(child: countCard),
          Expanded(child: fillingCard),
          Expanded(flex: 2, child: miadCard),
        ],
      );
    }

    // Geniş: sayım+işlem üstte yan yana, miad altta tam genişlik.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(child: countCard),
            Expanded(child: fillingCard),
          ],
        ),
        miadCard,
      ],
    );
  }
}
