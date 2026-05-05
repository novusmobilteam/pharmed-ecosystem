// [SWREQ-HW-SER-002] [IEC 62304 §5.5]
// Uygulama yaşam döngüsü gözlemcisi — seri port temizleme.
//
// AMAÇ:
//   Hot restart veya uygulama kapanışında seri port handle'ının
//   OS tarafında düzgün serbest bırakılmasını sağlar.
//   Son kullanıcıyı etkilemez — sadece geliştirme ortamında kritiktir.
//
// KULLANIM:
//   main() içinde veya root widget'ta bir kez kaydet:
//     WidgetsBinding.instance.addObserver(SerialPortLifecycleObserver(service));
//
// Sınıf: Class B

import 'package:flutter/widgets.dart';

import 'serial_communication/i_serial_communication_service.dart';

class SerialPortLifecycleObserver extends WidgetsBindingObserver {
  SerialPortLifecycleObserver(this._serialService);

  final ISerialCommunicationService _serialService;

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        // Uygulama kapanıyor veya hot restart — handle'ı serbest bırak
        if (_serialService.isConnected) {
          await _serialService.disconnect();
        }
      case AppLifecycleState.paused:
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
