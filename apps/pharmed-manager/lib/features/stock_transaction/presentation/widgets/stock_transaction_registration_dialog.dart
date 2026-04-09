import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

import '../notifier/stock_transaction_form_notifier.dart';

class StockTransactionRegistrationDialog extends StatelessWidget {
  const StockTransactionRegistrationDialog({super.key, required this.type});

  final StockTransactionType type;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Consumer<StockTransactionFormNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: type.label,
          isLoading: notifier.isSubmitting,
          onSave: () {
            if (formKey.currentState!.validate()) {
              notifier.submit();
            }

            if (context.mounted && notifier.isSuccess(notifier.submitOp)) {
              MessageUtils.showSuccessSnackbar(context, notifier.statusMessage);
              context.pop(true);
            } else if (context.mounted && notifier.isFailed(notifier.submitOp)) {
              MessageUtils.showErrorDialog(context, notifier.statusMessage);
            }
          },
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: AppDimensions.registrationDialogSpacing,
              children: [
                Row(
                  spacing: AppDimensions.registrationDialogSpacing,
                  children: [
                    Expanded(child: _MaterialField()),
                    Expanded(child: _QuantityField()),
                  ],
                ),
                if (type == StockTransactionType.exit) _ServiceField(),
                _ExpirationDateField(),
              ],
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
    return Consumer<StockTransactionFormNotifier>(
      builder: (context, notifier, _) {
        return SelectionField<Medicine>(
          label: 'Malzeme',
          initialValue: notifier.transaction?.medicine,
          dataSource: (skip, take, search) => context.read<IMedicineRepository>().getMedicines(),
          validator: (value) => Validators.cannotBlankValidator(value?.name),
          labelBuilder: (value) => value.name,
          onSelected: notifier.updateMaterial,
        );
      },
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField();

  @override
  Widget build(BuildContext context) {
    return TextInputField(
      label: 'Miktar',
      onChanged: (value) {
        context.read<StockTransactionFormNotifier>().updateQuantity(int.tryParse(value ?? ""));
      },
    );
  }
}

class _ServiceField extends StatelessWidget {
  const _ServiceField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StockTransactionFormNotifier>(
      builder: (context, notifier, _) {
        return SelectionField<HospitalService>(
          label: 'Gönderilen Servis',
          initialValue: notifier.transaction?.service,
          dataSource: (skip, take, search) => context.read<IServiceRepository>().getServices(),
          labelBuilder: (value) => value.name,
          onSelected: notifier.updateService,
          validator: (value) => Validators.cannotBlankValidator(value?.name),
        );
      },
    );
  }
}

class _ExpirationDateField extends StatelessWidget {
  const _ExpirationDateField();

  @override
  Widget build(BuildContext context) {
    return Consumer<StockTransactionFormNotifier>(
      builder: (context, notifier, _) {
        return TextInputField(
          label: 'Son Kullanma Tarihi',
          initialValue: notifier.transaction?.expirationDate.formattedDate,
          hintText: '10/05/2025',
          inputFormatters: [Formatter.dateMaskFormatter],
          onChanged: notifier.updateExpirationDate,
        );
      },
    );
  }
}
