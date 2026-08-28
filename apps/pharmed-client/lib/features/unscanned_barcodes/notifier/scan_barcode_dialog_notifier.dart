import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';
import 'scan_barcode_dialog_state.dart';

final scanBarcodeDialogNotifierProvider =
    NotifierProvider.autoDispose<ScanBarcodeDialogNotifier, ScanBarcodeDialogState>(ScanBarcodeDialogNotifier.new);

class ScanBarcodeDialogNotifier extends AutoDisposeNotifier<ScanBarcodeDialogState> {
  ScanBarcodeUseCase get _scanBarcode => ref.read(scanBarcodeUseCaseProvider);

  @override
  ScanBarcodeDialogState build() => const ScanBarcodeDialogIdle();

  /// true → başarılı, dialog kapatılmalı. false → hata state zaten set edildi, dialog açık kalmalı.
  Future<bool> submit({required int prescriptionItemId, required String qrCode}) async {
    final trimmed = qrCode.trim();
    if (trimmed.isEmpty) {
      state = const ScanBarcodeDialogError(message: 'Karekod boş olamaz');
      return false;
    }

    state = const ScanBarcodeDialogSubmitting();
    try {
      final result = await _scanBarcode.call(prescriptionItemId, trimmed);
      return result.when(
        ok: (_) => true,
        error: (e) {
          state = ScanBarcodeDialogError(message: e.message);
          return false;
        },
      );
    } catch (e) {
      // Result sözleşmesi bozulsa bile dialog sonsuz "submitting"de takılı kalmasın
      state = ScanBarcodeDialogError(message: e.toString());
      return false;
    }
  }
}
