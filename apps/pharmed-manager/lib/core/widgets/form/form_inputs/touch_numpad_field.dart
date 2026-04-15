import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Dokunmatik ekran için optimize edilmiş numpad giriş alanı.
///
/// [step] verilirse +/- butonlu stepper görünümü kullanılır;
/// verilmezse tüm alan tek bir numpad tetikleyicisi olarak çalışır.
///
class TouchNumpadField extends StatelessWidget {
  const TouchNumpadField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.unit,
    this.hint = '0',
    this.title,
    this.step,
    this.min = 0.0,
    this.max,
  });

  final double value;
  final Function(double) onChanged;

  final String? label;
  final String? unit;
  final String hint;
  final String? title;

  /// Doldurulursa +/- butonlu stepper gösterilir.
  /// null ise tüm alan tek tap ile numpad açar.
  final double? step;

  final double min;
  final double? max;

  bool get _isStepper => step != null;
  bool get _isEmpty => value == 0;

  // ── Numpad tetikleyici ──────────────────────────────────────────────
  Future<void> _openNumpad(BuildContext context) async {
    // final String? result = await showNumpadView(
    //   context,
    //   title: 'Miktar',
    //   initialValue: value == 0 ? '' : value.formatFractional,
    // );
    // if (result != null) onChanged(double.tryParse(result) ?? 0);
  }

  // ── Step değişimi ──────────────────────────────────────────────────
  void _increment(BuildContext context) {
    double next = value + step!;
    if (max != null && next > max!) next = max!;
    onChanged(next);
  }

  void _decrement(BuildContext context) {
    double next = value - step!;
    if (next < min) next = min;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return _isStepper ? _buildStepper(context) : _buildSimple(context);
  }

  // ══════════════════════════════════════════════════════════════════
  // STEPPER VARYANT
  // ══════════════════════════════════════════════════════════════════
  Widget _buildStepper(BuildContext context) {
    final bool canDecrement = value > min;
    final bool canIncrement = max == null || value < max!;

    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          // Azalt butonu
          _StepButton(
            icon: PhosphorIcons.minus(PhosphorIconsStyle.bold),
            enabled: canDecrement,
            onTap: canDecrement ? () => _decrement(context) : null,
            isLeft: true,
          ),

          _VerticalDivider(),

          // Merkez — değer gösterimi + numpad tetikleyici
          Expanded(
            child: InkWell(
              onTap: () => _openNumpad(context),
              borderRadius: BorderRadius.circular(4),
              child: _ValueDisplay(label: label, value: value, unit: unit, hint: hint, isEmpty: _isEmpty),
            ),
          ),

          _VerticalDivider(),

          // Artır butonu
          _StepButton(
            icon: PhosphorIcons.plus(PhosphorIconsStyle.bold),
            enabled: canIncrement,
            onTap: canIncrement ? () => _increment(context) : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SIMPLE (SADECE NUMPAD) VARYANT
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSimple(BuildContext context) {
    return InkWell(
      onTap: () => _openNumpad(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            // Sol — etiket + birim
            if (label != null || unit != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: context.colorScheme.outlineVariant.withValues(alpha: 0.4))),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    if (label != null)
                      Text(label!, style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                    if (unit != null)
                      Text(unit!, style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // Merkez — değer
            Expanded(
              child: _ValueDisplay(
                value: value,
                unit: label != null ? null : unit, // sol kolon varsa birim orada gösterildi
                hint: hint,
                isEmpty: _isEmpty,
              ),
            ),

            // Sağ — düzenle ikonu
            Container(
              width: 44,
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: context.colorScheme.outlineVariant.withValues(alpha: 0.4))),
              ),
              child: Icon(
                PhosphorIcons.pencilSimple(),
                size: 15,
                color: context.colorScheme.onSurfaceVariant.withValues(alpha: _isEmpty ? 0.4 : 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// YARDIMCI WİDGET'LAR
// ══════════════════════════════════════════════════════════════════════

/// Stepper +/- butonu
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.enabled, required this.onTap, required this.isLeft});

  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.horizontal(
        left: isLeft ? const Radius.circular(11) : Radius.zero,
        right: isLeft ? Radius.zero : const Radius.circular(11),
      ),
      child: SizedBox(
        width: 56,
        height: double.infinity,
        child: Icon(
          icon,
          size: 18,
          color: enabled ? context.colorScheme.primary : context.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

/// Stepper ve simple varyantlarda ortak kullanılan değer gösterimi
class _ValueDisplay extends StatelessWidget {
  const _ValueDisplay({required this.value, required this.hint, required this.isEmpty, this.label, this.unit});

  final double value;
  final String hint;
  final bool isEmpty;
  final String? label;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 1,
      children: [
        if (label != null)
          Text(
            label!.toUpperCase(),
            style: context.textTheme.labelSmall?.copyWith(fontSize: 9, fontWeight: FontWeight.w600),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: 4,
          children: [
            Text(
              isEmpty ? hint : value.formatFractional,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isEmpty ? context.colorScheme.onSurface.withValues(alpha: 0.3) : context.colorScheme.primary,
                fontSize: 22,
              ),
            ),
            if (unit != null && !isEmpty)
              Text(
                unit!,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Stepper'da +/- ile değer alanı arasındaki ince dikey çizgi
class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: VerticalDivider(
        width: 1,
        thickness: 0.5,
        color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
