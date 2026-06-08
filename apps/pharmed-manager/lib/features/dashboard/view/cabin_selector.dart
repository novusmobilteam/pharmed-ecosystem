import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// [SWREQ-MGR-DASH-003]
// Dashboard — yatay kabin seçici.
// Sınıf: Class A

class DashboardCabinSelector extends StatelessWidget {
  const DashboardCabinSelector({
    super.key,
    required this.cabins,
    required this.selectedId,
    required this.onSelect,
    this.lastUpdatedLabel,
  });

  final List<Cabin> cabins;
  final int? selectedId;
  final ValueChanged<int> onSelect;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final cabin in cabins)
                  if (cabin.id != null) ...[
                    MedButton(
                      label: cabin.name ?? '-',
                      size: MedButtonSize.sm,
                      variant: cabin.id == selectedId ? MedButtonVariant.primary : MedButtonVariant.secondary,
                      onPressed: () => onSelect(cabin.id!),
                    ),
                    const SizedBox(width: 8),
                  ],
              ],
            ),
          ),
        ),
        if (lastUpdatedLabel != null) ...[
          const SizedBox(width: 10),
          Text(lastUpdatedLabel!, style: MedTextStyles.monoXs(color: MedColors.text3)),
        ],
      ],
    );
  }
}
