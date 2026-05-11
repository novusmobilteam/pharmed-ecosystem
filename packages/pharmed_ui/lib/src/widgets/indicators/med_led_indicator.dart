import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedLedIndicator
// [SWREQ-UI-ATOM-006] [HAZ-003]
// Kullanım: Kabin görselindeki fiziksel LED göstergesi.
//   on      → yeşil, sabit
//   warning → amber, yanıp söner (2s döngü)
//   off     → kırmızı, sabit
// Sınıf: Class B — kabin fiziksel durumunu temsil eder
// ─────────────────────────────────────────────────────────────────

/// LED durum numaralandırması.
enum LedStatus { on, warning, off }

/// Animasyonlu LED göstergesi — kabin ve cihaz durumu için.
///
/// [LedStatus.warning] durumunda 2 saniyelik döngüyle yanıp söner.
///
/// ```dart
/// MedLedIndicator(status: LedStatus.on, size: 7)
/// ```
/// Backward compat alias.
typedef LedIndicator = MedLedIndicator;

class MedLedIndicator extends StatefulWidget {
  const MedLedIndicator({super.key, required this.status, this.size = 7});

  final LedStatus status;
  final double size;

  @override
  State<MedLedIndicator> createState() => _MedLedIndicatorState();
}

class _MedLedIndicatorState extends State<MedLedIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 50),
    ]).animate(_controller);

    if (widget.status == LedStatus.warning) _controller.repeat();
  }

  @override
  void didUpdateWidget(MedLedIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == LedStatus.warning) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(widget.status);
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.53), blurRadius: 5),
        ],
      ),
    );

    if (widget.status == LedStatus.warning) {
      return AnimatedBuilder(
        animation: _opacity,
        builder: (_, __) => Opacity(opacity: _opacity.value, child: dot),
      );
    }
    return dot;
  }

  Color _resolveColor(LedStatus status) => switch (status) {
        LedStatus.on => MedColors.ledGreen,
        LedStatus.warning => MedColors.ledAmber,
        LedStatus.off => MedColors.ledRed,
      };
}
