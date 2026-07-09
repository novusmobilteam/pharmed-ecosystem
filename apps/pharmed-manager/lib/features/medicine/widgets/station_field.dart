part of '../view/drug_form_panel.dart';

class StationField extends StatelessWidget {
  const StationField({
    super.key,
    this.enabled = true,
    required this.onChanged,
    this.initialValue,
    this.requireValidation = false,
  });

  final bool enabled;
  final ValueChanged<List<Station>?> onChanged;
  final List<Station>? initialValue;
  final bool requireValidation;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.medicine_fieldStation;

    return MedMultiSelectionField<Station>(
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      dataSource: (skip, take, search) =>
          context.read<GetStationsUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
      labelBuilder: (station) => station.name,
      onSelected: (station) => onChanged(station),
    );
  }
}
