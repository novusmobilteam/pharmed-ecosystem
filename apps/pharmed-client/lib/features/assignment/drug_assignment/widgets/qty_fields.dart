part of '../view/drug_assignment_panel.dart';

class _QtyFields extends StatelessWidget {
  const _QtyFields({
    required this.minQty,
    required this.maxQty,
    required this.criticalQty,
    required this.onMinChanged,
    required this.onMaxChanged,
    required this.onCriticalChanged,
  });

  final int? minQty;
  final int? maxQty;
  final int? criticalQty;
  final ValueChanged<int?> onMinChanged;
  final ValueChanged<int?> onMaxChanged;
  final ValueChanged<int?> onCriticalChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   context.l10n.assignment_quantitySectionLabel,
        //   style: TextStyle(
        //     fontFamily: MedFonts.mono,
        //     fontSize: 9,
        //     fontWeight: FontWeight.w500,
        //     letterSpacing: 1,
        //     color: MedColors.text3,
        //   ),
        // ),
        // const SizedBox(height: 6),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: _QtyInput(label: context.l10n.common_minLabel, value: minQty, onChanged: onMinChanged),
            ),
            Expanded(
              child: _QtyInput(label: context.l10n.common_maxLabel, value: maxQty, onChanged: onMaxChanged),
            ),
            Expanded(
              child: _QtyInput(
                label: context.l10n.common_criticalLabel,
                value: criticalQty,
                onChanged: onCriticalChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QtyInput extends StatefulWidget {
  const _QtyInput({required this.label, required this.value, required this.onChanged});

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  State<_QtyInput> createState() => _QtyInputState();
}

class _QtyInputState extends State<_QtyInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(_QtyInput old) {
    super.didUpdateWidget(old);
    // Dışarıdan value değişirse (göz değişimi) controller'ı güncelle
    if (widget.value != old.value) {
      final newText = widget.value?.toString() ?? '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: MedFonts.mono, fontSize: 14, fontWeight: FontWeight.w600, color: MedColors.text),
          decoration: InputDecoration(
            filled: true,
            fillColor: MedColors.surface2,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.blue, width: 1.5),
            ),
          ),
          onChanged: (v) => widget.onChanged(int.tryParse(v)),
        ),
      ],
    );
  }
}
