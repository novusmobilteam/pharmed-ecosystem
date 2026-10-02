// ignore_for_file: unintended_html_in_doc_comment

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_data/pharmed_data.dart';

import '../../features/auth/auth.dart';
import '../flavor/app_flavor.dart';
import '../hardware/hardware.dart';
import '../recording/recording.dart';
import 'providers.dart';

final recordingStorageConfigProvider = Provider<RecordingStorageConfig>((ref) => RecordingStorageConfig.defaults());

/// Upload worker her flavor'da açık. API yokken use case'ler sahte başarı
/// döner ve kayıtlar verifiedByStub işaretlenir — saklama kuralı onları
/// silmez, API açılınca yeniden yüklenirler. Gerekirse
/// --dart-define=RECORDING_UPLOAD_ENABLED=false ile tamamen kapatılabilir.
final recordingUploadConfigProvider = Provider<RecordingUploadConfig>((ref) => RecordingUploadConfig.fromEnvironment());

final recordingStorageProvider = Provider<RecordingStorage>(
  (ref) => RecordingStorage(rootPath: ref.watch(recordingStorageConfigProvider).rootPath),
);

final recordingOutboxProvider = Provider<HiveRecordingOutbox>((ref) {
  final outbox = HiveRecordingOutbox(storage: ref.watch(recordingStorageProvider));
  ref.onDispose(outbox.dispose);
  return outbox;
});

// ── Upload: datasource → repository → use case ──────────────────────────────
// Use case'ler RecordingUploadApi.isAvailable = false iken sunucuya gitmez.

final operationRecordingRemoteDataSourceProvider = Provider<OperationRecordingRemoteDataSource>(
  // NOT: apiManagerProvider adını doğrulayın. Büyük parçalar için ileride
  // ayrı (uzun timeout'lu) bir APIManager örneği önerilir — operasyonun API
  // çağrılarıyla aynı bağlantı havuzunu paylaşmasın.
  (ref) => OperationRecordingRemoteDataSource(apiManager: ref.read(apiManagerProvider)),
);

final recordingUploadRepositoryProvider = Provider<IRecordingUploadRepository>((ref) {
  if (FlavorConfig.instance.flavor == AppFlavor.mock) {
    final root = ref.watch(recordingStorageConfigProvider).rootPath;
    return MockRecordingUploadRepository(serverRootPath: p.join(p.dirname(root), 'mock_server'));
  }
  return OperationRecordingUploadRepositoryImpl(dataSource: ref.read(operationRecordingRemoteDataSourceProvider));
});

final submitRecordingMetadataUseCaseProvider = Provider(
  (ref) => SubmitRecordingMetadataUseCase(ref.read(recordingUploadRepositoryProvider)),
);
final getReceivedRecordingChunksUseCaseProvider = Provider(
  (ref) => GetReceivedRecordingChunksUseCase(ref.read(recordingUploadRepositoryProvider)),
);
final uploadRecordingChunkUseCaseProvider = Provider(
  (ref) => UploadRecordingChunkUseCase(ref.read(recordingUploadRepositoryProvider)),
);
final completeRecordingVideoUseCaseProvider = Provider(
  (ref) => CompleteRecordingVideoUseCase(ref.read(recordingUploadRepositoryProvider)),
);

// ── Kamera tanımları ────────────────────────────────────────────────────────

final cameraDeviceRepositoryProvider = Provider<ICameraDeviceRepository>((ref) => HiveCameraDeviceRepository());

final cameraSecretStoreProvider = Provider<ICameraSecretStore>((ref) => const SecureCameraSecretStore());

/// Kamera başına bir kaydedici. Tüm kameralar aynı staging klasörüne yazar;
/// dosyalar oturum kimliğiyle (<opId>--<cameraId>) ayrışır.
final cameraRecorderPoolProvider = Provider<CameraRecorderPool>((ref) {
  final stagingDir = Directory(p.join(ref.watch(recordingStorageConfigProvider).rootPath, recordingStagingFolder));
  final ffmpegPath = resolveFfmpegPath();
  return CameraRecorderPool(
    devices: ref.watch(cameraDeviceRepositoryProvider),
    secrets: ref.watch(cameraSecretStoreProvider),
    create: (config) => FfmpegOperationRecorder(config: config, ffmpegPath: ffmpegPath, outputDir: stagingDir),
  );
});

/// Kurulum ekranındaki deneme çekimi.
final cameraTesterProvider = Provider<CameraTester>((ref) => CameraTester(ffmpegPath: resolveFfmpegPath()));

// ── Koordinatör ─────────────────────────────────────────────────────────────

final operationRecordingCoordinatorProvider = Provider<OperationRecordingCoordinator>((ref) {
  final coordinator = OperationRecordingCoordinator(
    pool: ref.watch(cameraRecorderPoolProvider),
    outbox: ref.watch(recordingOutboxProvider),
    currentUser: () => switch (ref.read(authNotifierProvider)) {
      AuthLoggedIn(:final user) => (id: user.id, fullName: user.fullName),
      _ => (id: null, fullName: null),
    },
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

final recordingUploadWorkerProvider = Provider<RecordingUploadWorker>((ref) {
  final coordinator = ref.watch(operationRecordingCoordinatorProvider);
  final worker = RecordingUploadWorker(
    outbox: ref.watch(recordingOutboxProvider),
    storage: ref.watch(recordingStorageProvider),
    submitMetadata: ref.read(submitRecordingMetadataUseCaseProvider),
    getReceivedChunks: ref.read(getReceivedRecordingChunksUseCaseProvider),
    uploadChunk: ref.read(uploadRecordingChunkUseCaseProvider),
    completeVideo: ref.read(completeRecordingVideoUseCaseProvider),
    config: ref.watch(recordingUploadConfigProvider),
    isBusy: () => coordinator.hasActiveOperation,
  );
  ref.onDispose(worker.dispose);
  return worker;
});

final recordingRetentionSweeperProvider = Provider<RecordingRetentionSweeper>((ref) {
  final sweeper = RecordingRetentionSweeper(
    outbox: ref.watch(recordingOutboxProvider),
    storage: ref.watch(recordingStorageProvider),
    config: ref.watch(recordingStorageConfigProvider),
  );
  ref.onDispose(sweeper.dispose);
  return sweeper;
});

/// Kayıt hattını başlatır. Uygulama açılışında BİR KEZ, herhangi bir kabin
/// operasyonu başlamadan önce okunmalı.
///
/// Sıra önemli: kurtarma → temizlik → upload. Staging'deki yarım kayıtlar
/// arşive girmeden temizlik/upload başlamamalı.
final recordingPipelineBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(recordingOutboxProvider).recoverOnStartup();
  ref.read(recordingRetentionSweeperProvider).start();
  ref.read(recordingUploadWorkerProvider).start();
});
