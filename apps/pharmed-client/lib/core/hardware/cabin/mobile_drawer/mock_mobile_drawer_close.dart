// [SWREQ-CORE-006] Sahte donanımda mobil çekmecenin "kapatılması".
//
// Mobil işlemlerde (dolum, alım, sayım, boşaltma) "İşlemi tamamla" kaydı
// çekmece AÇIKKEN yapar, sonra ekran fiziksel kapanışı bekler (WaitingClose).
// Bilgisayar test sürümünde (HARDWARE=mock) kapatacak gerçek bir çekmece
// olmadığı için mock servis ~60 sn sonra kendiliğinden kapanıyordu. Kayıt
// başarılı olup WaitingClose'a geçildiği anda bu fonksiyon çağrılır ve mock
// servise kapanış bildirilir — akış gerçekteki gibi WaitingClose → Closed →
// Success ilerler.
//
// Gerçek donanımda (HARDWARE=real) hiçbir şey yapmaz; kapanış her zaman
// sensörden gelir.
//
// Sınıf: Class B

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../providers/providers.dart';
import '../../hardware_mode.dart';

void closeMockMobileDrawerAfterSave(Ref ref) {
  if (!HardwareConfig.isMock) return;
  MedLogger.info(
    unit: 'SW-UNIT-MOCK-DRAWER',
    swreq: 'SWREQ-CORE-006',
    message: 'Sahte donanım: kayıt sonrası mobil çekmece kapatıldı',
  );
  ref.read(cabinOperationServiceProvider).triggerManualClose();
}
