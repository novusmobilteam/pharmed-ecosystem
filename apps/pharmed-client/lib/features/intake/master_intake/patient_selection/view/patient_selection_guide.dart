// features/intake/patient_selection/view/intake_patient_selection_guide.dart
//
// [SWREQ-CLI-MINTAKE-XXX] [IEC 62304 §5.5]
// İlaç alım ekranına özel hasta seçim panelinin SAF sunum katmanı.
// Hiçbir provider bilmez. Reçeteler/Yönlendirilmiş sekmesi, Hastalarım/Tüm
// Hastalar/Acil toggle'ı, order durumu toggle'ı ve acil hasta oluşturma
// modu burada gömülü olarak render edilir — filtre dialogu artık sadece
// servis + (ordered modda) durum filtresini içerir.

import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart' hide PatientViewType;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../notifier/patient_selection_state.dart';

// features/intake/patient_selection/view/intake_patient_selection_guide.dart
//
// [SWREQ-CLI-MINTAKE-XXX] [IEC 62304 §5.5]
// İlaç alım ekranına özel hasta seçim panelinin SAF sunum katmanı.
// Hiçbir provider bilmez. Reçeteler/Yönlendirilmiş sekmesi, Hastalarım/Tüm
// Hastalar/Acil chip grubu, order durumu toggle'ı burada gömülü render
// edilir. Acil hasta oluşturma SHEET'i artık burada AÇILMIYOR — sadece
// onOpenCreateSheet callback'i tetiklenir; sheet'in kendisi (Stack overlay,
// local state) IntakePatientSelectionPanel'de yaşıyor (bkz. panel dosyası),
// çünkü panel sınırları içinde kalması gerekiyor (route/Overlay tabanlı
// showModalBottomSheet ekranın tamamını kaplardı).

class IntakePatientSelectionGuide extends StatelessWidget {
  const IntakePatientSelectionGuide({
    super.key,
    required this.state,
    required this.selectedPatient,
    required this.onPatientTap,
    required this.onTabChanged,
    required this.onSearchChanged,
    required this.onTogglePatientView,
    required this.onToggleOrderlessStatus,
    required this.onServiceFilterApply,
    required this.onEnterUrgentTab,
    required this.onExitUrgentTab,
    required this.onOpenCreateSheet,
    this.isLocked = false,
  });

  final IntakePatientSelectionReady state;
  final Hospitalization? selectedPatient;
  final ValueChanged<Hospitalization> onPatientTap;
  final ValueChanged<IntakePatientTab> onTabChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onTogglePatientView;
  final VoidCallback onToggleOrderlessStatus;
  final ValueChanged<Map<String, dynamic>> onServiceFilterApply;

  /// "Acil" chip'ine basılınca — listeyi urgent hastalara filtreler (mod
  /// değişimi), SHEET AÇMAZ.
  final VoidCallback onEnterUrgentTab;

  /// Acil sekmesinden normal bir chip'e geçilince.
  final VoidCallback onExitUrgentTab;

  /// "+ Acil Hasta Oluştur" butonu — panelin kendi Stack overlay'indeki
  /// sheet'i açar (bkz. IntakePatientSelectionPanel._openCreateSheet).
  final VoidCallback onOpenCreateSheet;

  final bool isLocked;

  List<FilterField> get _filterFields {
    if (state.tab == IntakePatientTab.redirected) return const [];
    return [
      DropdownFilterField<HospitalService?>(
        key: 'service',
        label: 'Servis',
        initialValue: state.selectedService,
        options: [null, ...state.availableServices],
        labelBuilder: (s) => s?.name ?? 'Tümü',
        defaultValue: null,
      ),
      if (state.isOrderedFilterActive)
        DropdownFilterField<PatientFilterType>(
          key: 'filter',
          label: 'Reçete Durumu',
          initialValue: state.filter,
          options: PatientFilterType.values,
          labelBuilder: (f) => f?.label,
          defaultValue: PatientFilterType.all,
        ),
    ];
  }

  Future<void> _openFilterDialog(BuildContext context) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => PatientSelectionFilterDialog(fields: _filterFields),
    );
    if (result == null) return;
    onServiceFilterApply(result);
  }

  List<PatientViewType> get viewTypes {
    if (state.isUrgentSegmentVisible) {
      return PatientViewType.values;
    }
    return [PatientViewType.allPatients, PatientViewType.myPatients];
  }

  PatientViewType get _selectedViewType {
    if (state.mode == PatientListMode.urgentCreate) return PatientViewType.urgent;
    return state.viewType == PatientViewType.myPatients ? PatientViewType.myPatients : PatientViewType.allPatients;
  }

  void _onViewTypeChanged(PatientViewType type) {
    if (type == PatientViewType.urgent) {
      onEnterUrgentTab();
      return;
    }
    if (state.mode == PatientListMode.urgentCreate) {
      onExitUrgentTab();
    }
    final wantsMine = type == PatientViewType.myPatients;
    final isCurrentlyMine = state.viewType == PatientViewType.myPatients;
    if (wantsMine != isCurrentlyMine) onTogglePatientView();
  }

  String viewTypeLabel(BuildContext context, PatientViewType type) {
    switch (type) {
      case PatientViewType.allPatients:
        return context.l10n.enumCore_patientFilterAll;
      case PatientViewType.myPatients:
        return context.l10n.patientPicker_myPatientsToggleLabel;
      case PatientViewType.urgent:
        return context.l10n.dashboard_priorityUrgentLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrgentTab = state.mode == PatientListMode.urgentCreate;

    return IgnorePointer(
      ignoring: isLocked,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Container(
          padding: MedSpacing.panelInsetPadding,
          decoration: MedDecoration.panelDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sekme: Reçeteler / Yönlendirilmiş ──
              MedSegmentedButton(
                selectedIndex: state.tab.index,
                onChanged: (i) => onTabChanged(IntakePatientTab.values[i]),
                labels: [context.l10n.intake_tab_prescriptions, context.l10n.intake_tab_redirectedOrders],
              ),
              const SizedBox(height: 6.0),

              TextFormField(
                onChanged: onSearchChanged,
                style: MedTextStyles.bodyMd(),
                decoration: InputDecoration(
                  prefixIcon: Icon(PhosphorIcons.magnifyingGlass(), size: 20.0),
                  hintText: context.l10n.patientPicker_searchHint,
                  suffixIcon: _filterFields.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _openFilterDialog(context),
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
                        options: viewTypes,
                        selected: _selectedViewType,
                        onChanged: _onViewTypeChanged,
                        labelBuilder: (type) => viewTypeLabel(context, type),
                        bgColor: _selectedViewType == PatientViewType.urgent ? MedColors.red : MedColors.blue,
                      ),
                    ),
                    if (state.isStatusToggleVisible)
                      MedToggleButton(
                        label: state.viewOrderStatus.isOrdered
                            ? context.l10n.patientPicker_orderedToggleLabel
                            : context.l10n.patientPicker_orderlessToggleLabel,
                        onTap: onToggleOrderlessStatus,
                        selected: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),

              // ── Aktif filtre chip'leri (servis/durum) — acil sekmesinde gizli ──
              if (!isUrgentTab)
                Builder(
                  builder: (context) {
                    final active = _filterFields.where((f) => f.isClearable && f.isActive(f.initialValue)).toList();
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
                                onDeleted: () => onServiceFilterApply({f.key: f.defaultValue}),
                                shape: MedChipShape.pill,
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),

              // ── Liste (fetch sırasında iskelet sabit kalır) ──
              Expanded(
                child: Stack(
                  children: [
                    state.visiblePatients.isEmpty && !state.isFetching
                        ? EmptyStateWidget(
                            variant: EmptyStateVariant.noResults,
                            // Acil sekmesinde boş liste "henüz acil hasta yok" anlamına
                            // gelir — arama sonucu boşluğundan farklı bir mesaj gerekebilir,
                            // gerekirse EmptyStateWidget'a ayrı bir variant eklenir.
                          )
                        : ListView.separated(
                            itemCount: state.visiblePatients.length,
                            separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
                            itemBuilder: (context, index) {
                              final h = state.visiblePatients[index];
                              final isSelected = selectedPatient?.id == h.id;
                              return PatientSelectionCard(
                                hospitalization: h,
                                isSelected: isSelected,
                                onTap: () => onPatientTap(h),
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

              // ── Acil sekmesi: "+ Acil Hasta Oluştur" — sheet'i panel açar ──
              if (isUrgentTab) ...[
                const SizedBox(height: 12.0),
                MedButton(
                  fullWidth: true,
                  label: context.l10n.patientPicker_createUrgentPatientButton,
                  variant: MedButtonVariant.danger,
                  prefixIcon: const Icon(PhosphorIconsBold.plus),
                  onPressed: onOpenCreateSheet,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
