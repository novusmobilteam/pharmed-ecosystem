// [SWREQ-CAM-010..013] [IEC 62304 §5.5]
// Kabin kuyruğunun yaşam döngüsüne kamera kaydını bağlayan katman.
// CabinDrawerQueueMixin'in hook'larını override eder; kuyruk mixin'i kameradan
// habersiz kalır. Feature notifier'a eklemek kaydı açmak için yeterlidir:
//
//   class XxxNotifier extends ChangeNotifier
//       with MasterDrawerExecutionMixin,
//            CabinDrawerQueueMixin<XxxJob, XxxTarget>,
//            CabinOperationRecordingMixin<XxxJob, XxxTarget> { ... }
//
// SIRA ÖNEMLİ: bu mixin CabinDrawerQueueMixin'den SONRA gelmeli ki
// onStageChanged / hook override'ları super zincirine doğru otursun.
//
// Politika: BEST-EFFORT — kamera başlatılamazsa kuyruk yine çalışır.
// Sınıf: Class B (kayıt zorunluluğu kararına kadar)
import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../hardware/hardware.dart';
import 'mixins.dart';

mixin CabinOperationRecordingMixin<TJob extends DrawerJob<TTarget>, TTarget extends DrawerJobTarget>
    on ChangeNotifier, MasterDrawerExecutionMixin, CabinDrawerQueueMixin<TJob, TTarget> {
  /// Provider'dan / testte fake ile enjekte edilir (drawerSession ile aynı desen).
  OperationRecordingCoordinator get recordingCoordinator;

  RecordedOperationType get recordedOperationType;

  /// Operasyonun dokunduğu kabinler — job'ların fiziksel çekmecelerinden
  /// türetilir (bir operasyon birden fazla kabine yayılabilir). Kuyruk
  /// kurulduktan sonra okunur. Özel bir kaynağı olan ekran override edebilir.
  Set<int> get recordingCabinIds => {for (final job in jobs) ?_cabinIdOf(job.representativeAssignment)};

  static int? _cabinIdOf(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.cabinId;

  OperationRecordingHandle? _recording;
  bool _beginInFlight = false;

  /// begin() sürerken kuyruk bitti / ekran kapandıysa, gelen handle hemen
  /// bu nedenle kapatılır.
  OperationEndReason? _endedDuringBegin;

  /// Aktif operasyonun kaydı (yoksa null). Zorunlu kayıt politikası gelince
  /// UI/feature `cameraStarted` değerine buradan bakabilir.
  OperationRecordingHandle? get activeRecording => _recording;

  @override
  Future<void> onQueueStarting() async {
    await super.onQueueStarting();

    // [SWREQ-CAM-010] İlk çekmece açılmadan önce, ~1,4 sn.
    _beginInFlight = true;
    _endedDuringBegin = null;
    try {
      final cabinIds = recordingCabinIds;
      if (cabinIds.isEmpty && jobs.isNotEmpty) {
        // Kabin çözülemezse hiçbir kamera eşleşmez ve kayıt SESSİZCE alınmaz —
        // bu yüzden görünür olmalı.
        MedLogger.warn(
          unit: 'SW-UNIT-CAM',
          swreq: 'SWREQ-CAM-010',
          message: 'Operasyonun kabinleri job\'lardan çözülemedi; kamera kaydı alınmayacak',
          context: {'type': recordedOperationType.name, 'jobs': jobs.length},
        );
      }

      final handle = await recordingCoordinator.begin(type: recordedOperationType, cabinIds: recordingCabinIds);
      final lateEnd = _endedDuringBegin;
      if (lateEnd != null) {
        unawaited(handle.end(lateEnd));
        return;
      }
      _recording = handle;
    } finally {
      _beginInFlight = false;
    }
  }

  @override
  void onQueueFinishing(QueueFinishReason reason) {
    super.onQueueFinishing(reason);
    _endRecording(switch (reason) {
      QueueFinishReason.completed => OperationEndReason.completed,
      QueueFinishReason.stoppedByUser => OperationEndReason.stoppedByUser,
      QueueFinishReason.abortedAfterError => OperationEndReason.abortedAfterError,
    });
  }

  @override
  void onStageChanged(MasterDrawerStage? previous, MasterDrawerStage current) {
    final job = currentJob;
    _recording?.markDrawerStage(
      previous,
      current,
      cabinDrawerId: job == null ? null : _physicalDrawerId(job.representativeAssignment),
    );
    super.onStageChanged(previous, current);
  }

  @override
  void dispose() {
    _endRecording(OperationEndReason.screenClosed);
    super.dispose();
  }

  void _endRecording(OperationEndReason reason) {
    if (_beginInFlight) {
      _endedDuringBegin ??= reason;
      return;
    }
    final handle = _recording;
    _recording = null;
    if (handle != null) unawaited(handle.end(reason));
  }

  /// Queue builder'lardaki fiziksel çekmece id'si ile aynı fallback zinciri.
  static int? _physicalDrawerId(MedicineAssignment a) => a.drawerUnit?.drawerSlot?.id ?? a.drawerUnit?.drawerSlotId;
}
