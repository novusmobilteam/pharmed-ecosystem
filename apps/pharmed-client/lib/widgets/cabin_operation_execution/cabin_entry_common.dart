// widgets/cabin_shell_widgets/execution/cabin_entry_common.dart
import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

typedef CabinDatePicker = Future<DateTime?> Function(BuildContext context, DateTime? initial);

Future<DateTime?> defaultCabinDatePicker(BuildContext context, DateTime? initial) => showDatePicker(
  context: context,
  initialDate: initial ?? DateTime.now(),
  firstDate: DateTime.now().subtract(const Duration(days: 365)),
  lastDate: DateTime(2098, 12, 31),
);

String formatEntryQuantity(double value) =>
    value == value.roundToDouble() ? value.toInt().toString() : value.toString();

/// − değer + — birim doz tablosu (compact) ve kübik kart (large) ortak.
/// 1'er artar, 0'ın altına inmez. Dokunmatik hedef en az 44px.
class CabinQuantityStepper extends StatelessWidget {
  const CabinQuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.emphasized = false,
    this.large = false,
    this.allowEmpty = false,
  });

  /// null → henüz girilmedi (yalnızca [allowEmpty] iken), "—" gösterilir.
  final double? value;
  final ValueChanged<double> onChanged;
  final bool emphasized;
  final bool large;

  /// Kör sayım: değer boş başlayabilir; değere dokununca numpad açılır.
  final bool allowEmpty;

  static const double compactButtonSize = 44;
  static const double largeButtonSize = 56;

  Future<void> _openNumpad(BuildContext context) async {
    final result = await showNumpadView(context, initialValue: value?.formatFractional ?? '');
    final parsed = double.tryParse((result ?? '').trim().replaceAll(',', '.'));
    if (parsed != null && parsed >= 0) onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = large ? largeButtonSize : compactButtonSize;
    final current = value;
    final color = emphasized ? MedColors.blue : (large ? MedColors.text : MedColors.text2);
    final base = large ? MedTextStyles.titleLg(color: color) : MedTextStyles.titleMd(color: color);
    final style = base.copyWith(fontWeight: emphasized || large ? FontWeight.w700 : null, fontSize: large ? 36 : null);

    return Row(
      children: [
        _StepButton(
          size: buttonSize,
          icon: Icons.remove,
          onTap: (current ?? 0) > 0 ? () => onChanged((current! - 1).clamp(0, double.infinity).toDouble()) : null,
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openNumpad(context),
            child: Text(
              current == null ? '—' : formatEntryQuantity(current),
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
        _StepButton(size: buttonSize, icon: Icons.add, onTap: () => onChanged((current ?? 0) + 1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.size, required this.icon, this.onTap});

  final double size;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MedColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: MedRadius.smAll,
        side: const BorderSide(color: MedColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: MedRadius.smAll,
        child: SizedBox.square(
          dimension: size,
          child: Icon(
            icon,
            size: size * 0.4,
            color: onTap != null ? MedColors.text2 : MedColors.text3.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}
