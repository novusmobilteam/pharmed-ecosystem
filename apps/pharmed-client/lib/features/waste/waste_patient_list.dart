import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

/// Sol panel — hasta listesi + arama.
class WastePatientList extends StatelessWidget {
  const WastePatientList({
    super.key,
    required this.patients,
    required this.selectedPatient,
    required this.isPatientLoading,
    required this.search,
    required this.onPatientTap,
    required this.onSearchChanged,
  });

  final List<Hospitalization> patients;
  final Hospitalization? selectedPatient;
  final bool isPatientLoading;
  final String search;
  final ValueChanged<Hospitalization> onPatientTap;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MedSpacing.md * 2),
      child: Column(
        spacing: 12.0,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextInputField(
            hintText: 'Hasta ara...',
            initialValue: search,
            onChanged: (query) => onSearchChanged(query ?? ''),
          ),
          Expanded(
            child: patients.isEmpty
                ? const EmptyStateWidget(variant: EmptyStateVariant.noResults)
                : ListView.separated(
                    itemCount: patients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: MedSpacing.xs / 2),
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
                  ),
          ),
        ],
      ),
    );
  }
}
