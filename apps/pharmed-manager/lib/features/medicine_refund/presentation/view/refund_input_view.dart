part of 'medicine_refund_view.dart';

class ReturnInputView extends StatefulWidget {
  const ReturnInputView({super.key});

  @override
  State<ReturnInputView> createState() => _ReturnInputViewState();
}

class _ReturnInputViewState extends State<ReturnInputView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineRefundNotifier>(
      builder: (context, notifier, _) {
        return CustomDialog(
          title: 'İade Miktarı',
          height: 600,
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              NumpadInputField(
                value: notifier.refundAmount?.formatFractional ?? '-',
                unit: notifier.selectedItem?.medicine?.operationUnit ?? 'Adet',
                label: 'İade Miktarı',
                onChanged: (val) {
                  notifier.changeAmount(
                    val,
                    onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                  );
                },
              ),
              PharmedButton(
                label: 'İade Et',
                isActive: (notifier.refundAmount ?? 0.0) > 0,
                isLoading: notifier.isLoading(notifier.submitOp) || notifier.isLoading(notifier.checkOp),
                onPressed: () {
                  if (notifier.type == ReturnType.toPharmacy) {
                    MessageUtils.showConfirmDialog(
                      context: context,
                      action: ConfirmAction.save,
                      customTitle: notifier.type.label,
                      customMessage:
                          'İade işleminizin tamamlanması için işlem sonrasında eczacınızdan onay almanız gerekmektedir. İşleme devam etmek istiyor musunuz?',
                      onConfirm: () => _onConfirm(context, notifier),
                    );
                  } else {
                    _onConfirm(context, notifier);
                  }
                },
              ),
              Column(
                children: [
                  Text(
                    'İade Notu',
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(notifier.refundNote ?? '-'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

void _onConfirm(BuildContext context, MedicineRefundNotifier notifier) {
  notifier.checkRefundStatus(
    onFailed: (message) => MessageUtils.showErrorSnackbar(context, message),
    onSuccess: (message) {
      context.pop();
      MessageUtils.showSuccessSnackbar(context, message);
    },
  );
}
