part of 'inconsistency_screen.dart';

void showSolveInconsistencyView(BuildContext context, Inconsistency data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<InconsistencyNotifier>(),
      child: SolveInconsistencyView(item: data),
    ),
  );
}

class SolveInconsistencyView extends StatefulWidget {
  const SolveInconsistencyView({super.key, required this.item});

  final Inconsistency item;

  @override
  State<SolveInconsistencyView> createState() => _SolveInconsistencyViewState();
}

class _SolveInconsistencyViewState extends State<SolveInconsistencyView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<InconsistencyNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: context.l10n.enumCore_warningSubjectInconsistencyResolution,
          maxHeight: 300,
          width: 500,
          onSave: () async {
            await notifier.solveInconsistency(
              widget.item,
              onSuccess: () {
                MessageUtils.showSuccessSnackbar(context, context.l10n.common_operationSuccessMessage);
                Navigator.pop(context);
              },
              onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
            );
          },
          saveButtonText: context.l10n.common_completeButton,
          isLoading: notifier.isSolving,
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(
              hintText: context.l10n.common_descriptionLabel,
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => notifier.updateDescription(value),
          ),
        );
      },
    );
  }
}
