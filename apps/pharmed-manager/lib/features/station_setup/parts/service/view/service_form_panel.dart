import 'package:flutter/material.dart';
import '../../../../../../widgets/side_panel.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../core/core.dart';
import '../../../notifier/station_setup_notifier.dart';
import '../notifier/service_form_notifier.dart';
import '../notifier/service_notifier.dart';

part 'room_field.dart';

class ServiceFormPanel extends StatelessWidget {
  const ServiceFormPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final setupNotifier = context.watch<StationSetupNotifier>();
    final formKey = GlobalKey<FormState>();
    final isNew = setupNotifier.selectedService == null;

    return ChangeNotifierProvider(
      key: ValueKey(setupNotifier.selectedService?.id ?? 'new'),
      create: (BuildContext context) => ServiceFormNotifier(
        createServiceUseCase: context.read(),
        updateServiceUseCase: context.read(),
        service: setupNotifier.selectedService,
        deleteRoomUseCase: context.read(),
        deleteBedUseCase: context.read(),
      ),
      child: Consumer<ServiceFormNotifier>(
        builder: (context, notifier, _) {
          return SidePanel(
            title: isNew ? context.l10n.stationSetup_service_formTitleNew : context.l10n.stationSetup_service_formTitleEdit,
            subtitle: isNew
                ? context.l10n.stationSetup_service_formSubtitleNew
                : context.l10n.stationSetup_service_formSubtitleEdit,
            isLoading: notifier.isSubmitting,
            onClose: setupNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                final wasCreate = notifier.isCreate;
                await notifier.submit();

                if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(
                    context,
                    wasCreate
                        ? context.l10n.stationSetup_service_createdSuccessMessage
                        : context.l10n.stationSetup_service_updatedSuccessMessage,
                  );
                  context.read<StationSetupNotifier>().closePanel();
                  context.read<ServiceNotifier>().fetch();
                } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
                  MessageUtils.showErrorDialog(context, notifier.statusMessage);
                }
              }
            },
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: AppDimensions.registrationDialogSpacing,
                children: const [
                  _NameField(),
                  Row(
                    spacing: AppDimensions.registrationDialogSpacing,
                    children: [
                      Expanded(child: _BranchField()),
                      Expanded(child: _UserField()),
                    ],
                  ),
                  _StatusField(),
                  RoomField(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return MedTextInputField(
          label: context.l10n.stationSetup_service_nameLabel,
          initialValue: notifier.service.name,
          onChanged: notifier.updateName,
          validator: (v) => Validators.cannotBlankValidator(v),
        );
      },
    );
  }
}

class _BranchField extends StatelessWidget {
  const _BranchField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return MedSelectionField<Branch>(
          label: context.l10n.stationSetup_service_branchLabel,
          title: context.l10n.stationSetup_service_branchSelectTitle,
          initialValue: notifier.service.branch,
          dataSource: (skip, take, search) =>
              context.read<GetBranchesUseCase>().call(GetBranchesParams(skip: skip, take: take, search: search)),
          labelBuilder: (w) => w.name ?? '—',
          onSelected: notifier.updateBranch,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
        );
      },
    );
  }
}

class _UserField extends StatelessWidget {
  const _UserField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return MedSelectionField<User>(
          label: context.l10n.stationSetup_service_userLabel,
          initialValue: notifier.service.user,
          labelBuilder: (user) => user.fullName,
          onSelected: notifier.updateUser,
          dataSource: (skip, take, search) =>
              context.read<GetUsersUseCase>().call(GetUsersParams(skip: skip, take: take, search: search)),
        );
      },
    );
  }
}

class _StatusField extends StatelessWidget {
  const _StatusField();

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceFormNotifier>(
      builder: (context, notifier, _) {
        return MedDropdownInputField<Status>(
          label: context.l10n.stationSetup_common_statusLabel,
          options: Status.values,
          initialValue: notifier.service.status,
          onChanged: notifier.updateStatus,
          labelBuilder: (status) => status?.label,
          validator: (value) => Validators.cannotBlankValidator(value?.toString()),
        );
      },
    );
  }
}
