part of '../view/drug_form_view.dart';

class PersonelField extends StatelessWidget {
  const PersonelField({
    super.key,
    this.enabled = true,
    required this.onChanged,
    this.initialValue,
    this.requireValidation = false,
  });

  final bool enabled;
  final ValueChanged<List<User>?> onChanged;
  final List<User>? initialValue;
  final bool requireValidation;

  @override
  Widget build(BuildContext context) {
    final label = 'Personel';

    return MultiSelectionField<User>(
      label: label,
      enabled: enabled,
      validator: (users) {
        if ((users == null || users.isEmpty) && requireValidation) {
          return Validators.cannotBlankValidator(null);
        } else {
          return null;
        }
      },
      initialValue: initialValue,
      dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(GetUsersParams()),
      labelBuilder: (user) => user?.fullName,
      onSelected: (user) => onChanged(user),
    );
  }
}
