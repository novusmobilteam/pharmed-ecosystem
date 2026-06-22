// cabin_connection_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../providers/providers.dart';
import 'cabin_connection_state.dart';

// cabin_connection_notifier.dart
final cabinConnectionProvider = NotifierProvider<CabinConnectionNotifier, CabinConnectionState>(
  CabinConnectionNotifier.new,
);

class CabinConnectionNotifier extends Notifier<CabinConnectionState> {
  @override
  CabinConnectionState build() => const CabinConnectionState(status: CabinConnectionStatus.disconnected);

  ICabinOperationService get _cabinOps => ref.read(cabinOperationServiceProvider);

  /// Uygulama açılışında (kurulum tamamlanmışsa) çağrılır.
  Future<void> connect() async {
    if (state.status == CabinConnectionStatus.connecting) return;

    state = const CabinConnectionState(status: CabinConnectionStatus.connecting);

    try {
      final manager = await _cabinOps.getOrScanManager();
      if (manager != null) {
        state = CabinConnectionState(status: CabinConnectionStatus.connected, managerAddress: manager.addressIndex);
        MedLogger.info(
          unit: 'CabinConnection',
          swreq: 'SWREQ-CABIN-OP-003',
          message: 'Karta bağlanıldı',
          context: {'adres': manager.addressIndex},
        );
      } else {
        state = const CabinConnectionState(status: CabinConnectionStatus.error, message: 'Yönetim kartı bulunamadı');
      }
    } catch (e) {
      state = CabinConnectionState(status: CabinConnectionStatus.error, message: e.toString());
    }
  }

  /// İşlem sonrası bağlantı koptuysa durumu güncellemek için
  /// (örn. getOrScanManager null dönerse işlem notifier'ı çağırabilir).
  void markDisconnected() {
    state = const CabinConnectionState(status: CabinConnectionStatus.error, message: 'Bağlantı koptu');
  }

  /// Manuel yeniden bağlanma (kullanıcı göstergeye tıklarsa ya da hata sonrası).
  Future<void> reconnect() => connect();
}
