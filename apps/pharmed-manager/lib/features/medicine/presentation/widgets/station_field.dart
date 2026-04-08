part of '../view/drug_form_view.dart';

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
    final label = 'İstasyon';

    return MultiSelectionField<Station>(
      label: label,
      enabled: enabled,
      initialValue: initialValue,
      dataSource: (skip, take, search) => context.read<GetStationsUseCase>().call(GetStationsParams()),
      labelBuilder: (station) => station?.name,
      onSelected: (station) => onChanged(station),
    );
  }
}
