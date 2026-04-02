import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedOnScreenKeyboard + MedKeyboardController
// [SWREQ-UI-ORG-KB-001]
// Dokunmatik HMI için özel ekran klavyesi.
// İki mod: alpha (Türkçe QWERTY) ve numpad.
// Klavye, ekranın alt kısmında sabit olarak gösterilir.
// Kullanım:
//   - MedKeyboardController.of(context) ile kontrolcüye ulaşılır.
//   - MedKeyboardScope ekranı sarar, MedOnScreenKeyboard scaffold'a eklenir.
// Sınıf : Class A (görsel girdi yardımcısı)
// ─────────────────────────────────────────────────────────────────

// ── Klavye modu ───────────────────────────────────────────────────
enum MedKeyboardMode { alpha, num }

// ── Controller ───────────────────────────────────────────────────
class MedKeyboardController extends ChangeNotifier {
  TextEditingController? _activeController;
  FocusNode? _activeFocusNode;
  String _targetLabel = '';
  bool _visible = false;
  MedKeyboardMode _mode = MedKeyboardMode.alpha;
  bool _shift = false;

  bool get visible => _visible;
  MedKeyboardMode get mode => _mode;
  bool get shift => _shift;
  String get targetLabel => _targetLabel;

  void show({
    required TextEditingController controller,
    required FocusNode focusNode,
    MedKeyboardMode mode = MedKeyboardMode.alpha,
    String label = '',
  }) {
    _activeController = controller;
    _activeFocusNode = focusNode;
    _mode = mode;
    _targetLabel = label;
    _visible = true;
    _shift = false;
    notifyListeners();
  }

  void hide() {
    _visible = false;
    _activeController = null;
    _activeFocusNode?.unfocus();
    _activeFocusNode = null;
    notifyListeners();
  }

  void switchMode(MedKeyboardMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggleShift() {
    _shift = !_shift;
    notifyListeners();
  }

  void pressChar(String char) {
    if (_activeController == null) return;
    final ctrl = _activeController!;
    final sel = ctrl.selection;
    final text = ctrl.text;

    if (char == 'backspace') {
      if (sel.isCollapsed && sel.start > 0) {
        final newText = text.substring(0, sel.start - 1) + text.substring(sel.start);
        ctrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: sel.start - 1),
        );
      } else if (!sel.isCollapsed) {
        final newText = text.substring(0, sel.start) + text.substring(sel.end);
        ctrl.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: sel.start),
        );
      }
    } else if (char == 'enter') {
      hide();
    } else {
      final c = _shift ? char.toUpperCase() : char;
      final newText = text.substring(0, sel.start) + c + text.substring(sel.end);
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: sel.start + c.length),
      );
      if (_shift) {
        _shift = false;
        notifyListeners();
      }
    }
  }
}

// ── InheritedWidget wrapper ───────────────────────────────────────
class MedKeyboardScope extends InheritedNotifier<MedKeyboardController> {
  const MedKeyboardScope({super.key, required MedKeyboardController controller, required super.child})
    : super(notifier: controller);

  static MedKeyboardController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MedKeyboardScope>()?.notifier;
  }

  static MedKeyboardController of(BuildContext context) {
    final ctrl = maybeOf(context);
    assert(ctrl != null, 'MedKeyboardScope bulunamadı');
    return ctrl!;
  }
}

// ── Ana klavye widget'ı ───────────────────────────────────────────
class MedOnScreenKeyboard extends StatelessWidget {
  const MedOnScreenKeyboard({super.key, required this.controller});

  final MedKeyboardController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        return AnimatedSlide(
          offset: controller.visible ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 250),
          curve: controller.visible ? const Cubic(0.4, 0, 0.2, 1) : Curves.easeIn,
          child: AnimatedOpacity(
            opacity: controller.visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: _KeyboardBody(controller: controller),
          ),
        );
      },
    );
  }
}

class _KeyboardBody extends StatelessWidget {
  const _KeyboardBody({required this.controller});
  final MedKeyboardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEEF1F6), Color(0xFFE4E8F0)],
        ),
        border: const Border(top: BorderSide(color: MedColors.border, width: 2)),
        boxShadow: const [BoxShadow(color: Color(0x1F1E3259), blurRadius: 32, offset: Offset(0, -8))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _KbBar(controller: controller),
              const SizedBox(height: 6),
              if (controller.mode == MedKeyboardMode.alpha)
                _AlphaLayout(controller: controller)
              else
                _NumpadLayout(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Üst bar (mod sekmesi + hedef + kapat) ─────────────────────────
class _KbBar extends StatelessWidget {
  const _KbBar({required this.controller});
  final MedKeyboardController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Mod sekmeleri
        Row(
          children: [
            _KbModeTab(
              label: 'ABC',
              isActive: controller.mode == MedKeyboardMode.alpha,
              onTap: () => controller.switchMode(MedKeyboardMode.alpha),
            ),
            const SizedBox(width: 4),
            _KbModeTab(
              label: '123',
              isActive: controller.mode == MedKeyboardMode.num,
              onTap: () => controller.switchMode(MedKeyboardMode.num),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Hedef etiket
        if (controller.targetLabel.isNotEmpty)
          Expanded(
            child: Text(
              controller.targetLabel,
              style: const TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 10,
                color: MedColors.text3,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          const Spacer(),
        // Kapat butonu
        GestureDetector(
          onTap: controller.hide,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: MedColors.surface3,
              border: Border.all(color: MedColors.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 12, color: MedColors.text2),
                SizedBox(width: 5),
                Text(
                  'Kapat',
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: MedColors.text2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _KbModeTab extends StatelessWidget {
  const _KbModeTab({required this.label, required this.isActive, required this.onTap});
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? MedColors.blue : Colors.transparent,
          border: Border.all(color: isActive ? MedColors.blue : MedColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: MedFonts.sans,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : MedColors.text3,
          ),
        ),
      ),
    );
  }
}

// ── Alpha klavye düzeni (Türkçe QWERTY) ──────────────────────────
class _AlphaLayout extends StatelessWidget {
  const _AlphaLayout({required this.controller});
  final MedKeyboardController controller;

  static const _rows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'ı', 'o', 'p', 'ğ', 'ü'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ş', 'i'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm', 'ç', 'ö'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Satır 1
        _KbRow(
          children: [
            ..._rows[0].map((c) => _Key(char: c, controller: controller)),
            _SpecialKey(label: '⌫', flex: 2, onTap: () => controller.pressChar('backspace')),
          ],
        ),
        const SizedBox(height: 5),
        // Satır 2
        _KbRow(
          children: [
            ..._rows[1].map((c) => _Key(char: c, controller: controller)),
            _ActionKey(label: '↵ Tamam', flex: 2, onTap: () => controller.pressChar('enter')),
          ],
        ),
        const SizedBox(height: 5),
        // Satır 3
        _KbRow(
          children: [
            _ShiftKey(controller: controller),
            ..._rows[2].map((c) => _Key(char: c, controller: controller)),
            _SpecialKey(label: '⇧', onTap: controller.toggleShift),
          ],
        ),
        const SizedBox(height: 5),
        // Alt satır
        _KbRow(
          children: [
            _SpecialKey(label: '— Çizgi', flex: 2, onTap: () => controller.pressChar('-')),
            _SpecialKey(label: '. Nokta', flex: 2, onTap: () => controller.pressChar('.')),
            _SpaceKey(controller: controller),
            _SpecialKey(label: '0', onTap: () => controller.pressChar('0')),
            _SpecialKey(label: '1', onTap: () => controller.pressChar('1')),
            _SpecialKey(label: '2', onTap: () => controller.pressChar('2')),
            _SpecialKey(label: '3', onTap: () => controller.pressChar('3')),
          ],
        ),
      ],
    );
  }
}

// ── Numpad düzeni ─────────────────────────────────────────────────
class _NumpadLayout extends StatelessWidget {
  const _NumpadLayout({required this.controller});
  final MedKeyboardController controller;

  static const _keys = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '.', '0'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < 4; row++)
            Padding(
              padding: EdgeInsets.only(bottom: row < 3 ? 6 : 0),
              child: Row(
                children: [
                  if (row < 3) ...[
                    for (var col = 0; col < 3; col++) ...[
                      _NumKey(label: _keys[row * 3 + col], onTap: () => controller.pressChar(_keys[row * 3 + col])),
                      if (col < 2) const SizedBox(width: 6),
                    ],
                  ] else ...[
                    _NumKey(label: '.', onTap: () => controller.pressChar('.')),
                    const SizedBox(width: 6),
                    _NumKey(label: '0', onTap: () => controller.pressChar('0')),
                    const SizedBox(width: 6),
                    _NumActionKey(label: '⌫', onTap: () => controller.pressChar('backspace')),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: _NumActionKey(label: '↵', onTap: () => controller.pressChar('enter'), wide: true),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tuş widget'ları ───────────────────────────────────────────────
class _KbRow extends StatelessWidget {
  const _KbRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Row(children: children.expand((c) => [c, const SizedBox(width: 5)]).toList()..removeLast());
  }
}

class _Key extends StatefulWidget {
  const _Key({required this.char, required this.controller});
  final String char;
  final MedKeyboardController controller;

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.controller.shift ? widget.char.toUpperCase() : widget.char;

    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.controller.pressChar(widget.char);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 54,
          decoration: BoxDecoration(
            color: _pressed ? MedColors.blueLight : MedColors.surface,
            border: Border.all(color: _pressed ? MedColors.blue : MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(9),
            boxShadow: _pressed
                ? [const BoxShadow(color: MedColors.blue, blurRadius: 0, offset: Offset(0, 1))]
                : const [
                    BoxShadow(color: MedColors.border, blurRadius: 0, offset: Offset(0, 3)),
                    BoxShadow(color: Color(0x141E3259), blurRadius: 4, offset: Offset(0, 2)),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _pressed ? MedColors.blue : MedColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpecialKey extends StatefulWidget {
  const _SpecialKey({required this.label, required this.onTap, this.flex = 1, this.isActive = false});
  final String label;
  final VoidCallback onTap;
  final int flex;
  final bool isActive;

  @override
  State<_SpecialKey> createState() => _SpecialKeyState();
}

class _SpecialKeyState extends State<_SpecialKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 54,
          decoration: BoxDecoration(
            color: _pressed
                ? MedColors.blueLight
                : widget.isActive
                ? const Color(0xFFFEF3E2)
                : MedColors.surface3,
            border: Border.all(
              color: _pressed
                  ? MedColors.blue
                  : widget.isActive
                  ? MedColors.amber
                  : MedColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(9),
            boxShadow: _pressed
                ? null
                : const [
                    BoxShadow(color: MedColors.border, blurRadius: 0, offset: Offset(0, 3)),
                    BoxShadow(color: Color(0x141E3259), blurRadius: 4, offset: Offset(0, 2)),
                  ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _pressed
                    ? MedColors.blue
                    : widget.isActive
                    ? MedColors.amber
                    : MedColors.text2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftKey extends StatelessWidget {
  const _ShiftKey({required this.controller});
  final MedKeyboardController controller;

  @override
  Widget build(BuildContext context) {
    return _SpecialKey(label: '⇧ Büyük', isActive: controller.shift, onTap: controller.toggleShift);
  }
}

class _ActionKey extends StatefulWidget {
  const _ActionKey({required this.label, required this.onTap, this.flex = 1});
  final String label;
  final VoidCallback onTap;
  final int flex;

  @override
  State<_ActionKey> createState() => _ActionKeyState();
}

class _ActionKeyState extends State<_ActionKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 54,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF1560C0) : MedColors.blue,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: _pressed ? Colors.transparent : const Color(0xFF1560C0),
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(color: const Color(0x4D1A6FD8), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceKey extends StatefulWidget {
  const _SpaceKey({required this.controller});
  final MedKeyboardController controller;

  @override
  State<_SpaceKey> createState() => _SpaceKeyState();
}

class _SpaceKeyState extends State<_SpaceKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.controller.pressChar(' ');
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 54,
          decoration: BoxDecoration(
            color: _pressed ? MedColors.blueLight : MedColors.surface,
            border: Border.all(color: _pressed ? MedColors.blue : MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(9),
            boxShadow: _pressed
                ? null
                : const [BoxShadow(color: MedColors.border, blurRadius: 0, offset: Offset(0, 3))],
          ),
          child: Center(
            child: Text(
              'BOŞLUK',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _pressed ? MedColors.blue : MedColors.text3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumKey extends StatefulWidget {
  const _NumKey({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_NumKey> createState() => _NumKeyState();
}

class _NumKeyState extends State<_NumKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 60,
          decoration: BoxDecoration(
            color: _pressed ? MedColors.blueLight : MedColors.surface,
            border: Border.all(color: _pressed ? MedColors.blue : MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
            boxShadow: _pressed
                ? [const BoxShadow(color: MedColors.blue, blurRadius: 0, offset: Offset(0, 1))]
                : const [BoxShadow(color: MedColors.border, blurRadius: 0, offset: Offset(0, 3))],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _pressed ? MedColors.blue : MedColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumActionKey extends StatefulWidget {
  const _NumActionKey({required this.label, required this.onTap, this.wide = false});
  final String label;
  final VoidCallback onTap;
  final bool wide;

  @override
  State<_NumActionKey> createState() => _NumActionKeyState();
}

class _NumActionKeyState extends State<_NumActionKey> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 60,
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFF1560C0) : MedColors.blue,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _pressed ? Colors.transparent : const Color(0xFF1560C0),
                blurRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
