import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'med_rectangle_button.dart';

class CabinOperationSelectionView extends StatelessWidget {
  const CabinOperationSelectionView({
    super.key,
    required this.assignments,
    required this.isAllSelected,
    this.toggleSelectAll,
    this.onAssignmentTap,
    required this.isAssignmentSelected,
    required this.title,
    this.footer,
    this.extra,
    this.showSearch = true,
    this.onSearch,
  });

  final String title;
  final List<MedicineAssignment> assignments;
  final bool isAllSelected;
  final VoidCallback? toggleSelectAll;
  final Function(MedicineAssignment assignment)? onAssignmentTap;
  final bool Function(MedicineAssignment assignment) isAssignmentSelected;
  final Widget? footer;
  final Widget? extra;
  final bool showSearch;
  final Function(String? query)? onSearch;

  @override
  Widget build(BuildContext context) {
    final isTappable = onAssignmentTap != null;

    // TODO : Localization
    return Container(
      margin: MedSpacing.insetXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kapsam ve Seçim', style: MedTextStyles.monoMd(color: MedColors.blueDark)),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(title, style: MedTextStyles.titleXl().copyWith()),
              ),
            ],
          ),
          SizedBox(height: 14.0),
          Divider(color: MedColors.border, height: 1, thickness: 2),
          ?extra,
          SizedBox(height: 16.0),
          // Search Field
          if (showSearch)
            SizedBox(
              height: 55,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: onSearch,
                      decoration: InputDecoration(
                        hintText: context.l10n.refill_hint_searchMedicine,
                        hintStyle: MedTextStyles.monoSm(),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
                      ),
                    ),
                  ),
                  if (toggleSelectAll != null) ...[
                    const SizedBox(width: 6.0),
                    MedRectangleButton(
                      label: isAllSelected ? 'Temizle' : 'Tümünü Seç',
                      height: 48,
                      onTap: toggleSelectAll!,
                      isActive: true,
                      showBorder: true,
                      foregroundColor: MedColors.text,
                      backgroundColor: Colors.transparent,
                    ),
                  ],
                ],
              ),
            ),
          if (showSearch) const SizedBox(height: 16.0),
          SizedBox(height: 16.0),
          // Tablo Başlıkları
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isTappable) SizedBox(width: 50, child: Text('Seç', style: MedTextStyles.titleSm())),
              Expanded(flex: 2, child: Text('Konum', style: MedTextStyles.titleSm())),
              Expanded(flex: 3, child: Text('İlaç', style: MedTextStyles.titleSm())),
              Expanded(child: Text('Stok', style: MedTextStyles.titleSm())),
              Expanded(child: Text('Doluluk', style: MedTextStyles.titleSm())),
              SizedBox(width: 60, child: Opacity(opacity: 0, child: Text('Düzenle'))),
            ],
          ),
          SizedBox(height: 16.0),
          // Tablo İçerikleri
          Expanded(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                final drug = assignment.medicine;
                final isSelected = isAssignmentSelected(assignment);
                final konum = assignment.isKubikType
                    ? 'Çekmece ${assignment.drawerUnit?.drawerSlot?.address} - Satır ${assignment.drawerUnit?.compartmentNo} - Sütun ${assignment.drawerUnit?.orderNo}'
                    : 'Çekmece ${assignment.drawerUnit?.drawerSlot?.orderNumber} - Göz ${assignment.drawerUnit?.compartmentNo}';

                double current = assignment.toDisplayQuantity(assignment.totalQuantity);
                double maxQty = assignment.maxQuantityFromBackend;

                return GestureDetector(
                  onTap: isTappable ? () => onAssignmentTap!(assignment) : null,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 4.0),
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? MedColors.blueLight : null,
                      border: Border(bottom: BorderSide(color: Colors.black)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (isTappable)
                          SizedBox(
                            width: 50,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                isSelected ? PhosphorIconsFill.checkSquare : PhosphorIcons.square(),
                                color: MedColors.blue,
                              ),
                            ),
                          ),
                        Expanded(flex: 2, child: Text(konum, style: MedTextStyles.bodyMd())),
                        Expanded(
                          flex: 3,
                          child: Text(drug?.name ?? '-', style: MedTextStyles.bodyLg(weight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: Text(
                            '${current.formatFractional} / ${maxQty.formatFractional}',
                            style: MedTextStyles.bodyMd(weight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: _MedStockFillBar(current: current.toInt(), max: maxQty.toInt()),
                        ),
                        SizedBox(width: 60, child: Opacity(opacity: 0, child: Text('Düzenle'))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.0),
          ?footer,
        ],
      ),
    );
  }
}

/// Stok/doluluk göstergesi — "mevcut / maksimum" metni + oransal bar.
/// Doluluk oranı %50'nin altındaysa kırmızı, %50 ve üzerindeyse koyu renk.
class _MedStockFillBar extends StatelessWidget {
  // ignore: unused_element_parameter
  const _MedStockFillBar({required this.current, required this.max, this.lowThreshold = 0.5});

  final int current;
  final int max;

  /// Bu oranın altı kırmızı, eşit/üstü koyu renk olarak gösterilir.
  final double lowThreshold;

  double get _ratio => max <= 0 ? 0 : current / max;

  /// Bar dolgu genişliği için kullanılan oran — %100'ü aşan stoklarda
  /// (örn. 9/8) bar tamamen dolu görünsün diye 1.0'da sınırlanır.
  double get _clampedRatio => _ratio.clamp(0.0, 1.0);

  bool get _isLow => _ratio <= lowThreshold;

  Color get _fillColor => _isLow ? MedColors.red : MedColors.green;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: MedColors.surface3)),
              Container(
                height: 6,
                width: constraints.maxWidth * _clampedRatio,
                decoration: BoxDecoration(color: _fillColor, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          );
        },
      ),
    );
  }
}
