// [SWREQ-DATA-AUTH-005] 401 → refresh token ile yenileme → tek tekrar deneme.

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_data/pharmed_data.dart';
// ignore: implementation_imports
import 'package:pharmed_data/src/network/token_interceptor.dart';

/// Yalnızca [validToken] ile gelen isteklere 200, diğerlerine 401 döner.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.validToken);

  String validToken;
  final List<String?> seenTokens = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final auth = options.headers['Authorization'] as String?;
    seenTokens.add(auth?.substring(7));
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final ok = auth == 'Bearer $validToken';
    return ResponseBody.fromString(
      ok ? '{"isSuccess":true,"data":"ok"}' : '{"isSuccess":false}',
      ok ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late TokenHolder holder;
  late _FakeAdapter adapter;
  late Dio dio;
  late int refreshCalls;
  late int unauthorizedCalls;

  setUp(() {
    holder = TokenHolder()..setToken('expired');
    adapter = _FakeAdapter('fresh');
    refreshCalls = 0;
    unauthorizedCalls = 0;
    holder.setOnUnauthorized(() => unauthorizedCalls++);
    dio = Dio(BaseOptions(baseUrl: 'http://test.local'))..httpClientAdapter = adapter;
    dio.interceptors.add(TokenInterceptor(tokenProvider: holder, retryDio: dio));
  });

  test('401 → refresh → istek yeni token ile tekrar denenir', () async {
    holder.setRefreshHandler(() async {
      refreshCalls++;
      holder.setToken('fresh');
      return true;
    });

    final response = await dio.get<dynamic>('/x');

    expect(response.statusCode, 200);
    expect(refreshCalls, 1);
    expect(unauthorizedCalls, 0);
    expect(adapter.seenTokens, ['expired', 'fresh']);
  });

  test('eşzamanlı 401\'ler tek refresh isteğinde birleşir', () async {
    final gate = Completer<void>();
    holder.setRefreshHandler(() async {
      refreshCalls++;
      await gate.future;
      holder.setToken('fresh');
      return true;
    });

    final futures = List.generate(3, (_) => dio.get<dynamic>('/x'));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    gate.complete();
    final responses = await Future.wait(futures);

    expect(responses.every((r) => r.statusCode == 200), isTrue);
    expect(refreshCalls, 1);
    expect(unauthorizedCalls, 0);
  });

  test('refresh başarısız → onUnauthorized, hata çağırana iletilir', () async {
    holder.setRefreshHandler(() async {
      refreshCalls++;
      return false;
    });

    await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
    expect(unauthorizedCalls, 1);
  });

  test('yenilenen token da 401 alırsa tekrar refresh yapılmaz, oturum kapanır', () async {
    holder.setRefreshHandler(() async {
      refreshCalls++;
      holder.setToken('still-invalid');
      return true;
    });

    await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
    expect(refreshCalls, 1);
    expect(unauthorizedCalls, 1);
    expect(adapter.seenTokens, ['expired', 'still-invalid']);
  });

  test('refresh handler yoksa eski davranış: 401 = oturum kapanır', () async {
    await expectLater(dio.get<dynamic>('/x'), throwsA(isA<DioException>()));
    expect(unauthorizedCalls, 1);
  });
}
