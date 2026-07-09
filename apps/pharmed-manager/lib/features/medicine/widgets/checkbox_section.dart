part of '../view/drug_form_panel.dart';

class CheckboxSection extends StatelessWidget {
  const CheckboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Flex(
      spacing: AppDimensions.registrationDialogSpacing / 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      direction: Axis.horizontal,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [_MultiPatientAccessTile(), _SingleUseTile(), _LowerDoseTile(), _RfidTile()],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_CameraRecordingTile(), _IndependentMaterialTile()],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_RequirePharmacyApprovalForDisposalTile(), _FireOrderRenewableTile()],
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
        return MedCheckboxField(
          value: vm.drug.isCanLowerDose,
          onChanged: (_) => vm.toggleLowerDose(),
          label: context.l10n.medicine_checkboxLowerDose,
        );
      },
    );
  }
}

class _RfidTile extends StatelessWidget {
  const _RfidTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return MedCheckboxField(
          value: vm.drug.isRfidEnable,
          onChanged: (_) => vm.toggleRfid(),
          label: context.l10n.medicine_checkboxRfid,
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxMultiPatientAccess,
          value: vm.drug.isMultiplePatientAccess,
          onChanged: (_) => vm.toggleMultiPatientAccess(),
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxSingleUse,
          value: vm.drug.isSingleUse,
          onChanged: (_) => vm.toggleSingleUse(),
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxCameraRecording,
          value: vm.drug.isCameraRecording,
          onChanged: (_) => vm.toggleCameraRecording(),
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxIndependentMaterial,
          value: vm.drug.isIndependentMaterial,
          onChanged: (_) => vm.toggleIndependentMaterial(),
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxWastagePharmacyApproval,
          value: vm.drug.isWastagePharmacyApproval,
          onChanged: (_) => vm.toggleWastagePharmacyApproval(),
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
        return MedCheckboxField(
          label: context.l10n.medicine_checkboxWastageOrderRenewed,
          value: vm.drug.isWastageOrderRenewed,
          onChanged: (_) => vm.toggleWastageOrderRenewed(),
        );
      },
    );
  }
}
