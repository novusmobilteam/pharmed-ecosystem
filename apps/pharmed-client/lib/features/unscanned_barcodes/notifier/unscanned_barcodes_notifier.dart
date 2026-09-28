import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/mixins.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_core/pharmed_core.dart';

final unscannedBarcodesNotifierProvider = ChangeNotifierProvider.autoDispose<UnscannedBarcodesNotifier>((ref) {
  return UnscannedBarcodesNotifier(
    getUnscannedBarcodesUseCase: ref.read(getUnscannedBarcodesUseCaseProvider),
    scanQrCodeUseCase: ref.read(scanQrCodeUseCaseProvider),
  );
});

class UnscannedBarcodesNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<PrescriptionItem> {
  final GetUnscannedBarcodesUseCase _getUnscannedBarcodesUseCase;
  final ScanQrCodeUseCase _scanQrCodeUseCase;

  UnscannedBarcodesNotifier({
    required GetUnscannedBarcodesUseCase getUnscannedBarcodesUseCase,
    required ScanQrCodeUseCase scanQrCodeUseCase,
  }) : _getUnscannedBarcodesUseCase = getUnscannedBarcodesUseCase,
       _scanQrCodeUseCase = scanQrCodeUseCase {
    fetch();
  }

  final OperationKey fetchOp = OperationKey.fetch();
  final OperationKey scanOp = OperationKey.custom('scan-qr');

  /// Kalemin okutulması gereken kutu adedi — dialog'daki okutma alanı sayısı.
  int requiredQrCountOf(PrescriptionItem item) {
    final count = item.medicine?.boxCountOf(item.dosePiece ?? 0) ?? 0;
    return count < 1 ? 1 : count;
  }

  /// İlacın barkodu — farklı ilacın karekodunu reddetmek için. İlaç değilse
  /// (sarf malzeme vb.) GTIN kontrolü yapılmaz.
  String? expectedGtinOf(PrescriptionItem item) => switch (item.medicine) {
    Drug(:final barcode) => barcode,
    _ => null,
  };

  @override
  Future<void> fetch() async {
    await fetchPagedData(
      fetchMethod: (skip, take) => _getUnscannedBarcodesUseCase.call(
        params: PagedQueryParams(searchQuery: searchQuery, skip: skip, take: take),
      ),
    );
  }

  /// QrScanDialog'un onSubmit'i. Hata dönerse dialog açık kalır; kullanıcı
  /// tekrar gönderebilir ya da iptal edebilir.
  Future<Result<void>> submit(PrescriptionItem item, List<Gs1Code> codes) async {
    if (codes.isEmpty) return const Result.ok(null);

    final result = await _scanQrCodeUseCase.call(
      ScanQrCodeParams(
        details: [
          QrCodeDetail(prescriptionDetailId: item.id ?? 0, qrCode: [for (final c in codes) c.raw]),
        ],
      ),
    );
    return result.when(ok: (_) => const Result.ok(null), error: (e) => Result.error(e));
  }
}
