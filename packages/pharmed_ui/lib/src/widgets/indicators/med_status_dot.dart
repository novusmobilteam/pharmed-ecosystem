import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────
// MedStatusDot
// [SWREQ-UI-ATOM-002]
// Kullanım: Widget başlığındaki küçük yuvarlak durum göstergesi.
// isPulsing: true → canlı bağlantı/aktif durum için nabız animasyonu.
// Sınıf  : Class A
// ─────────────────────────────────────────────────────────────────

/// Küçük dairevi durum noktası — widget başlıklarında durum rengi için.
///
/// ```dart
/// MedStatusDot(color: MedColors.green)
/// MedStatusDot(color: MedColors.green, isPulsing: true)  // canlı gösterge
/// ```
/// Backward compat alias.
typedef StatusDot = MedStatusDot;

class MedStatusDot extends StatefulWidget {
  const MedStatusDot({super.key, required this.color, this.size = 8, this.isPulsing = false});

  final Color color;
  final double size;

  /// true → hafif nabız animasyonu (canlı veri / aktif bağlantı için)
  final bool isPulsing;

  @override
  State<MedStatusDot> createState() => _MedStatusDotState();
}

class _MedStatusDotState extends State<MedStatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isPulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MedStatusDot old) {
    super.didUpdateWidget(old);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );

    if (!widget.isPulsing) return dot;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: dot,
    );
  }
}
