part of '../view/drug_form_view.dart';

class CheckboxSection extends StatelessWidget {
  const CheckboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Flex(
      spacing: AppDimensions.registrationDialogSpacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.horizontal,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            _MultiPatientAccessTile(),
            _SingleUseTile(),
            _LowerDoseTile(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            _CameraRecordingTile(),
            _IndependentMaterialTile(),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppDimensions.registrationDialogSpacing,
          children: [
            _RequirePharmacyApprovalForDisposalTile(),
            _FireOrderRenewableTile(),
          ],
        ),
      ],
    );
  }
}

class _LowerDoseTile extends StatelessWidget {
  const _LowerDoseTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Belirtilen dozdan düşük doz alınabilir',
          value: vm.drug.isCanLowerDose,
          onTap: vm.toggleLowerDose,
        );
      },
    );
  }
}

class _MultiPatientAccessTile extends StatelessWidget {
  const _MultiPatientAccessTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Çoklu Hasta Erişim',
          value: vm.drug.isMultiplePatientAccess,
          onTap: vm.toggleMultiPatientAccess,
        );
      },
    );
  }
}

class _SingleUseTile extends StatelessWidget {
  const _SingleUseTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Tek Kullanımlık',
          value: vm.drug.isSingleUse,
          onTap: vm.toggleSingleUse,
        );
      },
    );
  }
}

class _CameraRecordingTile extends StatelessWidget {
  const _CameraRecordingTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Kamera Kayıt',
          value: vm.drug.isCameraRecording,
          onTap: vm.toggleCameraRecording,
        );
      },
    );
  }
}

class _IndependentMaterialTile extends StatelessWidget {
  const _IndependentMaterialTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Serbest İlaç',
          value: vm.drug.isIndependentMaterial,
          onTap: vm.toggleIndependentMaterial,
        );
      },
    );
  }
}

class _RequirePharmacyApprovalForDisposalTile extends StatelessWidget {
  const _RequirePharmacyApprovalForDisposalTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Fire/İmha Eczane Onayı Alınsın mı?',
          value: vm.drug.isWastagePharmacyApproval,
          onTap: vm.toggleWastagePharmacyApproval,
        );
      },
    );
  }
}

class _FireOrderRenewableTile extends StatelessWidget {
  const _FireOrderRenewableTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return CustomCheckboxTile(
          label: 'Fire Order Yenilensin mi?',
          value: vm.drug.isWastageOrderRenewed,
          onTap: vm.toggleWastageOrderRenewed,
        );
      },
    );
  }
}
