import 'package:pharmed_core/pharmed_core.dart';

/// Operasyon kayıtlarının kalıcı giden kutusu (transactional outbox).
///
/// Kayıt önce lokal olarak kalıcı hale getirilir, upload ayrı bir süreçte
/// ve kendi hızında yapılır. Operasyon akışı ağ durumundan hiç etkilenmez.
abstract interface class IOperationRecordingOutbox {
  /// Operasyon başında çağrılır (write-ahead). Çökme sonrası kurtarma için
  /// operasyon bilgisini staging alanına yazar. [SWREQ-CAM-021]
  Future<void> stage(OperationRecordingStart start);

  /// Operasyon bitince çağrılır: videoyu arşiv konumuna taşır, metadata
  /// dosyasını yazar ve upload kuyruğuna alır. [SWREQ-CAM-022]
  Future<Result<void>> commit(OperationRecording recording);
}
