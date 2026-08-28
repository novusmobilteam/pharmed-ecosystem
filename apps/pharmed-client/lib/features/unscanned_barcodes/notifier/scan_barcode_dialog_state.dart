sealed class ScanBarcodeDialogState {
  const ScanBarcodeDialogState();
}

final class ScanBarcodeDialogIdle extends ScanBarcodeDialogState {
  const ScanBarcodeDialogIdle();
}

final class ScanBarcodeDialogSubmitting extends ScanBarcodeDialogState {
  const ScanBarcodeDialogSubmitting();
}

final class ScanBarcodeDialogError extends ScanBarcodeDialogState {
  const ScanBarcodeDialogError({required this.message});
  final String message;
}
