part of '../view/drug_form_panel.dart';

class UnitField extends StatelessWidget {
  const UnitField({super.key, this.enabled = true, required this.onChanged, this.unit, this.isRequired = false});

  final bool enabled;
  final ValueChanged<Unit?> onChanged;
  final Unit? unit;
  final bool? isRequired;

  @override
  Widget build(BuildContext context) {
    final label = 'Birim';
    return TextInputField(
      label: label,
      enabled: enabled,
      initialValue: unit?.name,
      validator: (value) => (isRequired ?? false) ? Validators.cannotBlankValidator(value) : null,
      onChanged: (String? value) {},
      onTap: () async {
        final unit = await showUnitView(context);
        onChanged(unit);
      },
    );
  }
}
