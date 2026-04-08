import 'package:flutter/material.dart';
import '../../cabin_assignment_picker/view/cabin_assignment_picker_view.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import '../notifier/cabin_inventory_notifier.dart';
import 'cabin_input_quantity_field.dart';
import 'expired_banner_view.dart';
import 'quantity_info_card.dart';

const double _kCardRadius = 12.0;

class DrawerLoadingView extends StatefulWidget {
  const DrawerLoadingView({
    super.key,
    required this.data,
    required this.type,
    required this.onMiadDateChanged,
    required this.countQuantities,
    required this.fillingQuantities,
    required this.onCountQuantityChanged,
    required this.onFillingQuantityChanged,
    required this.quantity,
    required this.isPerCellMiadEnabled,
    required this.onCellMiadChanged,
    required this.cellMiadDates,
    required this.expiredCellIndexes,
    this.plannedQuantity,
  });

  final CabinAssignment data;
  final CabinInventoryType type;
  final Function(DateTime date) onMiadDateChanged;

  final List<double> countQuantities;
  final List<double> fillingQuantities;

  final Function(double quantity, int index) onCountQuantityChanged;
  final Function(double quantity, int index) onFillingQuantityChanged;

  final double quantity;
  final double? plannedQuantity;

  final bool isPerCellMiadEnabled;
  final List<DateTime?> cellMiadDates;
  final Function(DateTime? date, int index) onCellMiadChanged;

  final List<int> expiredCellIndexes;

  @override
  State<DrawerLoadingView> createState() => _DrawerLoadingViewState();
}

class _DrawerLoadingViewState extends State<DrawerLoadingView> {
  late final TextEditingController _dateController;

  int get _numberOfSteps => widget.data.drawerUnit?.drawerSlot?.drawerConfig?.numberOfSteps ?? 0;

  bool _isCellExpired(int index) => widget.expiredCellIndexes.contains(index);
  bool _isCellLocked(int index) => _isCellExpired(index) && widget.type.shouldBlockOnExpiry;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: context.read<CabinInventoryNotifier>().miadDate?.formattedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overrideQuantity = widget.data.toDisplayQuantity(widget.data.totalQuantity);

    return Column(
      spacing: 10,
      children: [
        QuantityInfoCard(
          data: widget.data,
          quantity: widget.quantity,
          type: widget.type,
          plannedQuantity: widget.plannedQuantity,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: AppDimensions.cardDecoration(context).copyWith(borderRadius: BorderRadius.circular(_kCardRadius)),
          child: RatioProgressIndicator(assignment: widget.data, overrideQuantity: overrideQuantity),
        ),
        if (widget.expiredCellIndexes.isNotEmpty && widget.type.shouldBlockOnExpiry) ExpiredBannerView(),
        if (!widget.isPerCellMiadEnabled && widget.type.enableMiadDateInput)
          _buildMiadDateField(
            initialValue: () {
              final m = context.read<CabinInventoryNotifier>().miadDate;
              return (m != null && !m.isBefore(DateTime.now())) ? m : null;
            }(),
            isExpired: false,
            label: 'Miad Tarihi',
            controller: _dateController,
            onDateSelected: (date) {
              widget.onMiadDateChanged(date);
              _dateController.text = date.formattedDate;
            },
          ),
        if (!widget.isPerCellMiadEnabled &&
            !widget.type.enableMiadDateInput &&
            context.read<CabinInventoryNotifier>().miadDate != null)
          _buildMiadDateField(
            initialValue: context.read<CabinInventoryNotifier>().miadDate,
            isExpired: false,
            label: 'Mevcut Miad Tarihi',
            enabled: false,
            onDateSelected: (_) {},
          ),
        Container(
          decoration: AppDimensions.cardDecoration(context).copyWith(borderRadius: BorderRadius.circular(_kCardRadius)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _buildTableHeader(context),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _numberOfSteps,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, thickness: 1, color: context.colorScheme.outlineVariant.withValues(alpha: 0.3)),
                itemBuilder: (context, index) => _buildTableRow(context, index),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final style = context.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: context.colorScheme.onSurfaceVariant,
      fontSize: 10,
      letterSpacing: 0.3,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: context.colorScheme.surfaceContainerHighest.withAlpha(100),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text('Göz', style: style)),
          Expanded(
            child: Center(child: Text('Sayım Miktarı', style: style)),
          ),
          if (widget.type != CabinInventoryType.count)
            Expanded(
              child: Center(child: Text(widget.type.fieldText, style: style)),
            ),
          if (widget.isPerCellMiadEnabled)
            Expanded(
              child: Center(child: Text('Miad Tarihi', style: style)),
            ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, int index) {
    final double currentCount = widget.countQuantities[index];
    final double currentFill = widget.fillingQuantities[index];
    final DateTime? currentMiad = widget.cellMiadDates[index];

    final bool hasInput = widget.type == CabinInventoryType.count ? currentCount > 0 : currentFill > 0;
    final bool isCellLocked = _isCellLocked(index);

    return Opacity(
      opacity: isCellLocked ? 0.4 : 1.0,
      child: IgnorePointer(
        ignoring: isCellLocked,
        child: Container(
          color: isCellLocked ? context.colorScheme.errorContainer.withValues(alpha: 0.12) : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            spacing: 8,
            children: [
              SizedBox(
                width: 32,
                child: Row(
                  spacing: 4,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isCellLocked
                            ? context.colorScheme.errorContainer
                            : context.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: context.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCellLocked ? context.colorScheme.error : context.colorScheme.primary,
                        ),
                      ),
                    ),
                    if (isCellLocked) Icon(Icons.lock_rounded, size: 12, color: context.colorScheme.error),
                  ],
                ),
              ),
              Expanded(
                child: CabinInputQuantityField(
                  data: widget.data,
                  type: widget.type,
                  isCountField: true,
                  value: currentCount,
                  showLabel: false,
                  onChanged: (val) => widget.onCountQuantityChanged(val, index),
                ),
              ),
              if (widget.type != CabinInventoryType.count)
                Expanded(
                  child: CabinInputQuantityField(
                    data: widget.data,
                    type: widget.type,
                    showLabel: false,
                    isCountField: false,
                    value: currentFill,
                    onChanged: (val) {
                      if (val > 0 && currentMiad != null && currentMiad.isBefore(DateTime.now())) {
                        widget.onCellMiadChanged(null, index);
                      }
                      widget.onFillingQuantityChanged(val, index);
                    },
                  ),
                ),
              if (widget.isPerCellMiadEnabled)
                Expanded(
                  child: widget.type.enableMiadDateInput
                      ? Opacity(
                          opacity: (isCellLocked || hasInput) ? 1.0 : 0.4,
                          child: IgnorePointer(
                            ignoring: isCellLocked || !hasInput,
                            child: _buildMiadDateField(
                              initialValue: isCellLocked
                                  ? currentMiad
                                  : (currentMiad != null && !currentMiad.isBefore(DateTime.now()))
                                  ? currentMiad
                                  : null,
                              isExpired: isCellLocked,
                              onDateSelected: (date) => widget.onCellMiadChanged(date, index),
                            ),
                          ),
                        )
                      : _buildMiadDateField(
                          initialValue: currentMiad,
                          isExpired: false,
                          enabled: false,
                          onDateSelected: (_) {},
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiadDateField({
    required DateTime? initialValue,
    required bool isExpired,
    required void Function(DateTime) onDateSelected,
    TextEditingController? controller,
    String? label,
    bool enabled = true,
  }) {
    return DateInputField(
      label: label,
      initialValue: initialValue,
      firstDate: (isExpired || !enabled) ? null : DateTime.now(),
      //controller: controller,
      enabled: enabled,
      onDateSelected: onDateSelected,
    );
  }
}
