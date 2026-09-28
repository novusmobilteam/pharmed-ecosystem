import 'package:pharmed_core/pharmed_core.dart';

class ScanBarcodeUseCase {
  final IPrescriptionRepository _repository;

  ScanBarcodeUseCase(this._repository);

  Future<Result<void>> call(int prescriptionItemId, String qrCode) {
    return _repository.scanBarcode(prescriptionItemId: prescriptionItemId, qrCode: qrCode);
  }
}

/// TODO : Alım ekranında da birebir aynı fonksiyon kullanılıyor.
/// Aslında manager ve client ekranlarında yer alan Okutulmayan Karekodlar ekranlarında üstteki
/// usecase kullanılıyordu fakat bu fonksiyonlar sadece birer tane qrcode aldığı için bu fonksiyona geçildi
/// Şu an için bilinen bir hata: qr code okuma işleminin ardından ilgili kayıtlar silinmiyor.
class ScanQrCodeParams {
  const ScanQrCodeParams({required this.details});

  final List<QrCodeDetail> details;

  Map<String, dynamic> toJson() => {'detail': details.map((d) => d.toJson()).toList()};
}

class QrCodeDetail {
  const QrCodeDetail({required this.prescriptionDetailId, required this.qrCode});

  final int prescriptionDetailId;
  final List<String> qrCode;

  Map<String, dynamic> toJson() => {'prescriptionDetailId': prescriptionDetailId, 'qrCode': qrCode};
}

class ScanQrCodeUseCase {
  const ScanQrCodeUseCase(this._repository);

  final IPrescriptionRepository _repository;

  Future<Result<void>> call(ScanQrCodeParams params) => _repository.scanQrCodes(params);
}
