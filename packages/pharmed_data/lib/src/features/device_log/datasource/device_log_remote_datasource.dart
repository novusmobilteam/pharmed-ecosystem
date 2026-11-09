// [SWREQ-NET-007] [IEC 62304 §5.5]
// Kiosk loglarının toplu gönderimi — backend FrontendLog servisi,
// POST /api/FrontendLog/batch (Swagger: FrontendLogBatchModel). Gövde client
// tarafında hazırlanır (DeviceLogMapper); burası yalnızca taşır ve yanıtı okur.
//
// Kimlik mevcut Bearer token'dır; kullanıcı ve istasyonu backend token'dan
// alır. Yanıt zarfının `data` alanı accepted / duplicates / rejected taşır.
//
// Sınıf: Class B

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

/// Ingest yanıtı. Ayrıntısı yoksa (ör. boş 200) hepsi kabul edilmiş sayılır.
class DeviceLogBatchResult {
  const DeviceLogBatchResult({required this.accepted, required this.duplicates, required this.rejected});

  final int accepted;
  final int duplicates;

  /// Backend'in satır doğrulamasında reddettiği kayıtlar: id → sebep (id
  /// bilinmiyorsa sıra numarası). Tekrar gönderilmez.
  final Map<String, String> rejected;

  int get rejectedCount => rejected.length;

  factory DeviceLogBatchResult.fromJson(Object? json, {required int sent}) {
    // Zarf: { statusCode, isSuccess, data: { accepted, duplicates, rejected } }
    final root = json is Map ? json : const <String, dynamic>{};
    final data = root['data'] is Map ? root['data'] as Map : root;
    if (data.isEmpty) return DeviceLogBatchResult(accepted: sent, duplicates: 0, rejected: const {});

    final rejected = <String, String>{};
    final raw = data['rejected'];
    if (raw is List) {
      for (final (i, r) in raw.indexed) {
        if (r is Map) {
          final id = r['id'] ?? r['entryId'] ?? '#$i';
          final reason = r['reason'] ?? r['message'] ?? r['errors'] ?? '';
          rejected['$id'] = '$reason';
        } else {
          rejected['$r'] = '';
        }
      }
    } else if (raw is num) {
      for (var i = 0; i < raw.toInt(); i++) {
        rejected['#$i'] = '';
      }
    }

    int? count(Object? v) => v is num ? v.toInt() : (v is List ? v.length : null);
    final duplicates = count(data['duplicates']) ?? 0;
    return DeviceLogBatchResult(
      accepted: count(data['accepted']) ?? sent - duplicates - rejected.length,
      duplicates: duplicates,
      rejected: rejected,
    );
  }
}

class DeviceLogRemoteDataSource {
  DeviceLogRemoteDataSource({required APIManager apiManager}) : _api = apiManager;

  final APIManager _api;

  static const path = '/FrontendLog/batch';

  /// [body]: `{ "device": {...}, "entries": [...] }` (FrontendLogBatchModel).
  Future<Result<DeviceLogBatchResult>> postBatch(Map<String, dynamic> body) async {
    final sent = (body['entries'] as List?)?.length ?? 0;
    final result = await _api.post<Object?>(path, data: body, parser: (json) => json);
    return result.when<Result<DeviceLogBatchResult>>(
      ok: (json) {
        // Zarf başarısızlık bildiriyorsa (isSuccess: false) kuyruk korunur.
        if (json is Map && json['isSuccess'] == false) {
          return Result.error(
            ServiceException(
              message: '${json['message'] ?? json['error'] ?? 'Log gönderimi reddedildi'}',
              statusCode: (json['statusCode'] as num?)?.toInt() ?? 0,
            ),
          );
        }
        return Result.ok(DeviceLogBatchResult.fromJson(json, sent: sent));
      },
      // Gövdesiz 2xx (ör. 204) da başarıdır — tümü kabul edilmiş sayılır.
      error: (e) => e is EmptyResponseException
          ? Result.ok(DeviceLogBatchResult(accepted: sent, duplicates: 0, rejected: const {}))
          : Result.error(e),
    );
  }
}
