import 'package:pharmed_core/pharmed_core.dart';

import 'cabin_drawer_queue_mixin.dart';

/// Giriş alanlarının ekrandan beklediği işlemler — body widget'ı yalnızca
/// bu arayüze bağlıdır, somut notifier'ı bilmez (fake ile test edilebilir).
abstract interface class CabinEntryHandlers {
  void onCubicCountChanged(double value);
  void onCubicSecondaryChanged(double value);
  void onCubicMiadChanged(DateTime? date);
  void onStepCountChanged(int stepIndex, double value);
  void onStepSecondaryChanged(int stepIndex, double value);
  void onStepMiadChanged(int stepIndex, DateTime? date);
  void onSingleMiadChanged(DateTime? date);
}

/// Dolum / sayım / dolum listesi notifier'larının ortak giriş güncellemeleri.
/// Her zaman AKTİF target'ı günceller — view'in target indeksi taşımasına gerek yok.
mixin CabinOperationEntryMixin on CabinDrawerQueueMixin<CabinOperationDrawerJob, CabinOperationTarget>
    implements CabinEntryHandlers {
  @override
  void onCubicCountChanged(double v) => _updateCurrent((t) => t.withCubicCount(v));
  @override
  void onCubicSecondaryChanged(double v) => _updateCurrent((t) => t.withCubicSecondary(v));
  @override
  void onCubicMiadChanged(DateTime? d) => _updateCurrent((t) => t.withCubicMiad(d));
  @override
  void onStepCountChanged(int i, double v) => _updateCurrent((t) => t.withStepCount(i, v));
  @override
  void onStepSecondaryChanged(int i, double v) => _updateCurrent((t) => t.withStepSecondary(i, v));
  @override
  void onStepMiadChanged(int i, DateTime? d) => _updateCurrent((t) => t.withStepMiad(i, d));
  @override
  void onSingleMiadChanged(DateTime? d) => _updateCurrent((t) => t.withSharedMiad(d));

  void _updateCurrent(CabinOperationTarget Function(CabinOperationTarget) update) {
    final job = currentJob;
    final index = currentTargetIndex;
    if (job == null || index < 0 || index >= job.targets.length) return;

    final next = List<CabinOperationTarget>.from(job.targets);
    next[index] = update(next[index]);
    replaceCurrentJobTargets(next);
  }
}
