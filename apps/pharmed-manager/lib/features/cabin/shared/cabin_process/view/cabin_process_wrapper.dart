import 'package:flutter/material.dart';

import '../../../../../../core/core.dart';

/// Bu widget, herhangi bir ekranı sarmalayarak ona
/// "Çekmece Açma → İşlem Yapma → Kapatma" yeteneği kazandırır.
///
/// Kullanım:
/// ```dart
/// CabinProcessWrapper(
///   onDrawerReady: (context, assignment) async {
///     final result = await showCabinInventoryView(...);
///     return result;
///   },
///   onProcessCompleted: (assignment) async { ... },
///   child: MyWidget(),
/// )
/// ```
class CabinProcessWrapper extends StatelessWidget {
  final Widget child;

  /// Çekmece açıldığında (readyForFilling) çalışacak fonksiyon.
  /// false veya null dönerse işlem iptal edilmiş sayılır.
  final Future<bool> Function(BuildContext context, CabinAssignment activeDrawer) onDrawerReady;

  /// İşlem tamamen bittiğinde (completed) çalışacak fonksiyon.
  final Function(CabinAssignment? assignment, bool isSuccess)? onProcessCompleted;

  const CabinProcessWrapper({super.key, required this.child, required this.onDrawerReady, this.onProcessCompleted});

  @override
  Widget build(BuildContext context) {
    return _CabinProcessListener(onDrawerReady: onDrawerReady, onProcessCompleted: onProcessCompleted, child: child);
  }
}

class _CabinProcessListener extends StatefulWidget {
  final Widget child;
  final Future<bool> Function(BuildContext context, CabinAssignment activeDrawer) onDrawerReady;
  final Function(CabinAssignment? assignment, bool isSuccess)? onProcessCompleted;

  const _CabinProcessListener({required this.child, required this.onDrawerReady, this.onProcessCompleted});

  @override
  State<_CabinProcessListener> createState() => _CabinProcessListenerState();
}

class _CabinProcessListenerState extends State<_CabinProcessListener> {
  /// Çoklu tetiklenmeyi önlemek için kilit.
  // bool _isProcessingReadyState = false;

  /// Dialog açık/kapalı durumu.
  /// Global flag yerine instance-level tutulur — farklı wrapper instance'ları
  /// birbirini etkilemez ve dispose sonrası flag sıfırlanır.
  // bool _isDialogOpen = false;

  /// context.read yerine initState'te alınan referans.
  /// Listener tetiklendiğinde context deaktive olmuş olabilir;
  /// bu referans her zaman güvenli erişim sağlar.
  // CabinStatusNotifier? _notifier;

  // bool _lastProcessResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // _notifier = context.read<CabinStatusNotifier>();
      // _notifier?.addListener(_handleDrawerStateChange);
    });
  }

  // Future<void> _handleDrawerStateChange() async {
  //   if (!mounted) return;

  //   final notifier = _notifier;
  //   if (notifier == null) return;

  //   final stage = notifier.stage;
  //   final selected = notifier.assignment;

  //   // 1. BAĞLANMA: Status dialogunu aç
  //   if (stage == DrawerStage.connecting) {
  //     _showStatusDialog();
  //   }

  //   // 2. HAZIR: Dolum/Sayım vb. ekranına geç
  //   if (stage == DrawerStage.readyForFilling && selected != null) {
  //     if (_isProcessingReadyState) return;
  //     _isProcessingReadyState = true;

  //     // Status dialogunu kapat
  //     _popIfPossible();

  //     final bool result = await widget.onDrawerReady(context, selected);
  //     _lastProcessResult = result;

  //     if (mounted) {
  //       // Çekmeceyi kapatma moduna al
  //       notifier.confirmFillingCompleted();
  //     }

  //     _isProcessingReadyState = false;
  //   }

  //   // 3. KAPATMA BEKLENİYOR: "Kapatın" uyarısını göster
  //   if (stage == DrawerStage.waitingForClose && mounted) {
  //     _showStatusDialog();
  //   }

  //   // 4. TAMAMLANDI: Temizle ve callback'i çağır
  //   if (stage == DrawerStage.completed && mounted) {
  //     final finishedAssignment = selected;
  //     final bool finalResult = _lastProcessResult;

  //     _popIfPossible();
  //     notifier.reset();

  //     await Future.delayed(const Duration(seconds: 1));

  //     if (mounted && finishedAssignment != null) {
  //       widget.onProcessCompleted?.call(finishedAssignment, finalResult);
  //     }
  //   }
  // }

  /// Status dialogunu açar.
  /// Zaten açıksa yeni bir tane açmaz.
  // void _showStatusDialog() {
  //   if (_isDialogOpen || !mounted) return;
  //   _isDialogOpen = true;

  //   showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (_) => ChangeNotifierProvider.value(value: _notifier!, child: const CabinStatusDialog()),
  //   ).whenComplete(() {
  //     // Dialog kapandığında (exception dahil) flag sıfırlanır
  //     _isDialogOpen = false;
  //   });
  // }

  // /// Mevcut dialog varsa kapatır.
  // void _popIfPossible() {
  //   if (mounted && Navigator.of(context).canPop()) {
  //     Navigator.of(context).pop();
  //   }
  // }

  // @override
  // void dispose() {
  //   _notifier?.removeListener(_handleDrawerStateChange);
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
