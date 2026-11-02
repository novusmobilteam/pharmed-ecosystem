part of '../view/drug_form_panel.dart';

class PersonelField extends StatelessWidget {
  const PersonelField({
    super.key,
    this.enabled = true,
    required this.onChanged,
    this.initialValue,
    this.requireValidation = false,
    this.loadAll = false,
  });

  final bool enabled;
  final ValueChanged<List<User>?> onChanged;
  final List<User>? initialValue;
  final bool requireValidation;

  /// true → sayfalama yok, diyalog açılınca tüm personel tek istekle çekilir
  /// (şahitli işlemler / imha alanları). false → mevcut sayfalı arama.
  final bool loadAll;

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.medicine_fieldPersonnel;

    return MedMultiSelectionField<User>(
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
      dataSource: loadAll
          ? _loadAllDataSource(
              fetchAll: () => context.read<GetUsersUseCase>().call(const GetUsersParams()),
              labelBuilder: (user) => user.fullName,
            )
          : (skip, take, search) =>
                context.read<GetUsersUseCase>().call(GetUsersParams(skip: skip, take: take, search: search)),
      labelBuilder: (user) => user.fullName,
      onSelected: (user) => onChanged(user),
    );
  }
}
