// Master kabin işlem ekranlarının (dolum, sayım, alım, iade...) ortak KÖK
// iskeleti. init tetikleme, hata dinleme (queue error → confirm dialog,
// diğer hata → snackbar), boot/loading gate ve Selection↔Execution geçişini
// merkezileştirir.
//
// Bu widget HİÇBİR notifier/state tipini bilmiyor — her ekranın kendi root
// view'ı (ince bir sarmalayıcı olarak kalır) state'ini [RootPhase]'e çevirip
// buraya verir. Böylece mevcut, doğrulanmış state machine'lere dokunmadan
// davranış merkezileştirilmiş olur.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Çağıranın state'ini bu üçe indirgemesi beklenir. Value object — her
/// build'de yeniden hesaplanır, kalıcı değildir.
sealed class RootPhase {
  const RootPhase();
}

/// Veri henüz yok / notifier init edilmedi / ilk yükleme sürüyor.
/// Ekstra bir boot-gate varsa (ör. intake'teki ikinci provider) o da
/// hazır olana kadar bu fazda kalınır.
final class RootBooting extends RootPhase {
  const RootBooting();
}

/// Seçim fazı — [selectionBuilder] gösterilir.
final class RootSelection extends RootPhase {
  const RootSelection();
}

/// Yürütme fazı — [executionBuilder] gösterilir.
final class RootExecuting extends RootPhase {
  const RootExecuting({this.replacesEverything = false});

  /// true ise execution paneli AnimatedSwitcher'ın DIŞINDA, tam ekran
  /// render edilir — selection tarafından hiçbir iz (ör. hasta listesi)
  /// ekranda kalmaz. Intake gibi ekranlar için.
  final bool replacesEverything;
}

/// Kuyruk hatası dialog'u için gereken bilgiler — [onQueueError] callback'i
/// bunu üretir, scaffold dialog'u kendi açar.
class RootQueueErrorInfo {
  const RootQueueErrorInfo({
    required this.title,
    required this.message,
    required this.onContinue,
    required this.onAbort,
  });

  final String title;
  final String message;
  final VoidCallback onContinue;
  final VoidCallback onAbort;
}

class MasterCabinRootScaffold<TData, TState> extends StatefulWidget {
  const MasterCabinRootScaffold({
    super.key,
    required this.data,
    required this.cabinIdOf,
    required this.onInit,
    required this.state,
    required this.phaseOf,
    required this.selectionBuilder,
    required this.executionBuilder,
    this.extraBootGate,
    this.isFailure,
    this.isQueueFailure,
    this.onQueueError,
    this.onDismissError,
    this.errorMessageOf,
    this.emptyStateVariant = EmptyStateVariant.cabinData,
  });

  /// Ekrana geçirilen kaynak veri (ör. CabinVisualizerData?). null ise
  /// [RootBooting] fazında kalınır, init çağrılmaz.
  final TData? data;

  /// [data]'dan karşılaştırma anahtarı türetir (didUpdateWidget'ta yeniden
  /// init kararı için) — genelde `(d) => d.cabinId`.
  final Object? Function(TData data) cabinIdOf;

  /// data hazır olduğunda (ilk açılış VEYA cabinId değiştiğinde) bir kez
  /// çağrılır. Notifier'ın kendi init(data) metodunu çağırmalıdır.
  final Future<void> Function(TData data) onInit;

  /// İzlenen state (genelde `ref.watch(...)`'ın sonucu, çağıran taraf verir).
  final TState state;

  /// [state]'i [RootPhase]'e indirger — her ekranın kendi switch'i burada.
  final RootPhase Function(TState state) phaseOf;

  /// data hazır olsa bile true dönerse [RootBooting] fazında kalınır.
  /// İkinci bağımsız bir provider'ın (ör. patientSelection) senkron boot
  /// olması gerektiği ekranlarda kullanılır. Bu true iken de builder'lar
  /// Offstage ile mount edilir — aksi halde o ikinci provider'ın kendi
  /// init'i (genelde initState'te post-frame) hiç tetiklenmez.
  final bool Function()? extraBootGate;

  /// [state] bir hata mı taşıyor? (queue error da dahil, genel amaçlı)
  final bool Function(TState state)? isFailure;

  /// [state] bir KUYRUK hatası mı? (true ise confirm dialog, false ise snackbar)
  final bool Function(TState state)? isQueueFailure;

  /// Kuyruk hatası true iken dialog içeriğini üretir.
  final RootQueueErrorInfo Function(TState state)? onQueueError;

  /// Kuyruk hatası DEĞİLKEN (basit hata) çağrılır — snackbar sonrası
  /// notifier.dismissError() gibi bir çağrı yapılmalıdır.
  final void Function(TState state)? onDismissError;

  /// Basit hata durumunda snackbar'da gösterilecek mesaj.
  final String Function(TState state)? errorMessageOf;

  final EmptyStateVariant emptyStateVariant;

  /// Seçim fazında gösterilecek widget'ı üretir.
  final WidgetBuilder selectionBuilder;

  /// Yürütme fazında gösterilecek widget'ı üretir.
  final WidgetBuilder executionBuilder;

  @override
  State<MasterCabinRootScaffold<TData, TState>> createState() => _MasterCabinRootScaffoldState<TData, TState>();
}

class _MasterCabinRootScaffoldState<TData, TState> extends State<MasterCabinRootScaffold<TData, TState>> {
  // ignore: unused_field
  Object? _lastCabinKey;

  // Bir kez tam hazır olduktan sonra bir daha RootBooting'e dönmüyoruz —
  // ör. hasta değişiminde alt state kısa süreliğine "loading benzeri" bir
  // ara duruma düşse bile sol/sağ panel yerinde kalsın. Bu ayrımı ekranın
  // kendi selection panel'i (isItemsLoading vb.) zaten yönetiyor.
  bool _hasBooted = false;

  @override
  void initState() {
    super.initState();
    _maybeInit(widget.data);
  }

  @override
  void didUpdateWidget(covariant MasterCabinRootScaffold<TData, TState> old) {
    super.didUpdateWidget(old);
    final oldKey = old.data != null ? old.cabinIdOf(old.data as TData) : null;
    final newKey = widget.data != null ? widget.cabinIdOf(widget.data as TData) : null;
    if (newKey != oldKey) _maybeInit(widget.data);
  }

  void _maybeInit(TData? data) {
    if (data == null) return;
    _lastCabinKey = widget.cabinIdOf(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onInit(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    _handleErrorListening(context);

    if (widget.data == null) {
      return EmptyStateWidget(variant: widget.emptyStateVariant);
    }

    final phase = widget.phaseOf(widget.state);
    final extraNotReady = widget.extraBootGate?.call() ?? false;

    if (!_hasBooted) {
      if (phase is RootBooting || extraNotReady) {
        return Stack(
          children: [
            // Panelleri görünmez ama MOUNT edilmiş tut — aksi halde ikinci
            // bağımsız provider'ların initState'teki init() çağrıları hiç
            // tetiklenmez ve loading sonsuza kalır.
            Offstage(offstage: true, child: widget.selectionBuilder(context)),
            const Center(child: MedLoadingIndicator()),
          ],
        );
      }
      _hasBooted = true;
    }

    if (phase is RootExecuting && phase.replacesEverything) {
      return widget.executionBuilder(context);
    }

    final isExecuting = phase is RootExecuting;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isExecuting
          ? KeyedSubtree(key: const ValueKey('execution'), child: widget.executionBuilder(context))
          : KeyedSubtree(key: const ValueKey('selection'), child: widget.selectionBuilder(context)),
    );
  }

  void _handleErrorListening(BuildContext context) {
    final isFailure = widget.isFailure?.call(widget.state) ?? false;
    if (!isFailure) return;

    final isQueue = widget.isQueueFailure?.call(widget.state) ?? false;
    if (isQueue) {
      final info = widget.onQueueError?.call(widget.state);
      if (info == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showConfirmDialog(
          context: context,
          action: ConfirmAction.custom,
          customTitle: info.title,
          customMessage: info.message,
          iconData: PhosphorIcons.warning(),
          color: MedColors.amber,
          confirmButtonText: context.l10n.refill_error_continueNext,
          cancelButtonText: context.l10n.refill_error_endProcess,
          onConfirm: info.onContinue,
          onCancel: info.onAbort,
        );
      });
    } else {
      final message = widget.errorMessageOf?.call(widget.state) ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        MessageUtils.showErrorSnackbar(context, message);
        widget.onDismissError?.call(widget.state);
      });
    }
  }
}
