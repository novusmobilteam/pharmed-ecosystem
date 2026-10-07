// pharmed-client/lib/core/providers/fingerprint_providers.dart
//
// [SWREQ-FP-030]
// Kiosk başına tek parmak izi okuyucu → global (autoDispose olmayan) provider.
//
// Varsayılan: takılı okuyucu otomatik seçilir (önce SecuGen, sonra Suprema BioMini).
// Geliştirmede:
//   --dart-define=FINGERPRINT_MOCK=true          okuyucusuz makinede mock
//   --dart-define=FINGERPRINT_VENDOR=secugen     yalnızca SecuGen
//   --dart-define=FINGERPRINT_VENDOR=suprema     yalnızca BioMini
// Mock flavor'da her zaman MockFingerprintScanner.

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import 'package:pharmed_client/core/flavor/app_flavor.dart';
import 'package:pharmed_client/core/hardware/fingerprint/fingerprint.dart';
import 'package:pharmed_client/core/providers/network_providers.dart';
import 'package:pharmed_client/features/auth/notifier/auth_notifier.dart';

final fingerprintScannerProvider = Provider<IFingerprintScanner>((ref) {
  final scanner = createFingerprintScanner();
  ref.onDispose(scanner.close);
  return scanner;
});

IFingerprintScanner createFingerprintScanner() {
  const forceMock = bool.fromEnvironment('FINGERPRINT_MOCK');
  if (FlavorConfig.instance.isMock || forceMock) return MockFingerprintScanner();

  IFingerprintScanner secuGen() => SecuGenFingerprintScanner(settings: SecuGenSettings.fromEnvironment());
  IFingerprintScanner bioMini() => BioMiniFingerprintScanner(settings: BioMiniSettings.fromEnvironment());

  const vendor = String.fromEnvironment('FINGERPRINT_VENDOR', defaultValue: 'auto');
  return switch (vendor) {
    'secugen' => secuGen(),
    'suprema' || 'biomini' => bioMini(),
    _ => AutoFingerprintScanner([secuGen(), bioMini()]),
  };
}

// ── Kayıt servisi: datasource → repository → use case ───────────────────────
// [SWREQ-FP-100] FingerprintApi.isAvailable = false iken (ve mock flavor'da) sahte
// repository kullanılır: akış uçtan uca çalışır, veri hiçbir yere gönderilmez.

final fingerprintRemoteDataSourceProvider = Provider<FingerprintRemoteDataSource>(
  (ref) => FingerprintRemoteDataSource(apiManager: ref.read(apiManagerProvider)),
);

final fingerprintRepositoryProvider = Provider<IFingerprintRepository>((ref) {
  if (FingerprintApi.isAvailable && !FlavorConfig.instance.isMock) {
    return FingerprintRepositoryImpl(dataSource: ref.read(fingerprintRemoteDataSourceProvider));
  }
  final base = Platform.environment['LOCALAPPDATA'] ?? Directory.systemTemp.path;
  return FakeFingerprintRepository(
    storeFilePath: p.join(base, 'PharMed', 'dev', 'fake_fingerprint_enrollments.json'),
    currentUserId: () => ref.read(authNotifierProvider.notifier).currentUser?.id,
  );
});

final enrollFingerprintsUseCaseProvider = Provider(
  (ref) => EnrollFingerprintsUseCase(ref.read(fingerprintRepositoryProvider)),
);

final getEnrolledFingersUseCaseProvider = Provider(
  (ref) => GetEnrolledFingersUseCase(ref.read(fingerprintRepositoryProvider)),
);

final deleteEnrolledFingerUseCaseProvider = Provider(
  (ref) => DeleteEnrolledFingerUseCase(ref.read(fingerprintRepositoryProvider)),
);
