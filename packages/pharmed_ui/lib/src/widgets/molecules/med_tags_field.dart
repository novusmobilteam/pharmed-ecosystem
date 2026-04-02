import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

// ─────────────────────────────────────────────────────────────────
// MedTagsField
// [SWREQ-UI-MOL-TAG-001]
// Oda/Servis etiket girişi — chip tabanlı çoklu değer girişi.
// Enter veya virgülle yeni etiket eklenir.
// Sınıf : Class A (görsel girdi)
// ─────────────────────────────────────────────────────────────────

class MedTagsField extends StatefulWidget {
  const MedTagsField({
    super.key,
    this.initialTags = const [],
    this.onChanged,
    this.label,
    this.placeholder = 'Değer ekle...',
    this.helperText,
  });

  final List<String> initialTags;
  final ValueChanged<List<String>>? onChanged;
  final String? label;
  final String placeholder;
  final String? helperText;

  @override
  State<MedTagsField> createState() => _MedTagsFieldState();
}

class _MedTagsFieldState extends State<MedTagsField> {
  late List<String> _tags;
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _tags = List.of(widget.initialTags);
    _focus.addListener(() {
      setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addTag(String val) {
    final trimmed = val.trim();
    if (trimmed.isNotEmpty && !_tags.contains(trimmed)) {
      setState(() => _tags.add(trimmed));
      _ctrl.clear();
      widget.onChanged?.call(List.unmodifiable(_tags));
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: MedColors.text2,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onTap: () => _focus.requestFocus(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              color: _focused ? MedColors.surface : MedColors.surface2,
              border: Border.all(color: _focused ? MedColors.blue : MedColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
              boxShadow: _focused ? const [BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3)] : null,
            ),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._tags.map((tag) => _TagChip(label: tag, onRemove: () => _removeTag(tag))),
                IntrinsicWidth(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text),
                    decoration: InputDecoration(
                      hintText: _tags.isEmpty ? widget.placeholder : '',
                      hintStyle: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text4),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                      isDense: true,
                      constraints: const BoxConstraints(minWidth: 80),
                    ),
                    onSubmitted: (val) {
                      _addTag(val);
                      _focus.requestFocus();
                    },
                    onChanged: (val) {
                      if (val.endsWith(',')) {
                        _addTag(val.replaceAll(',', ''));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MedColors.blue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: MedColors.blue),
          ),
        ],
      ),
    );
  }
}
