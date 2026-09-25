//
// [SWREQ-CLI-CABINEXEC-001]
// CabinOperationExecutionView'in notifier'dan beklediği her şey. Dolum,
// dolum listesi, sayım ve boşaltma notifier'ları bunu implement eder —
// view hiçbir somut notifier tipini bilmez.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/hardware/hardware.dart';
import '../../core/mixins/mixins.dart';

/// Kuyruk iskeletinin (yerleşim, overlay, footer, hata dialog'u) notifier'dan
/// beklediği her şey. Target tipinden bağımsız — alım ve iade da karşılar.
abstract interface class CabinQueueController implements Listenable {
  bool get isExecuting;
  List<DrawerJob> get jobs;
  int get currentIndex;
  List<DrawerQueueItem> toLocationItems(List<DrawerGroup> allGroups);

  MasterDrawerStage get drawerStage;
  bool get isSaving;
  bool get isStopping;
  Future<void> confirmCurrent();
  Future<void> requestStop();

  CabinOperationFailure? get failure;
  bool get isQueueError;
  Future<void> continueAfterError();
  Future<void> abortAfterError();
  void dismissQueueError();
}

/// Dolum/sayım/boşaltma/imha: iskelete ek olarak CabinOperationTarget girişleri.
abstract interface class CabinOperationExecutionController implements CabinQueueController, CabinEntryHandlers {
  @override
  List<CabinOperationDrawerJob> get jobs;
  CabinOperationDrawerJob? get currentJob;
  CabinOperationTarget? get currentTarget;
  bool get isPerCellMiadEnabled;
}
