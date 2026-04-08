import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmed_manager/core/widgets/side_panel.dart';
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
    final isNew = setupNotifier.editingService == null;

    return ChangeNotifierProvider(
      key: ValueKey(setupNotifier.editingService?.id ?? 'new'),
      create: (BuildContext context) => ServiceFormNotifier(
        createServiceUseCase: context.read(),
        updateServiceUseCase: context.read(),
        service: setupNotifier.editingService,
      ),
      child: Consumer<ServiceFormNotifier>(
        builder: (context, notifier, _) {
          return SidePanel(
            title: isNew ? 'Yeni Servis' : 'Servis Düzenle',
            subtitle: isNew ? 'Servis bilgilerini doldurun' : 'Servis bilgilerini güncelleyin',
            isLoading: notifier.isSubmitting,
            onClose: setupNotifier.closePanel,
            onSave: () async {
              if (formKey.currentState!.validate()) {
                await notifier.submit();

                if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
                  MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
                  context.read<StationSetupNotifier>().closePanel();
                  context.read<ServiceNotifier>().getServices();
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
        return TextInputField(
          label: 'Servis Adı',
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
        return SelectionField<Branch>(
          label: 'Branş',
          title: 'Branş Seç',
          initialValue: notifier.service.branch,
          dataSource: (skip, take, search) => context.read<GetBranchesUseCase>().call(GetBranchesParams()),
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
        return SelectionField<User>(
          label: 'Kullanıcı',
          initialValue: notifier.service.user,
          labelBuilder: (user) => user.fullName,
          onSelected: notifier.updateUser,
          dataSource: (skip, take, search) => context.read<GetUsersUseCase>().call(const GetUsersParams()),
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
        return DropdownInputField<Status>(
          label: 'Durumu',
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
