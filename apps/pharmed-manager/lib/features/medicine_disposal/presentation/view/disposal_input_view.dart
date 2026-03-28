part of 'disposal_view.dart';

class DisposalInputView extends StatefulWidget {
  const DisposalInputView({super.key});

  @override
  State<DisposalInputView> createState() => _DisposalInputViewState();
}

class _DisposalInputViewState extends State<DisposalInputView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DisposalNotifier>(
      builder: (context, notifier, _) {
        final typeText = notifier.type.label;

        return CustomDialog(
          title: '$typeText Edilecek Miktar',
          height: 600,
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PharmedSegmentedButton(
                selectedIndex: notifier.selectedTypeIndex,
                onChanged: (index) => notifier.changeType(index),
                labels: DisposeType.values.map((w) => w.label).toList(),
              ),
              SizedBox(height: 20),
              NumpadInputField(
                label: '$typeText Edilecek Miktar',
                onChanged: (value) => notifier.changeAmount(
                  value,
                  onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
                ),
                value: notifier.disposableAmount?.formatFractional ?? '-',
                unit: notifier.doseUnit,
              ),
              SizedBox(height: 20),
              _submitButton(notifier, context),
              SizedBox(height: 20),
              Text(
                'Not',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(notifier.destructionNote ?? '-'),
            ],
          ),
        );
      },
    );
  }

  Widget _submitButton(DisposalNotifier notifier, BuildContext context) {
    return SizedBox(
      width: context.width,
      child: PharmedButton(
        label: 'Tamamla',
        isLoading: notifier.isLoading(notifier.submitOp),
        onPressed: () {
          notifier.submit(
            onFailed: (message) {
              MessageUtils.showErrorSnackbar(context, message);
            },
            onSuccess: (message) {
              MessageUtils.showSuccessSnackbar(context, message);
              context.pop(true);
            },
          );
        },
      ),
    );
  }
}
