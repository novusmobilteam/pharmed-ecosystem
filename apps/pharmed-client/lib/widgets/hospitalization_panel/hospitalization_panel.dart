import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../cabin_shell_widgets/cabin_shell_widgets.dart';
import 'hospitalization_panel_notifier.dart';

class HospitalizationPanel extends ConsumerStatefulWidget {
  const HospitalizationPanel({
    super.key,
    required this.cellBuilder,
    this.onTypeChanged,
    this.isMobileCabin = false,
    this.showTypeSelector = true,
  });

  final Widget Function(Hospitalization item) cellBuilder;
  final VoidCallback? onTypeChanged;
  final bool isMobileCabin;
  final bool showTypeSelector;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => HospitalizationPanelState();
}

class HospitalizationPanelState extends ConsumerState<HospitalizationPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(hospitalizationNotifierProvider)
          .init(isMobileCabin: widget.isMobileCabin, showTypeSelector: widget.showTypeSelector);
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(hospitalizationNotifierProvider);

    return Container(
      decoration: MedDecoration.panelDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MedSpacing.insetLg,
            child: Text(context.l10n.myPatients_activeHospitalizationsPanelTitle, style: MedTextStyles.titleSm()),
          ),
          Container(
            padding: MedSpacing.insetMd,
            color: MedColors.border2,
            child: Column(
              children: [
                CabinOperationSearchField(
                  onChanged: notifier.onSearchChanged,
                  hintText: context.l10n.patientPicker_searchHint,
                ),
              ],
            ),
          ),
          SizedBox(height: MedSpacing.sm),
          if (widget.showTypeSelector)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetLg.left),
              child: MedSegmentedButton(
                selectedIndex: notifier.selectedIndex,
                onChanged: (index) {
                  notifier.selectType(HospitalizationType.values.elementAt(index));
                  widget.onTypeChanged?.call();
                },
                labels: [context.l10n.enumCore_patientFilterAll, context.l10n.patientPicker_myPatientsToggleLabel],
              ),
            ),
          if (notifier.isLoading(notifier.fetchHospitalizationsOp))
            Expanded(child: Center(child: MedLoadingIndicator()))
          else
            Expanded(
              child: notifier.filteredHospitalizations.isEmpty
                  ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                  : Padding(
                      padding: MedSpacing.insetLg,
                      child: ListView.separated(
                        itemCount: notifier.filteredHospitalizations.length,
                        separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                        itemBuilder: (context, index) {
                          final h = notifier.filteredHospitalizations[index];
                          return widget.cellBuilder(h);
                        },
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}
