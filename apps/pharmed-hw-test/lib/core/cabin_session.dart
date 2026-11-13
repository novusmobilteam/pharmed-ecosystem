// Oturum boyunca kullanılan kabin tanımı. YALNIZCA bellekte tutulur:
// uygulama kapanınca (ya da çıkışta) silinir; client cache'ine ve servise
// hiçbir şey yazılmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cabin_model.dart';
import 'cabin_scanner.dart';
import 'client_cache_reader.dart';
import 'providers.dart';
import 'report.dart';

class CabinSessionState {
  const CabinSessionState({
    this.cacheChecked = false,
    this.cache,
    this.scan,
    this.active,
    this.differences = const [],
  });

  /// Client tanımı arandı mı.
  final bool cacheChecked;

  /// Bu bilgisayardaki client tanımı (bulunduysa).
  final ClientCacheResult? cache;

  /// Son tarama sonucu.
  final CabinScanResult? scan;

  /// Teknisyenin devam ettiği tanım (client tanımı ya da tarama).
  final CabinSnapshot? active;

  /// Client tanımı ile son tarama arasındaki farklar.
  final List<CabinDifference> differences;

  bool get hasCache => cache != null;
}

class CabinSessionNotifier extends Notifier<CabinSessionState> {
  @override
  CabinSessionState build() => const CabinSessionState();

  TestReport get _report => ref.read(testReportProvider);

  /// Client tanımını bir kez arar (salt okunur kopya üzerinden).
  Future<void> loadClientCache() async {
    if (state.cacheChecked) return;
    ClientCacheResult? result;
    String? error;
    try {
      result = await ClientCacheReader().read();
    } catch (e) {
      error = '$e';
    }
    state = CabinSessionState(cacheChecked: true, cache: result, scan: state.scan, active: state.active);
    if (result != null) {
      _report.add(
        'Client kabin tanımı bulundu: ${result.snapshot.summary}',
        StepResult.info,
        detail: [
          'Klasör: ${result.folder}',
          if (result.stationName != null || result.stationId != null)
            'İstasyon: ${result.stationName ?? '-'} (${result.stationId ?? '-'})',
          if (result.deviceMode != null) 'Client modu: ${result.deviceMode}',
          if (result.comPort != null) 'Client COM portu: ${result.comPort}',
          ...result.snapshot.describe(),
          for (final n in result.notes) 'Not: $n',
        ].join('\n'),
      );
    } else if (error != null) {
      _report.add('Client kabin tanımı okunamadı', StepResult.info, detail: error);
    }
  }

  /// Teknisyen client tanımıyla devam eder.
  void useClientDefinition() {
    final cache = state.cache;
    if (cache == null) return;
    state = CabinSessionState(
      cacheChecked: true,
      cache: cache,
      scan: state.scan,
      active: cache.snapshot,
      differences: state.differences,
    );
    _report.add('Client kabin tanımıyla devam edildi', StepResult.info);
  }

  /// Hattı ve kartları tarar. Sonuç aktif tanım olur; client tanımı varsa
  /// farklar çıkarılır. Client tanımı değişmez.
  Future<void> scan({required bool patientBased, void Function(String message)? onProgress}) async {
    final scanner = CabinScanner(
      serial: ref.read(serialServiceProvider),
      ops: ref.read(cabinOpsProvider),
      repository: ref.read(cabinRepositoryProvider),
    );
    final result = await scanner.scan(patientBased: patientBased, onProgress: onProgress);
    final cache = state.cache;
    final diffs = cache == null ? const <CabinDifference>[] : compareSnapshots(cache.snapshot, result.snapshot);
    state = CabinSessionState(
      cacheChecked: state.cacheChecked,
      cache: cache,
      scan: result,
      active: result.snapshot,
      differences: diffs,
    );

    final snapshot = result.snapshot;
    final problems = snapshot.cabins.where((c) => c.hasProblems).length;
    _report.add(
      'Kabin taraması: ${snapshot.cabins.isEmpty ? 'kabin bulunamadı' : snapshot.summary}',
      snapshot.cabins.isEmpty || problems > 0 ? StepResult.fail : StepResult.ok,
      detail: [...snapshot.describe(), '', ...result.log].join('\n'),
    );
    if (cache != null) {
      _report.add(
        diffs.isEmpty ? 'Tarama client tanımıyla uyumlu' : 'Tarama client tanımından farklı (${diffs.length} fark)',
        diffs.isEmpty ? StepResult.ok : StepResult.fail,
        detail: diffs.isEmpty ? null : diffs.join('\n'),
      );
    }
  }
}

final cabinSessionProvider = NotifierProvider<CabinSessionNotifier, CabinSessionState>(CabinSessionNotifier.new);
