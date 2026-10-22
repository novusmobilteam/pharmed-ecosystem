part of '../view/drug_form_panel.dart';

/// Kabin tarafındaki davranış bayrakları; 3 sütunlu ızgara.
class CheckboxSection extends StatelessWidget {
  const CheckboxSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: MedSpacing.md,
      children: [
        _FormRow(
          children: [
            _GridToggle(_MultiPatientAccessTile()),
            _GridToggle(_SingleUseTile()),
            _GridToggle(_LowerDoseTile()),
          ],
        ),
        _FormRow(
          children: [_GridToggle(_RfidTile()), _GridToggle(_CameraRecordingTile()), _GridToggle(_TakeGiveButtonTile())],
        ),
        _FormRow(
          children: [
            _GridToggle(_RequirePharmacyApprovalForDisposalTile()),
            _GridToggle(_FireOrderRenewableTile()),
            SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}

/// Izgara hücresinde sola hizalı checkbox; sütuna sığmayan etiket küçültülür.
class _GridToggle extends StatelessWidget {
  const _GridToggle(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child),
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

/// Serum kabininde Al-Ver tuşlarıyla miktar doğrulaması — rafın ayarıyla
/// birlikte açıksa alım/iadede girilen miktar tuş değeriyle eşleşmelidir.
class _TakeGiveButtonTile extends StatelessWidget {
  const _TakeGiveButtonTile();

  @override
  Widget build(BuildContext context) {
    return Consumer<DrugFormNotifier>(
      builder: (context, vm, _) {
        return MedCheckboxField(
          value: vm.drug.isTakeGiveButtonActive,
          onChanged: (_) => vm.toggleTakeGiveButton(),
          label: context.l10n.medicine_checkboxTakeGiveButton,
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
