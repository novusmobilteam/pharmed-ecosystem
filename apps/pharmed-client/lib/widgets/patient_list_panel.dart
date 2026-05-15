import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'hospitalization_card.dart';

/// Genel amaçlı hasta listesi paneli.
///
/// Sol panel olarak tasarlanmıştır; arama alanı, hasta sayısı chip'i
/// ve seçili hasta durumu yönetimi içerir.
///
/// ```dart
/// MedPatientListPanel(
///   patients: state.patients,
///   selectedPatient: state.selectedPatient,
///   isPatientLoading: state.isLoading,
///   search: state.search,
///   onPatientTap: notifier.selectPatient,
///   onSearchChanged: notifier.onSearchChanged,
/// )
/// ```
class PatientListPanel extends StatelessWidget {
  const PatientListPanel({
    super.key,
    required this.patients,
    required this.selectedPatient,
    required this.isPatientLoading,
    required this.search,
    required this.onPatientTap,
    required this.onSearchChanged,
    this.title = 'Hastalar',
  });

  final List<Hospitalization> patients;
  final Hospitalization? selectedPatient;
  final bool isPatientLoading;
  final String search;
  final ValueChanged<Hospitalization> onPatientTap;
  final ValueChanged<String> onSearchChanged;

  /// Panel başlığı. Varsayılan: `'Hastalar'`
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: title, count: patients.length),
          const Divider(height: 1, thickness: 1, color: MedColors.border),
          _SearchBar(search: search, onChanged: onSearchChanged),
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
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: MedSpacing.xl,
        right: MedSpacing.xl,
        top: MedSpacing.xl,
        bottom: MedSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: MedTextStyles.titleMd()),
          MedInfoChip(info: '$count Hasta'),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.search, required this.onChanged});

  final String search;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
      child: MedTextInputField(
        hintText: 'Hasta ara...',
        prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
        initialValue: search,
        onChanged: (query) => onChanged(query ?? ''),
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
      padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.md),
      itemCount: patients.length,
      separatorBuilder: (_, _) => const SizedBox(height: MedSpacing.sm),
      itemBuilder: (context, index) {
        final h = patients[index];
        final isSelected = selectedPatient?.id == h.id;
        return HospitalizationCard(
          hospitalization: h,
          isSelected: isSelected,
          isLoading: isSelected && isPatientLoading,
          onTap: () => onPatientTap(h),
        );
      },
    );
  }
}
