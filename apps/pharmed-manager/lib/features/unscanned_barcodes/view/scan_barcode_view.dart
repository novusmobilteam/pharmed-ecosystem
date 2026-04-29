part of 'unscanned_barcodes_screen.dart';

void showScanBarcodeView(BuildContext context, PrescriptionItem data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesNotifier>(),
      child: ScanBarcodeView(item: data),
    ),
  );
}

class ScanBarcodeView extends StatefulWidget {
  const ScanBarcodeView({super.key, required this.item});

  final PrescriptionItem item;

  @override
  State<ScanBarcodeView> createState() => _ScanBarcodeViewState();
}

class _ScanBarcodeViewState extends State<ScanBarcodeView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UnscannedBarcodesNotifier>(
      builder: (context, notifier, _) {
        return RegistrationDialog(
          title: 'Karekod',
          maxHeight: 350,
          onSave: () async {
            await notifier.scanBarcode(
              widget.item,
              onSuccess: (msg) {
                MessageUtils.showSuccessSnackbar(context, msg);
                context.pop();
              },
              onFailed: (msg) => MessageUtils.showErrorDialog(context, msg),
            );
          },
          saveButtonText: 'Karekod Gir',
          child: Column(
            children: [TextInputField(label: 'Karekod', onChanged: (value) => notifier.barcode = value ?? '')],
          ),
        );
      },
    );
  }
}
