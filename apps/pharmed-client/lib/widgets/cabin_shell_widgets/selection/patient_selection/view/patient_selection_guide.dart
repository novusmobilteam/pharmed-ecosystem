import 'package:flutter/material.dart';
import 'package:pharmed_client/widgets/widgets.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Genel amaçlı hasta listesi paneli.
///
/// Sol panel olarak tasarlanmıştır; arama alanı, hasta sayısı chip'i
/// ve seçili hasta durumu yönetimi içerir.
class PatientSelectionGuide extends StatelessWidget {
  const PatientSelectionGuide({
    super.key,
    required this.patients,
    required this.selectedPatient,
    required this.isPatientLoading,
    required this.search,
    required this.onPatientTap,
    required this.onSearchChanged,
    this.title = 'Hasta Listesi',
    this.filterFields, // <-- yeni
    this.onFilterApply, // <-- yeni: dialog kapanınca sonucu dışarı verir
    this.footer,
    this.isLocked = false,
  });

  final List<Hospitalization> patients;
  final Hospitalization? selectedPatient;
  final bool isPatientLoading;
  final String search;
  final ValueChanged<Hospitalization> onPatientTap;
  final ValueChanged<String> onSearchChanged;
  final String title;

  /// Filtre popup'ında gösterilecek alanlar. null/boşsa ikon gösterilmez.
  final List<FilterField>? filterFields;

  /// Kullanıcı "Kaydet"e bastığında {key: yeniDeğer} map'i döner.
  /// Panel notifier bilmez — uygulamayı çağıran taraf yapar.
  final ValueChanged<Map<String, dynamic>>? onFilterApply;

  final Widget? footer;
  final bool isLocked;

  List<FilterField> get _activeFields =>
      filterFields?.where((f) => f.isClearable && f.isActive(f.initialValue)).toList() ?? const [];

  Future<void> _openFilterDialog(BuildContext context) async {
    if (filterFields == null || filterFields!.isEmpty) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => PatientSelectionFilterDialog(fields: filterFields!),
    );

    if (result == null) return;
    onFilterApply?.call(result);
  }

  void _clearFilter(FilterField field) {
    // Sadece bu alanı defaultValue'ya döndür; diğer alanlara dokunma.
    onFilterApply?.call({field.key: field.defaultValue});
  }

  @override
  Widget build(BuildContext context) {
    final activeFields = _activeFields;

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
              /// Search and Filter
              Row(
                spacing: 8.0,
                children: [
                  Expanded(
                    child: CabinOperationSearchField(
                      onChanged: onSearchChanged,
                      hintText: context.l10n.patientPicker_searchHint,
                    ),
                  ),
                  if (filterFields != null && filterFields!.isNotEmpty)
                    IconButton(
                      onPressed: () => _openFilterDialog(context),
                      icon: Icon(PhosphorIconsBold.faders, color: MedColors.text3),
                      constraints: const BoxConstraints(
                        minWidth: MedSpacing.touchTarget,
                        minHeight: MedSpacing.touchTarget,
                      ),
                    ),
                ],
              ),

              /// Active filters
              if (activeFields.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: MedSpacing.sm),
                  child: Wrap(
                    spacing: MedSpacing.sm,
                    runSpacing: MedSpacing.sm,
                    children: activeFields
                        .map(
                          (f) => MedChip(
                            label: f.activeLabel(f.initialValue),
                            size: MedChipSize.md,
                            style: MedChipStyle.info,
                            onDeleted: () => _clearFilter(f),
                            shape: MedChipShape.pill,
                          ),
                        )
                        .toList(),
                  ),
                ),
              SizedBox(height: 12.0),

              /// Body
              Expanded(
                child: patients.isEmpty
                    ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                    : _PatientList(
                        patients: patients,
                        selectedPatient: selectedPatient,
                        isPatientLoading: isPatientLoading,
                        onPatientTap: onPatientTap,
                      ),
              ),

              /// Footer
              ?footer,
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientList extends StatelessWidget {
  const _PatientList({
    required this.patients,
    required this.selectedPatient,
    required this.isPatientLoading,
    required this.onPatientTap,
  });

  final List<Hospitalization> patients;
  final Hospitalization? selectedPatient;
  final bool isPatientLoading;
  final ValueChanged<Hospitalization> onPatientTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
      itemBuilder: (context, index) {
        final h = patients[index];
        final isSelected = selectedPatient?.id == h.id;
        return PatientSelectionCard(
          hospitalization: h,
          isSelected: isSelected,
          isLoading: isSelected && isPatientLoading,
          onTap: () => onPatientTap(h),
        );
      },
    );
  }
}
