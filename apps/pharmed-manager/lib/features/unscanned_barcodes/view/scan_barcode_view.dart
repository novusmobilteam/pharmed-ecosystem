part of 'unscanned_barcodes_screen.dart';

void showScanBarcodeView(BuildContext context, PrescriptionItem data) {
  showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<UnscannedBarcodesViewModel>(),
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
  UnscannedBarcodesViewModel? _viewModel;

  void _setupCallbacks(BuildContext context, UnscannedBarcodesViewModel vm) {
    vm.setCallbacks(
      key: UnscannedBarcodesViewModel.scanBarcodeOperation,
      onLoading: () => showLoading(context),
      onError: (message) {
        hideLoading(context);
        MessageUtils.showErrorDialog(context, message ?? 'Bir hata oluştu');
      },
      onSuccess: (message) {
        hideLoading(context);
        MessageUtils.showSuccessSnackbar(context, message);
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UnscannedBarcodesViewModel>(
      builder: (context, vm, _) {
        if (_viewModel != vm) {
          _viewModel = vm;
          _setupCallbacks(context, vm);
        }

        return RegistrationDialog(
          title: 'Karekod',
          maxHeight: 350,
          onSave: () async {
            await vm.scanBarcode(widget.item);
          },
          saveButtonText: 'Karekod Gir',
          child: Column(
            children: [
              TextInputField(
                label: 'Karekod',
                onChanged: (value) => vm.barcode = value ?? '',
              ),
            ],
          ),
        );
      },
    );
  }
}
