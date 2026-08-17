// Master kabin işlem ekranlarının ortak çekmece-durumu bekleme adımı.
// Yalnızca açılmayı değil; kapanma bekleme (WaitingForClose), durdurma
// bekleme ve hata (Failed) durumlarını da kapsar — MasterCabinExecutionScaffold
// tarafından MasterDrawerStage'in TÜM dallarında kullanılır.
//
// Stage→(title, subtitle) çözümlemesi MasterCabinExecutionScaffold içinde
// yapılır (masterDrawer_status_* ARB key'leriyle, tüm ekranlarda ortak) —
// bu widget yalnızca sunumdan sorumludur, hiçbir stage tipini bilmez.

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class MasterDrawerStatusView extends StatelessWidget {
  const MasterDrawerStatusView({super.key, required this.title, required this.subtitle, this.isError = false});

  final String title;
  final String subtitle;

  /// true ise (ör. MasterDrawerFailed) ikon kırmızı/amber olur ve alttaki
  /// "işleniyor" spinner'ı gösterilmez — bir hata sonsuza dek "yükleniyor"
  /// hissi vermemeli.
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final accentColor = isError ? MedColors.amber : MedColors.blue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isError) ...[_BlinkingSquare(size: 15, color: accentColor), const SizedBox(height: 8)],
        Text(title, style: MedTextStyles.titleLg()),
        const SizedBox(height: 6.0),
        Text(
          subtitle,
          style: MedTextStyles.bodyLg(color: MedColors.text3),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Sürekli tekrar eden opaklık animasyonuyla yanıp sönen kare —
/// MedLoadingIndicator yerine, "işlem devam ediyor" göstergesi.
class _BlinkingSquare extends StatefulWidget {
  const _BlinkingSquare({required this.size, this.color});

  final double size;
  final Color? color;

  @override
  State<_BlinkingSquare> createState() => _BlinkingSquareState();
}

class _BlinkingSquareState extends State<_BlinkingSquare> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.25,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color ?? MedColors.blue),
      ),
    );
  }
}
