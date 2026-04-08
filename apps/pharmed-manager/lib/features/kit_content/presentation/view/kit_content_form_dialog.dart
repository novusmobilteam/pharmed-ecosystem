import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../../../core/core.dart';

import '../../domain/entity/kit_content.dart';
import '../notifier/kit_content_form_notifier.dart';

Future<bool> showKitContentFormDialog(BuildContext context, {int? kitId, KitContent? initial}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => KitContentFormNotifier(
        kitContent: initial,
        kitId: kitId,
        createKitContentUseCase: context.read(),
        updateKitContentUseCase: context.read(),
      ),
      child: const KitContentFormDialog(),
    ),
  );

  return result ?? false;
}

class KitContentFormDialog extends StatefulWidget {
  const KitContentFormDialog({super.key});

  @override
  State<KitContentFormDialog> createState() => _KitContentFormDialogState();
}

class _KitContentFormDialogState extends State<KitContentFormDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<KitContentFormNotifier>(
      builder: (context, notifier, _) {
        final String title = notifier.isCreate ? 'Kit İçeriği Ekle' : 'Kit İçeriği Düzenle';
        return RegistrationDialog(
          title: title,
          width: 600,
          isLoading: notifier.isLoading(notifier.submitOp),
          onSave: () async {
            if (formKey.currentState!.validate()) {
              await notifier.submit(
                onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                onSuccess: (msg) {
                  MessageUtils.showSuccessSnackbar(context, msg);
                  context.pop(true);
                },
              );
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: const [_MaterialField(), _PieceField()],
            ),
          ),
        );
      },
    );
  }
}

class _MaterialField extends StatelessWidget {
  const _MaterialField();

  @override
  Widget build(BuildContext context) {
    return Consumer<KitContentFormNotifier>(
      builder: (context, notifier, _) {
        return SelectionField<Medicine>(
          label: 'Malzeme',
          title: 'Malzeme',
          initialValue: notifier.kitContent.medicine,
          labelBuilder: (medicine) => medicine.name ?? '-',
          dataSource: (skip, take, search) => context.read<IMedicineRepository>().getMedicines(),
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          onSelected: notifier.updateMaterial,
        );
      },
    );
  }
}

class _PieceField extends StatelessWidget {
  const _PieceField();

  @override
  Widget build(BuildContext context) {
    return Consumer<KitContentFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Adet',
          initialValue: notifier.kitContent.piece.toCustomString(),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) => Validators.cannotBlankValidator(v),
          onChanged: notifier.updatePiece,
        );
      },
    );
  }
}
