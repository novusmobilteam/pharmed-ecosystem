// lib/shared/widgets/cabin_widgets/overview_panel/_cabin_overview_panel_shared.dart
//
// MasterCabinOverviewPanel ve MobileCabinOverviewPanel tarafından
// paylaşılan ortak widget'lar.
//
// Sınıf: Class B

part of 'overview_panel.dart';

// ─────────────────────────────────────────────────────────────────
// Dış kabin container
// ─────────────────────────────────────────────────────────────────

class _CabinContainer extends StatelessWidget {
  const _CabinContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFD8E0EC),
        border: Border.all(color: MedColors.border2, width: 2),
        borderRadius: MedRadius.lgAll,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────

class _CabinPanelHeader extends StatelessWidget {
  const _CabinPanelHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC4CEDF), Color(0xFFB4C0D4)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF3), width: 2)),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────

class _CabinPanelFooter extends StatelessWidget {
  const _CabinPanelFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFB4C0D4), Color(0xFFA0AEC0)],
        ),
        border: Border(top: BorderSide(color: Color(0xFFE8ECF3), width: 1.5)),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Çekmece kolu
// ─────────────────────────────────────────────────────────────────

class _DrawerHandle extends StatelessWidget {
  const _DrawerHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA0B0C4), Color(0xFF9AADC0), Color(0xFFA0B0C4)],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF7A90A8)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Blink animasyonu
// ─────────────────────────────────────────────────────────────────

class _BlinkingWidget extends StatefulWidget {
  const _BlinkingWidget({required this.child});
  final Widget child;

  @override
  State<_BlinkingWidget> createState() => _BlinkingWidgetState();
}

class _BlinkingWidgetState extends State<_BlinkingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

// ─────────────────────────────────────────────────────────────────
// Çekmece kartı ortak dekorasyon
// ─────────────────────────────────────────────────────────────────

BoxDecoration _drawerCardDecoration(bool isSelected, double height) {
  return BoxDecoration(
    gradient: isSelected
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEEFF), Color(0xFFCEE0F7)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDF1F8), Color(0xFFDDE5F0)],
          ),
    border: Border.all(color: isSelected ? MedColors.blue : MedColors.border2, width: isSelected ? 2 : 1.5),
    borderRadius: BorderRadius.circular(7),
  );
}

// ─────────────────────────────────────────────────────────────────
// Durum noktası
// ─────────────────────────────────────────────────────────────────

enum _DrawerStockStatus { normal, low, critical, empty }

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.workingStatus, required this.stockStatus});

  final CabinWorkingStatus workingStatus;
  final _DrawerStockStatus stockStatus;

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor();
    final shouldBlink = workingStatus == CabinWorkingStatus.faulty || stockStatus == _DrawerStockStatus.critical;

    final dot = Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withAlpha(50), blurRadius: 4)],
      ),
    );

    if (!shouldBlink) return dot;
    return _BlinkingWidget(child: dot);
  }

  Color _resolveColor() {
    if (workingStatus == CabinWorkingStatus.faulty) return MedColors.red;
    if (workingStatus == CabinWorkingStatus.maintenance) return MedColors.amber;
    return switch (stockStatus) {
      _DrawerStockStatus.critical => MedColors.red,
      _DrawerStockStatus.low => MedColors.amber,
      _DrawerStockStatus.empty => MedColors.surface,
      _DrawerStockStatus.normal => MedColors.blue,
    };
  }
}

// ─────────────────────────────────────────────────────────────────
// Tip etiketi text stili — ortak
// ─────────────────────────────────────────────────────────────────

TextStyle get _typeLabelStyle =>
    const TextStyle(fontFamily: MedFonts.sans, fontSize: 9, letterSpacing: 0.8, color: MedColors.text3);

TextStyle get _subLabelStyle => const TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3);
