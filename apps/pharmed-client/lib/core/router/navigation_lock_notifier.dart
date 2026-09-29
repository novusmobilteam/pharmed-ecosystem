// [SWREQ-UI-NAV-001] [HAZ-004] [HAZ-006]
// Kabin işlemi (dolum, sayım, alım, iade, imha, boşaltma...) sürerken ana
// navigasyon barını kilitler. Yarım kalan bir çekmece kuyruğunun başka bir
// menüye geçilerek terk edilmesini engeller.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedLogger

/// Sahip (owner) bazlı kilit. Her ekran kilidi kendi token'ıyla alır ve
/// bırakır; böylece bir ekranın dispose'u başka bir ekranın kilidini
/// yanlışlıkla kaldırmaz.
class NavigationLockNotifier extends ChangeNotifier {
  final Set<Object> _owners = {};
  bool _disposed = false;

  bool get isLocked => _owners.isNotEmpty;

  void acquire(Object owner) {
    final wasLocked = isLocked;
    if (!_owners.add(owner)) return;

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-NAV-001',
      message: 'Navigasyon kilitlendi',
      context: {'owner': owner.runtimeType.toString(), 'count': _owners.length},
    );
    if (!wasLocked) _scheduleNotify();
  }

  void release(Object owner) {
    if (!_owners.remove(owner)) return;

    MedLogger.info(
      unit: 'SW-UNIT-UI',
      swreq: 'SWREQ-UI-NAV-001',
      message: 'Navigasyon kilidi kaldırıldı',
      context: {'owner': owner.runtimeType.toString(), 'count': _owners.length},
    );
    if (!isLocked) _scheduleNotify();
  }

  /// acquire/release çoğunlukla initState/dispose içinden çağrılır. O anda
  /// senkron notify, nav bar'ı build/finalize ortasında rebuild etmeye
  /// çalışıp assert'e düşer; bu yüzden frame sonrasına ertelenir.
  void _scheduleNotify() {
    scheduleMicrotask(() {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

final navigationLockProvider = ChangeNotifierProvider<NavigationLockNotifier>((ref) => NavigationLockNotifier());

/// Ağaçta bulunduğu sürece navigasyonu kilitli tutar.
/// `MasterCabinExecutionScaffold` gibi işlem kök widget'larını sarmak için.
class NavigationLockScope extends ConsumerStatefulWidget {
  const NavigationLockScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NavigationLockScope> createState() => _NavigationLockScopeState();
}

class _NavigationLockScopeState extends ConsumerState<NavigationLockScope> {
  // dispose'da ref kullanılamadığı için notifier referansı saklanır.
  late final NavigationLockNotifier _lock;

  @override
  void initState() {
    super.initState();
    _lock = ref.read(navigationLockProvider)..acquire(this);
  }

  @override
  void dispose() {
    _lock.release(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
