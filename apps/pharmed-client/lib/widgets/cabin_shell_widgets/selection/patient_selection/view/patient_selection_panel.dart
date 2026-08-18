// widgets/cabin_shell_widgets/patient_selection/patient_selection_panel.dart
//
// [SWREQ-CLI-PATIENT-003] [IEC 62304 §5.5]
// Master kabin işlemlerinde (alım/iade/fire-imha) kullanılan TEK, ORTAK hasta
// seçim paneli. PatientSelectionConfig hangi opsiyonel akışların (sekmeler,
// acil hasta, filtreler) aktif olduğuna karar verir.
//
// Acil hasta akışı: PatientListMode YOKTUR. "Acil Hasta Oluştur" butonu
// config.enableUrgentPatient açıkken (ve isUrgentActionVisible true iken)
// HER ZAMAN görünür, tıklanınca alttan sheet açılır (oluşturma orada olur).
// Oluşturma başarılı olunca liste tamamen gizlenir, yerine tek bir onay
// kartı (_UrgentPatientCreatedCard) gösterilir — normal akışa dönmenin tek
// yolu karttaki "Sil" butonudur (DeleteUrgentPatientUseCase).
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/patient_selection_config.dart';
import '../notifier/patient_selection_notifier.dart';
import '../notifier/patient_selection_state.dart';
import 'patient_selection_card.dart';

part 'urgent_patient_sheet.dart';
part 'patient_selection_filter_dialog.dart';

class PatientSelectionPanel extends ConsumerStatefulWidget {
  const PatientSelectionPanel({
    super.key,
    required this.config,
    required this.onPatientSelected,
    required this.selectedPatient,
    this.isLocked = false,
  });

  final PatientSelectionConfig config;

  /// Hasta seçildiğinde (satır tıklama veya acil hasta oluşturma sonrası)
  /// tetiklenir. `tab`, config.enableTabs=false olan ekranlarda her zaman
  /// [PatientSelectionTab.prescriptions] gelir — çağıran taraf gerekmiyorsa
  /// yok sayabilir.
  final void Function(Hospitalization patient, PatientSelectionTab tab, bool isOrderless) onPatientSelected;

  final Hospitalization? selectedPatient;

  /// true iken panel tamamen etkileşimsiz (execution fazı gibi).
  final bool isLocked;

  @override
  ConsumerState<PatientSelectionPanel> createState() => _PatientSelectionPanelState();
}

class _PatientSelectionPanelState extends ConsumerState<PatientSelectionPanel> {
  bool _isCreateSheetOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(patientSelectionNotifierProvider.notifier).init(widget.config);
    });
  }

  void _openCreateSheet() => setState(() => _isCreateSheetOpen = true);
  void _closeCreateSheet() => setState(() => _isCreateSheetOpen = false);

  List<FilterField> _filterFields(BuildContext context, PatientSelectionReady state) {
    if (!widget.config.showFilters) return const [];
    if (widget.config.enableTabs && state.tab == PatientSelectionTab.redirected) return const [];

    return [
      DropdownFilterField<HospitalService?>(
        key: 'service',
        label: context.l10n.assignment_serviceLabel,
        initialValue: state.selectedService,
        options: [null, ...state.availableServices],
        labelBuilder: (s) => s?.name ?? context.l10n.filter_all,
        defaultValue: null,
      ),
      if (state.isOrderedFilterActive)
        DropdownFilterField<PatientFilterType>(
          key: 'filter',
          label: context.l10n.prescriptionDetailStatusLabel,
          initialValue: state.filter,
          options: PatientFilterType.values,
          labelBuilder: (f) => f?.label,
          defaultValue: PatientFilterType.all,
        ),
    ];
  }

  Future<void> _openFilterDialog(
    BuildContext context,
    PatientSelectionNotifier notifier,
    List<FilterField> fields,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => PatientSelectionFilterDialog(fields: fields),
    );
    if (result == null) return;

    if (result.containsKey('service')) notifier.toggleService(result['service'] as HospitalService?);
    if (result.containsKey('filter')) notifier.changeFilter(result['filter'] as PatientFilterType);
  }

  String _viewTypeLabel(BuildContext context, PatientViewType type) {
    switch (type) {
      case PatientViewType.allPatients:
        return context.l10n.enumCore_patientFilterAll;
      case PatientViewType.myPatients:
        return context.l10n.patientPicker_myPatientsToggleLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawState = ref.watch(patientSelectionNotifierProvider);
    final notifier = ref.read(patientSelectionNotifierProvider.notifier);

    ref.listen(patientSelectionNotifierProvider, (_, next) {
      if (next is PatientSelectionError) {
        MessageUtils.showErrorSnackbar(context, next.message);
        notifier.dismissError();
      }
    });

    // `rawState`'in statik tipi her zaman PatientSelectionState kalır —
    // narrow edilmiş `state`'i (Ready) SADECE bu local değişken üzerinden
    // kullanıyoruz. `previousState` PatientSelectionError'da PatientSelectionState
    // (henüz Ready'e daraltılmamış) olduğu için burada TEKRAR pattern-match
    // ediyoruz, notifier'daki previousState'i doğrudan Ready varsayıp
    // kullanmıyoruz.
    final state = switch (rawState) {
      PatientSelectionReady r => r,
      PatientSelectionError(previousState: final p) when p is PatientSelectionReady => p,
      _ => null,
    };

    // MasterCabinRootScaffold'un extraBootGate'i hazır olana kadar bu panel
    // Offstage ile mount tutulur — buraya normalde düşülmemeli.
    if (state == null) return const SizedBox.shrink();

    final hasCreatedUrgentPatient = widget.config.enableUrgentPatient && state.createdUrgentPatient != null;
    final showUrgentAction = widget.config.enableUrgentPatient && state.isUrgentActionVisible;
    final fields = _filterFields(context, state);

    return Stack(
      children: [
        IgnorePointer(
          ignoring: widget.isLocked,
          child: Opacity(
            opacity: widget.isLocked ? 0.6 : 1.0,
            child: Container(
              padding: MedSpacing.panelInsetPadding,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: MedColors.border),
                color: MedColors.surface,
                borderRadius: MedRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.config.enableTabs) ...[
                    MedSegmentedButton(
                      selectedIndex: state.tab.index,
                      onChanged: (i) => notifier.switchTab(PatientSelectionTab.values[i]),
                      labels: [context.l10n.intake_tab_prescriptions, context.l10n.intake_tab_redirectedOrders],
                    ),
                    const SizedBox(height: 6.0),
                  ],

                  // ── Acil hasta oluşturulduysa: her şeyin yerine tek kart ──
                  if (hasCreatedUrgentPatient)
                    Expanded(
                      child: _UrgentPatientCreatedCard(
                        patient: state.createdUrgentPatient!,
                        isDeleting: state.isDeletingUrgent,
                        onDelete: () => notifier.deleteUrgentPatient(
                          onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                        ),
                      ),
                    )
                  else ...[
                    TextFormField(
                      onChanged: notifier.onSearchChanged,
                      style: MedTextStyles.bodyMd(),
                      decoration: InputDecoration(
                        prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 20.0),
                        hintText: context.l10n.patientPicker_searchHint,
                        suffixIcon: fields.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () => _openFilterDialog(context, notifier, fields),
                                icon: Icon(PhosphorIcons.slidersHorizontal(), size: 20.0),
                              ),
                      ),
                    ),
                    const SizedBox(height: 6.0),

                    SizedBox(
                      height: 40,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MedFilterChipGroup<PatientViewType>(
                              options: const [PatientViewType.allPatients, PatientViewType.myPatients],
                              selected: state.viewType,
                              onChanged: (type) {
                                final wantsMine = type == PatientViewType.myPatients;
                                final isCurrentlyMine = state.viewType == PatientViewType.myPatients;
                                if (wantsMine != isCurrentlyMine) notifier.togglePatientView();
                              },
                              labelBuilder: (type) => _viewTypeLabel(context, type),
                              bgColor: MedColors.blue,
                            ),
                          ),
                          if (widget.config.enableOrderlessToggle && state.isStatusToggleVisible)
                            MedToggleButton(
                              label: state.viewOrderStatus.isOrdered
                                  ? context.l10n.patientPicker_orderedToggleLabel
                                  : context.l10n.patientPicker_orderlessToggleLabel,
                              onTap: notifier.toggleOrderlessStatus,
                              selected: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),

                    Builder(
                      builder: (context) {
                        final active = fields.where((f) => f.isClearable && f.isActive(f.initialValue)).toList();
                        if (active.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: MedSpacing.sm),
                          child: Wrap(
                            spacing: MedSpacing.sm,
                            runSpacing: MedSpacing.sm,
                            children: active
                                .map(
                                  (f) => MedChip(
                                    label: f.activeLabel(f.initialValue),
                                    size: MedChipSize.md,
                                    style: MedChipStyle.info,
                                    onDeleted: () {
                                      if (f.key == 'service') {
                                        notifier.toggleService(f.defaultValue as HospitalService?);
                                      }
                                      if (f.key == 'filter') {
                                        notifier.changeFilter(f.defaultValue as PatientFilterType);
                                      }
                                    },
                                    shape: MedChipShape.pill,
                                  ),
                                )
                                .toList(),
                          ),
                        );
                      },
                    ),

                    Expanded(
                      child: Stack(
                        children: [
                          state.visiblePatients.isEmpty && !state.isFetching
                              ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                              : ListView.separated(
                                  itemCount: state.visiblePatients.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final h = state.visiblePatients[index];
                                    final isSelected = widget.selectedPatient?.id == h.id;
                                    return PatientSelectionCard(
                                      hospitalization: h,
                                      isSelected: isSelected,
                                      onTap: () => widget.onPatientSelected(h, state.tab, state.isOrderless),
                                    );
                                  },
                                ),
                          if (state.isFetching)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  color: MedColors.surface.withValues(alpha: 0.5),
                                  alignment: Alignment.center,
                                  child: const MedLoadingIndicator(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    if (showUrgentAction) ...[
                      const SizedBox(height: 12.0),
                      MedButton(
                        fullWidth: true,
                        label: context.l10n.patientPicker_createUrgentPatientButton,
                        variant: MedButtonVariant.danger,
                        prefixIcon: const Icon(PhosphorIconsBold.plus),
                        onPressed: _openCreateSheet,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),

        if (_isCreateSheetOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeCreateSheet,
              child: Container(color: Colors.black.withValues(alpha: 0.05)),
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
              child: _UrgentPatientCreateSheetContent(
                services: state.availableServices,
                onCancel: _closeCreateSheet,
                onCreated: (h) {
                  _closeCreateSheet();
                  widget.onPatientSelected(h, state.tab, true);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UrgentPatientCreatedCard extends StatelessWidget {
  const _UrgentPatientCreatedCard({required this.patient, required this.isDeleting, required this.onDelete});

  final Hospitalization patient;
  final bool isDeleting;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIcons.warningCircle(PhosphorIconsStyle.fill), size: 40, color: MedColors.red),
          const SizedBox(height: 12.0),
          Text(patient.patient?.fullName ?? '-', style: MedTextStyles.titleSm(), textAlign: TextAlign.center),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: MedSpacing.lg),
            child: Text(
              // TODO(Feyzullah): gerçek ARB key'ini oluştur.
              'Acil hasta oluşturuldu, normal akışa dönmek istiyorsanız acil hastayı silmeniz gerekiyor.',
              style: MedTextStyles.bodySm(color: MedColors.text3),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16.0),
          MedButton(
            label: context.l10n.common_deleteTooltip,
            variant: MedButtonVariant.danger,
            isLoading: isDeleting,
            prefixIcon: const Icon(PhosphorIconsBold.trash),
            onPressed: isDeleting ? null : onDelete,
          ),
        ],
      ),
    );
  }
}
