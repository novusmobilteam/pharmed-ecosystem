// [SWREQ-NET-007] Log gönderimi: gövde dönüşümü, kalıcı kuyruk, gönderici.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_client/core/logging/shipping/shipping.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

LogEntry _entry({
  LogLevel level = LogLevel.error,
  Map<String, dynamic>? context,
  Map<String, Object?>? session,
  List<String>? breadcrumbs,
}) => LogEntry(
  timestamp: DateTime.utc(2026, 11, 9, 11, 22, 1, 123),
  level: level,
  unit: 'SW-UNIT-NET',
  swreq: 'SWREQ-NET-006',
  message: '✕ POST /Prescription/detail/checkCollect (badResponse)',
  context: context,
  session: session,
  breadcrumbs: breadcrumbs,
);

void main() {
  group('DeviceLogMapper', () {
    test('ağ kaydının alanları ayrı alanlara çıkarılır', () {
      final json = DeviceLogMapper.toJson(
        _entry(
          context: {
            'req': 'r57',
            'method': 'POST',
            'path': '/Prescription/detail/checkCollect',
            'status': 400,
            'ms': 312,
            'errorType': 'ServiceException',
            'rule': 'INTAKE_CHECK_FAILED',
          },
          session: {'userId': 14, 'stationId': 3},
          breadcrumbs: ['14:21:58.402 → GET /x'],
        ),
        appRunId: 'run-1',
        id: 'id-1',
      )!;

      expect(json['id'], 'id-1');
      expect(json['appRunId'], 'run-1');
      expect(json['timestamp'], '2026-11-09T11:22:01.123Z');
      expect(json['level'], 'ERROR');
      expect(json['req'], 'r57');
      expect(json['rule'], 'INTAKE_CHECK_FAILED');
      expect(json['errorType'], 'ServiceException');
      expect(json['http'], {'method': 'POST', 'path': '/Prescription/detail/checkCollect', 'status': 400, 'ms': 312});
      expect(json.containsKey('relatedOperationId'), isFalse);
      expect(json['session'], {'userId': 14, 'stationId': 3});
      expect(json['breadcrumbs'], ['14:21:58.402 → GET /x']);
    });

    test('olmayan alanlar gövdeye yazılmaz', () {
      final json = DeviceLogMapper.toJson(_entry(level: LogLevel.info), appRunId: 'r')!;
      expect(json.containsKey('http'), isFalse);
      expect(json.containsKey('rule'), isFalse);
      expect(json.containsKey('context'), isFalse);
      expect(json['level'], 'INFO');
      expect(json['id'], matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    });

    test('işlem kimliği relatedOperationId olarak gönderilir', () {
      final json = DeviceLogMapper.toJson(_entry(level: LogLevel.info, context: {'operationId': 17814}), appRunId: 'r')!;
      expect(json['relatedOperationId'], 17814);
    });

    test('uzun mesaj şema sınırına kırpılır', () {
      final json = DeviceLogMapper.toJson(
        LogEntry(timestamp: DateTime.utc(2026), level: LogLevel.warn, unit: 'U', swreq: 'S', message: 'x' * 1500),
        appRunId: 'r',
      )!;
      expect((json['message'] as String).length, DeviceLogMapper.maxMessage);
    });

    test('DEBUG kayıtları gönderilmez', () {
      expect(DeviceLogMapper.toJson(_entry(level: LogLevel.debug), appRunId: 'r'), isNull);
    });
  });

  group('LogOutbox', () {
    late Directory dir;
    late LogOutbox outbox;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('log-outbox-test');
      outbox = LogOutbox(directory: dir, maxBytes: 1 << 20)..ensureCreated();
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('eklenenler gönderime ayrılır ve okunur', () {
      outbox.append({'id': 'a'});
      outbox.append({'id': 'b'});
      expect(outbox.pendingInCurrent, 2);

      outbox.seal();
      expect(outbox.pendingInCurrent, 0);
      final batches = outbox.batches();
      expect(batches, hasLength(1));
      expect(outbox.read(batches.single).map((e) => e['id']), ['a', 'b']);
    });

    test('kısmi gönderimde kalanlar dosyada kalır, tamamı gidince silinir', () {
      outbox.append({'id': 'a'});
      outbox.append({'id': 'b'});
      outbox.seal();
      final batch = outbox.batches().single;

      outbox.rewrite(batch, [
        {'id': 'b'},
      ]);
      expect(outbox.read(batch).map((e) => e['id']), ['b']);

      outbox.rewrite(batch, const []);
      expect(outbox.batches(), isEmpty);
    });

    test('bozuk satırlar atlanır', () {
      outbox.append({'id': 'a'});
      File('${dir.path}/current.ndjson').writeAsStringSync('{bozuk\n', mode: FileMode.append);
      outbox.append({'id': 'b'});
      outbox.seal();
      expect(outbox.read(outbox.batches().single).map((e) => e['id']), ['a', 'b']);
    });

    test('boyut sınırı aşılınca en eski batch düşürülür', () {
      final small = LogOutbox(directory: dir, maxBytes: 300);
      for (var i = 0; i < 3; i++) {
        small.append({'id': 'old-$i', 'pad': 'x' * 40});
      }
      small.seal();
      for (var i = 0; i < 3; i++) {
        small.append({'id': 'new-$i', 'pad': 'x' * 40});
      }
      final dropped = small.seal();
      expect(dropped, 3);
      final remaining = small.batches().expand(small.read).map((e) => e['id']);
      expect(remaining, ['new-0', 'new-1', 'new-2']);
    });
  });

  group('LogUploadWorker', () {
    late Directory dir;
    late LogShipping shipping;
    final sent = <List<dynamic>>[];

    setUp(() {
      sent.clear();
      dir = Directory.systemTemp.createTempSync('log-shipping-test');
      LogShipping.instance = null;
      shipping = LogShipping.init(
        config: const LogShippingConfig(enabled: true, batchSize: 2, flushInterval: Duration(hours: 1)),
        dataRoot: dir.path,
        flavor: 'test',
      )!;
    });

    tearDown(() => dir.deleteSync(recursive: true));

    Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 50));

    test('kayıtlar parçalara bölünüp gönderilir ve kuyruktan silinir', () async {
      for (var i = 0; i < 3; i++) {
        shipping.outbox.append({'id': 'e$i'});
      }
      final worker = LogUploadWorker(
        shipping: shipping,
        post: (body) async {
          sent.add(body['entries'] as List);
          return Result.ok(DeviceLogBatchResult(accepted: (body['entries'] as List).length, duplicates: 0, rejected: const {}));
        },
      );
      worker.kick();
      await settle();
      worker.dispose();

      expect(sent.map((c) => c.map((e) => e['id']).toList()), [
        ['e0', 'e1'],
        ['e2'],
      ]);
      expect(shipping.outbox.batches(), isEmpty);
    });

    test('oturum yokken gönderim yapılmaz', () async {
      shipping.outbox.append({'id': 'e0'});
      final worker = LogUploadWorker(
        shipping: shipping,
        canUpload: () => false,
        post: (body) async {
          sent.add(body['entries'] as List);
          return Result.ok(const DeviceLogBatchResult(accepted: 1, duplicates: 0, rejected: {}));
        },
      );
      worker.kick();
      await settle();
      worker.dispose();
      expect(sent, isEmpty);
    });

    test('hata olursa kayıtlar kuyrukta kalır', () async {
      shipping.outbox.append({'id': 'e0'});
      final worker = LogUploadWorker(
        shipping: shipping,
        post: (body) async =>
            const Result.error(ServiceException(message: 'yok', statusCode: 404)),
      );
      worker.kick();
      await settle();
      worker.dispose();

      final pending = shipping.outbox.batches().expand(shipping.outbox.read).map((e) => e['id']);
      expect(pending, ['e0']);
    });

    test('gönderilecek bir şey yoksa canlılık sinyali (boş gönderim) yapılır', () async {
      final worker = LogUploadWorker(
        shipping: shipping,
        post: (body) async {
          sent.add(body['entries'] as List);
          final device = body['device'] as Map;
          expect(device['deviceId'], shipping.device.deviceId);
          expect(device['application'], 'client');
          expect(device.containsKey('stationId'), isFalse);
          return Result.ok(const DeviceLogBatchResult(accepted: 0, duplicates: 0, rejected: {}));
        },
      );
      worker.kick();
      await settle();
      worker.dispose();
      expect(sent, [isEmpty]);
    });
  });

  test('deviceId açılışlar arasında aynı kalır', () {
    final dir = Directory.systemTemp.createTempSync('device-id-test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final a = DeviceIdentity.load(dataRoot: dir.path, appVersion: '1', flavor: 'test');
    final b = DeviceIdentity.load(dataRoot: dir.path, appVersion: '1', flavor: 'test');
    expect(a.deviceId, b.deviceId);
  });
}
