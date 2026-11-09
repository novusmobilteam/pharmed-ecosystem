// [SWREQ-NET-007] [IEC 62304 §5.5]
// Kiosk loglarının toplu gönderimi — "PharMed Cihaz Logları — Backend API
// Sözleşmesi", POST /api/DeviceLog/batch. Gövde client tarafında hazırlanır
// (DeviceLogMapper); burası yalnızca taşır ve yanıtı okur.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Ingest yanıtı. Ayrıntısı yoksa (ör. boş 200) hepsi kabul edilmiş sayılır.
class DeviceLogBatchResult {
  const DeviceLogBatchResult({required this.accepted, required this.duplicates, required this.rejected});

  final int accepted;
  final int duplicates;

  /// Backend'in reddettiği kayıtlar: id → sebep. Tekrar gönderilmez.
  final Map<String, String> rejected;

  factory DeviceLogBatchResult.fromJson(Object? json, {required int sent}) {
    if (json is! Map) return DeviceLogBatchResult(accepted: sent, duplicates: 0, rejected: const {});
    final rejected = <String, String>{};
    final list = json['rejected'];
    if (list is List) {
      for (final r in list) {
        if (r is Map && r['id'] != null) rejected['${r['id']}'] = '${r['reason'] ?? ''}';
      }
    }
    return DeviceLogBatchResult(
      accepted: (json['accepted'] as num?)?.toInt() ?? sent - rejected.length,
      duplicates: (json['duplicates'] as num?)?.toInt() ?? 0,
      rejected: rejected,
    );
  }
}

class DeviceLogRemoteDataSource {
  DeviceLogRemoteDataSource({required APIManager apiManager}) : _api = apiManager;

  final APIManager _api;

  static const path = '/DeviceLog/batch';

  /// [body]: `{ "device": {...}, "entries": [...] }`.
  /// [deviceKey] verilirse `X-Device-Key` header'ı ile gönderilir.
  Future<Result<DeviceLogBatchResult>> postBatch(Map<String, dynamic> body, {String? deviceKey}) async {
    final sent = (body['entries'] as List?)?.length ?? 0;
    final result = await _api.post<DeviceLogBatchResult>(
      path,
      data: body,
      headers: deviceKey == null || deviceKey.isEmpty ? null : {'X-Device-Key': deviceKey},
      parser: (json) => DeviceLogBatchResult.fromJson(json, sent: sent),
    );
    // Gövdesiz 2xx (ör. 204) da başarıdır — tümü kabul edilmiş sayılır.
    return result.when(
      ok: Result.ok,
      error: (e) => e is EmptyResponseException
          ? Result.ok(DeviceLogBatchResult(accepted: sent, duplicates: 0, rejected: const {}))
          : Result.error(e),
    );
  }
}
