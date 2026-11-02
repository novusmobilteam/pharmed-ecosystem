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
      // Sayfalama yok: diyalog açılınca tüm istasyonlar tek istekle çekilir.
      dataSource: _loadAllDataSource(
        fetchAll: () => context.read<GetStationsUseCase>().call(PagedQueryParams()),
        labelBuilder: (station) => station.name,
      ),
      labelBuilder: (station) => station.name,
      onSelected: (station) => onChanged(station),
    );
  }
}
