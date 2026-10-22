part of '../view/drug_form_panel.dart';

/// Serbest ilacın alınabileceği servisler. "Serbest İlaç" kapalıyken kilitli;
/// açıkken en az bir servis seçilmesi zorunludur (boş liste backend'de
/// "hiçbir servis" anlamına gelir).
class _IndependentServicesField extends StatelessWidget {
  const _IndependentServicesField();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        final enabled = vm.drug.isIndependentMaterial;
        return MedMultiSelectionField<HospitalService>(
          key: ValueKey(vm.independentServices),
          label: context.l10n.medicine_fieldIndependentServices,
          title: context.l10n.medicine_independentServicesDialogSelectTitle,
          enabled: enabled,
          initialValue: vm.independentServices,
          labelBuilder: (s) => s.name ?? '#${s.id}',
          validator: (services) {
            if (enabled && (services == null || services.isEmpty)) {
              return Validators.cannotBlankValidator(null);
            }
            return null;
          },
          dataSource: (skip, take, search) =>
              context.read<GetServicesUseCase>().call(PagedQueryParams(skip: skip, take: take, searchQuery: search)),
          onSelected: vm.updateIndependentServices,
        );
      },
    );
  }
}
