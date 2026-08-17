import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/patient_selection/notifier/patient_selection_notifier.dart';
import 'package:pharmed_client/widgets/med_rectangle_button.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

part 'urgent_patient_sheet.dart';

class PatientSelectionPanel extends StatelessWidget {
  const PatientSelectionPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, child) {
        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: MedSpacing.insetXl.left * 1.5,
                    top: MedSpacing.insetXl.top,
                    right: MedSpacing.insetXl.right,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hastalar'.toUpperCase(), style: MedTextStyles.titleMd()),
                      SizedBox(height: 12.0),
                      IntakeTabSelector(),
                      SizedBox(height: 12.0),
                      SearchField(),
                      SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: PatienViewTypeSelector()),
                          Expanded(flex: 1, child: OrderStatusSelector()),
                        ],
                      ),
                      SizedBox(height: 6.0),
                      FilterTypeSelector(),
                      Divider(color: MedColors.text2),
                    ],
                  ),
                ),
                Expanded(child: notifier.hasUrgentPatient ? const SizedBox.shrink() : PatientListView()),
                if (notifier.hasUrgentPatient)
                  UrgentPatientCard(patient: notifier.urgentPatient!, onClear: notifier.clearUrgentPatient)
                else
                  CreateUrgentPatientButton(),
              ],
            ),

            // Sheet
            if (notifier.isCreateSheetOpen) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: notifier.closeCreateSheet,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: 1,
                    child: Container(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TweenAnimationBuilder<Offset>(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
                  builder: (context, offset, child) => FractionalTranslation(translation: offset, child: child),
                  child: const UrgentPatientSheet(),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class IntakeTabSelector extends StatelessWidget {
  const IntakeTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, child) {
        return Row(
          children: List.generate(IntakePatientTab.values.length, (index) {
            final tab = IntakePatientTab.values.elementAt(index);
            final isSelected = notifier.intakeTab == tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => notifier.changeIntakeTab(tab),
                child: _selector(context, tab, isSelected, index),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _selector(BuildContext context, IntakePatientTab tab, bool isSelected, int index) {
    final border = Border(
      top: BorderSide(width: 1.5),
      bottom: BorderSide(width: 1.5),
      right: BorderSide(width: 1.5),
      left: BorderSide(width: index == 0 ? 1.5 : 0),
    );
    return Container(
      //height: 50,
      padding: EdgeInsets.symmetric(horizontal: MedSpacing.insetXl.left * 2, vertical: MedSpacing.insetXl.top),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(color: isSelected ? MedColors.blue : null, border: border),
      child: Text(tab.label(context), style: MedTextStyles.titleSm(color: isSelected ? Colors.white : null)),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        hintText: context.l10n.patientPicker_searchHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: MedColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: MedColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: MedColors.border),
        ),
      ),
    );
  }
}

class PatienViewTypeSelector extends StatelessWidget {
  const PatienViewTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, child) {
        return Row(
          spacing: 6.0,
          children: List.generate(PatientViewType.values.length, (index) {
            final type = PatientViewType.values.elementAt(index);
            final isSelected = type == notifier.viewType;
            return MedRectangleButton(
              height: 40,
              showBorder: !isSelected,
              foregroundColor: isSelected ? Colors.white : Colors.black,
              backgroundColor: isSelected ? MedColors.blue : MedColors.surface,
              label: type.label(context),
              onTap: () => notifier.changeViewType(type),
            );
          }),
        );
      },
    );
  }
}

class OrderStatusSelector extends StatelessWidget {
  const OrderStatusSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, child) {
        if (!notifier.showOrderToggleButton) {
          return SizedBox();
        }

        final bool isSelected = notifier.orderStatus == OrderStatus.ordered;
        return MedRectangleButton(
          height: 40,
          width: 60,
          onTap: () => notifier.toggleOrderStatus(),
          label: context.l10n.patientPicker_orderedToggleLabel,
          suffixIcon: isSelected ? PhosphorIconsFill.squareLogo : PhosphorIcons.square(),
          foregroundColor: Colors.white,
        );
      },
    );
  }
}

class FilterTypeSelector extends StatefulWidget {
  const FilterTypeSelector({super.key});

  @override
  State<FilterTypeSelector> createState() => _FilterTypeSelectorState();
}

class _FilterTypeSelectorState extends State<FilterTypeSelector> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(skipTraversal: true);

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, child) {
        if (!notifier.showFilterRow) {
          return SizedBox.shrink();
        }

        return HorizontalMouseScrollable(
          controller: _scrollController,
          focusNode: _focusNode,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6.0,
              children: List.generate(PatientFilterType.values.length, (index) {
                final type = PatientFilterType.values.elementAt(index);
                final isSelected = type == notifier.filterType;
                return MedRectangleButton(
                  height: 40,

                  showBorder: !isSelected,
                  foregroundColor: isSelected ? Colors.white : Colors.black,
                  backgroundColor: isSelected ? MedColors.blue : MedColors.surface,
                  label: type.label,
                  onTap: () => notifier.changeFilterType(type),
                  textStyle: MedTextStyles.bodySm(
                    color: isSelected ? Colors.white : MedColors.text2,
                    weight: FontWeight.bold,
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

class PatientListView extends StatelessWidget {
  const PatientListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, _) {
        if (notifier.isFetchingHospitalizations && notifier.hospitalizations.isEmpty) {
          return Center(child: MedLoadingIndicator());
        }

        if (!notifier.isFetchingHospitalizations && notifier.hospitalizations.isEmpty) {
          return Center(child: EmptyStateWidget(variant: EmptyStateVariant.noData));
        }

        return ListView.separated(
          itemBuilder: (context, index) {
            final hosp = notifier.hospitalizations.elementAt(index);
            final patient = hosp.patient;
            final admissionDate = hosp.admissionDate;
            final service = hosp.physicalService?.name;
            final bed = hosp.bed?.name;
            final room = hosp.bed?.room?.name;
            final bool isSelected = notifier.selected == hosp;
            if (patient == null) {
              return SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () => notifier.onPatientTap(hosp),
              child: Container(
                padding: MedSpacing.insetXl * 1.5,
                decoration: BoxDecoration(
                  color: isSelected ? MedColors.blueLight : null,
                  border: isSelected ? Border(left: BorderSide(color: MedColors.blue, width: 16)) : null,
                ),
                child: Column(
                  spacing: 6.0,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName, style: MedTextStyles.titleMd()),
                    if (admissionDate != null)
                      Text(
                        context.l10n.hospitalization_admissionDate(hosp.admissionDate!.formattedDate),
                        style: MedTextStyles.monoMd(),
                      ),
                    Row(
                      spacing: 6.0,
                      children: [
                        if (service != null) MedChip(label: service),
                        if (bed != null) MedChip(label: bed),
                        if (room != null) MedChip(label: room),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return Divider(height: 1);
          },
          itemCount: notifier.hospitalizations.length,
        );
      },
    );
  }
}

class CreateUrgentPatientButton extends StatelessWidget {
  const CreateUrgentPatientButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientSelectionNotifier>(
      builder: (context, notifier, _) {
        return Padding(
          padding: MedSpacing.insetXl,
          child: MedRectangleButton(
            height: 45,
            label: context.l10n.patientPicker_createUrgentPatientButton,
            suffixIcon: PhosphorIcons.plus(),
            foregroundColor: Colors.white,
            backgroundColor: MedColors.red,
            isLoading: notifier.isFetchingServices,
            onTap: notifier.isFetchingServices
                ? null
                : () => notifier.fetchServices(
                    onError: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                    onSuccess: () {
                      if (!context.mounted) return;
                      notifier.openCreateSheet();
                    },
                  ),
          ),
        );
      },
    );
  }
}

class UrgentPatientCard extends StatelessWidget {
  const UrgentPatientCard({super.key, required this.patient, required this.onClear});

  final Hospitalization patient;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MedSpacing.insetXl,
      child: Container(
        padding: MedSpacing.insetXl,
        decoration: BoxDecoration(
          color: MedColors.redLight,
          border: Border.all(color: MedColors.red),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.0,
          children: [
            Text(
              context.l10n.patientPicker_urgentPatientCreatedMessage,
              style: MedTextStyles.titleMd(color: MedColors.red),
            ),
            Text(
              context.l10n.patientPicker_urgentPatientActiveDescription,
              style: MedTextStyles.bodyMd(weight: FontWeight.bold, color: MedColors.redDark),
            ),
            const SizedBox(height: 4),
            MedRectangleButton(
              label: context.l10n.common_deleteTooltip, // "Kaldır"
              backgroundColor: MedColors.red,
              height: 40,
              onTap: onClear,
            ),
          ],
        ),
      ),
    );
  }
}
