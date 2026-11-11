// [SWREQ-CORE-007] Sunucu yanıtlarındaki `Date` başlığından ServerClock'u günceller.
// Cihaz saati sunucudan 2 dakikadan fazla saparsa bir kez uyarı loglanır
// (sahada yanlış saatli cihazı bulmak için).
// Sınıf: Class B

import 'package:dio/dio.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';

class ServerClockInterceptor extends Interceptor {
  static const _warnThreshold = Duration(minutes: 2);
  bool _warned = false;

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _update(response.headers);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final headers = err.response?.headers;
    if (headers != null) _update(headers);
    handler.next(err);
  }

  void _update(Headers headers) {
    final skew = ServerClock.updateFromHttpDate(headers.value('date'));
    if (skew == null || _warned || skew.abs() < _warnThreshold) return;
    _warned = true;
    MedLogger.warn(
      unit: 'SW-UNIT-NETWORK',
      swreq: 'SWREQ-CORE-007',
      message: 'Cihaz saati sunucudan farklı; tarih filtreleri sunucu saatine göre hesaplanıyor',
      context: {'skewSeconds': skew.inSeconds, 'deviceNow': DateTime.now().toIso8601String()},
    );
  }
}
