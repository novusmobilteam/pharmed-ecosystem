// [SWREQ-FP-100] [SWREQ-FP-101] [SWREQ-FP-103]
// Parmak izi kayıt/giriş use case kuralları.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmed_core/pharmed_core.dart';

FingerprintSample _sample({int quality = 80, int size = 400}) =>
    FingerprintSample(template: Uint8List(size)..fillRange(0, size, 7), quality: quality);

FingerEnrollment _finger(FingerPosition p, {int samples = 3, int quality = 80, int size = 400}) => FingerEnrollment(
  position: p,
  samples: [for (var i = 0; i < samples; i++) _sample(quality: quality, size: size)],
);

const _source = FingerprintSource(
  format: FingerprintTemplateFormat.iso19794_2,
  scannerVendor: 'mock',
  scannerModel: 'Mock',
  livenessActive: true,
);

FingerprintEnrollmentRequest _request(List<FingerEnrollment> fingers) =>
    FingerprintEnrollmentRequest(fingers: fingers, source: _source);

final _thumbs = [_finger(FingerPosition.rightThumb), _finger(FingerPosition.leftThumb)];
final _one = [_finger(FingerPosition.rightIndex)];

class _FakeFingerprintRepository implements IFingerprintRepository {
  int enrollCalls = 0;
  int deleteCalls = 0;

  @override
  Future<Result<void>> enroll(FingerprintEnrollmentRequest request) async {
    enrollCalls++;
    return const Result.ok(null);
  }

  @override
  Future<Result<List<EnrolledFinger>>> getEnrolledFingers() async => const Result.ok([]);

  @override
  Future<Result<void>> deleteFinger(FingerPosition position) async {
    deleteCalls++;
    return const Result.ok(null);
  }
}

class _FakeAuthRepository implements IAuthRepository {
  int fingerprintCalls = 0;

  @override
  Future<Result<AuthToken>> loginWithFingerprint(FingerprintLoginRequest request) async {
    fingerprintCalls++;
    return Result.error(const ServiceException(message: 'unused', statusCode: 401));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('EnrollFingerprintsUseCase.validate', () {
    test('zorunlu parmak yok: tek bir parmak geçerli', () {
      for (final p in FingerPosition.values) {
        expect(EnrollFingerprintsUseCase.validate(_request([_finger(p)])), isNull, reason: p.name);
      }
    });

    test('birden fazla parmak geçerli', () {
      expect(EnrollFingerprintsUseCase.validate(_request(_thumbs)), isNull);
    });

    test('boş istek reddedilir', () {
      expect(EnrollFingerprintsUseCase.validate(_request([])), isA<ValidationException>());
    });

    test('aynı parmak iki kez gönderilemez', () {
      final e = EnrollFingerprintsUseCase.validate(_request([..._thumbs, _finger(FingerPosition.rightThumb)]));
      expect(e, isA<ValidationException>());
    });

    test('parmak başına tam 3 okuma gerekir', () {
      for (final n in [2, 4]) {
        final e = EnrollFingerprintsUseCase.validate(
          _request([_finger(FingerPosition.rightThumb, samples: n), _finger(FingerPosition.leftThumb)]),
        );
        expect(e, isA<ValidationException>().having((x) => x.field, 'field', 'samples'), reason: '$n okuma');
      }
    });

    test('kayıt kalitesi eşiğin altındaysa reddedilir, eşikte kabul edilir', () {
      const min = FingerprintEnrollmentRules.minEnrollQuality;
      final low = EnrollFingerprintsUseCase.validate(
        _request([_finger(FingerPosition.rightThumb, quality: min - 1), _finger(FingerPosition.leftThumb)]),
      );
      expect(low, isA<ValidationException>().having((x) => x.field, 'field', 'quality'));

      final edge = EnrollFingerprintsUseCase.validate(
        _request([_finger(FingerPosition.rightThumb, quality: min), _finger(FingerPosition.leftThumb)]),
      );
      expect(edge, isNull);
    });

    test('boş ya da çok büyük şablon reddedilir', () {
      for (final size in [0, FingerprintEnrollmentRules.maxTemplateBytes + 1]) {
        final e = EnrollFingerprintsUseCase.validate(
          _request([_finger(FingerPosition.rightThumb, size: size), _finger(FingerPosition.leftThumb)]),
        );
        expect(e, isA<ValidationException>().having((x) => x.field, 'field', 'template'), reason: 'size $size');
      }
    });
  });

  group('EnrollFingerprintsUseCase', () {
    test('geçersiz istek repository\'ye gitmez', () async {
      final repo = _FakeFingerprintRepository();
      final result = await EnrollFingerprintsUseCase(repo)(_request([_finger(FingerPosition.rightIndex, samples: 2)]));
      expect(result.isError, isTrue);
      expect(repo.enrollCalls, 0);
    });

    test('geçerli istek repository\'ye gider', () async {
      final repo = _FakeFingerprintRepository();
      final result = await EnrollFingerprintsUseCase(repo)(_request(_one));
      expect(result.isSuccess, isTrue);
      expect(repo.enrollCalls, 1);
    });
  });

  group('DeleteEnrolledFingerUseCase', () {
    test('başparmaklar dahil her parmak silinebilir', () async {
      final repo = _FakeFingerprintRepository();
      for (final p in FingerPosition.values) {
        final result = await DeleteEnrolledFingerUseCase(repo)(p);
        expect(result.isSuccess, isTrue, reason: p.name);
      }
      expect(repo.deleteCalls, FingerPosition.values.length);
    });
  });

  group('LoginWithFingerprintUseCase', () {
    FingerprintLoginRequest login({int quality = 80, int size = 400}) =>
        FingerprintLoginRequest(sample: _sample(quality: quality, size: size), source: _source);

    test('giriş kalitesi eşiğin altındaysa lowQuality döner, servise gidilmez', () async {
      final repo = _FakeAuthRepository();
      final result = await LoginWithFingerprintUseCase(repo)(
        login(quality: FingerprintEnrollmentRules.minLoginQuality - 1),
      );
      result.when(
        ok: (_) {
          fail('başarılı olmamalıydı');
        },
        error: (e) {
          expect(
            e,
            isA<FingerprintException>().having((x) => x.reason, 'reason', FingerprintFailureReason.lowQuality),
          );
        },
      );
      expect(repo.fingerprintCalls, 0);
    });

    test('boş şablon reddedilir', () async {
      final repo = _FakeAuthRepository();
      final result = await LoginWithFingerprintUseCase(repo)(login(size: 0));
      expect(result.isError, isTrue);
      expect(repo.fingerprintCalls, 0);
    });

    test('servis hazır değilken 501 döner', () async {
      final repo = _FakeAuthRepository();
      final result = await LoginWithFingerprintUseCase(repo)(login());
      result.when(
        ok: (_) {
          fail('başarılı olmamalıydı');
        },
        error: (e) {
          expect(e, isA<ServiceException>().having((x) => x.statusCode, 'statusCode', 501));
        },
      );
      expect(repo.fingerprintCalls, 0);
    }, skip: FingerprintApi.isAvailable ? 'Servis hazır — bu test kaldırılmalı' : false);
  });

  group('FingerPosition', () {
    test('ISO kodları 1–10 ve geri dönüşüm', () {
      expect(FingerPosition.values.map((p) => p.isoCode), [for (var i = 1; i <= 10; i++) i]);
      for (final p in FingerPosition.values) {
        expect(FingerPosition.fromIsoCode(p.isoCode), p);
      }
    });
  });
}
