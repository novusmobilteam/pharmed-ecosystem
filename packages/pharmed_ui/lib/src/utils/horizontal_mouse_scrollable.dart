// Yatay scroll'lu widget'ları (MedFilterChipGroup, servis chip barı vb.)
// masaüstünde mouse tekerleği + klavye ok tuşlarıyla kullanılabilir hâle
// getiren sarmalayıcı.
//
// Flutter'ın varsayılan davranışı:
//   - Touch drag: ÇALIŞIR (ListView.horizontal zaten destekliyor)
//   - Mouse tekerleği: ÇALIŞMAZ — PointerScrollEvent dikey delta üretir,
//     yatay ScrollController'a otomatik yansımaz.
//   - Mouse click+drag: varsayılan ScrollBehavior'da mouse `dragDevices`
//     listesinde YOK (yanlışlıkla buton tıklarken sürüklemeyi önlemek için).
//   - Klavye ok tuşları: ScrollView'lar kendiliğinden dinlemez.
//
// Kullanım — MedFilterChipGroup'un İÇİNDEKİ ListView/SingleChildScrollView'ı
// bu widget'la sarmalayın (controller'ı paylaşmanız yeterli):
//
//   final _controller = ScrollController();
//   ...
//   HorizontalMouseScrollable(
//     controller: _controller,
//     child: ListView.separated(
//       controller: _controller,
//       scrollDirection: Axis.horizontal,
//       ...
//     ),
//   )


import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HorizontalMouseScrollable extends StatefulWidget {
  const HorizontalMouseScrollable({
    super.key,
    required this.controller,
    required this.child,
    this.scrollAmount = 60,
    this.wheelSensitivity = 1.0,
    this.focusNode,
  });

  /// Sarmalanan yatay ScrollView ile AYNI controller.
  final ScrollController controller;

  final Widget child;

  /// Ok tuşuna basınca kaydırılacak piksel.
  final double scrollAmount;

  /// Mouse tekerleği delta çarpanı (trackpad'lerde genelde küçük delta gelir,
  /// klasik mouse tekerleğinde büyük — 1.0 çoğu durumda iyi bir varsayılan).
  final double wheelSensitivity;

  /// Dıştan bir FocusNode verilirse (ör. chip tıklamasında requestFocus
  /// çağırabilmek için) onu kullanır; verilmezse kendi node'unu oluşturur.
  final FocusNode? focusNode;

  @override
  State<HorizontalMouseScrollable> createState() => _HorizontalMouseScrollableState();
}

class _HorizontalMouseScrollableState extends State<HorizontalMouseScrollable> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode(skipTraversal: true));

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;

    // Kaydı burada yapıyoruz: resolver bu event için TEK bir dinleyicinin
    // kazanmasını sağlar — böylece aynı tekerlek hareketi sayfanın dikey
    // scroll'una da bulaşmaz (event "tüketilmiş" olur).
    GestureBinding.instance.pointerSignalResolver.register(event, (PointerSignalEvent e) {
      final scrollEvent = e as PointerScrollEvent;

      // Zaten yatay bir delta varsa (bazı trackpad'ler shift+wheel veya
      // native yatay swipe ile dx üretir) onu, yoksa dikey delta'yı kullan.
      final delta = scrollEvent.scrollDelta.dx.abs() > scrollEvent.scrollDelta.dy.abs()
          ? scrollEvent.scrollDelta.dx
          : scrollEvent.scrollDelta.dy;

      final target = (widget.controller.offset + delta * widget.wheelSensitivity).clamp(
        widget.controller.position.minScrollExtent,
        widget.controller.position.maxScrollExtent,
      );

      widget.controller.jumpTo(target);
    });
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    double? delta;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) delta = widget.scrollAmount;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) delta = -widget.scrollAmount;
    if (delta == null) return KeyEventResult.ignored;

    final target = (widget.controller.offset + delta).clamp(
      widget.controller.position.minScrollExtent,
      widget.controller.position.maxScrollExtent,
    );
    widget.controller.animateTo(target, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    return KeyEventResult.handled;
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Listener(
        onPointerSignal: _handlePointerSignal,
        child: ScrollConfiguration(
          // Mouse ile click+drag kaydırmayı da açıyoruz (varsayılanda kapalı).
          behavior: ScrollConfiguration.of(
            context,
          ).copyWith(dragDevices: {...ScrollConfiguration.of(context).dragDevices, PointerDeviceKind.mouse}),
          child: widget.child,
        ),
      ),
    );
  }
}
