import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class NumpadInputField extends StatefulWidget {
  final String? label;
  final String value;
  final String hint;
  final String? title;
  final Function(String) onChanged;
  final String? unit;

  const NumpadInputField({
    super.key,
    this.label,
    required this.value,
    this.hint = '0',
    this.title,
    required this.onChanged,
    this.unit,
  });

  @override
  State<NumpadInputField> createState() => _NumpadInputFieldState();
}

class _NumpadInputFieldState extends State<NumpadInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(NumpadInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.value.isEmpty;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: InkWell(
        onTap: () async {
          // final String? result = await showNumpadView(
          //   context,
          //   hintText: widget.hint,
          //   title: widget.title ?? widget.label ?? widget.hint,
          //   initialValue: widget.value == '0' ? '' : widget.value,
          // );

          // if (result != null) {
          //   widget.onChanged(result);
          // }
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Row(
            spacing: 3,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isEmpty ? widget.hint : widget.value,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isEmpty ? context.colorScheme.outline : context.colorScheme.onSurface,
                ),
              ),
              if (widget.unit != null && widget.value != '0')
                Text(
                  widget.unit!,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEmpty ? context.colorScheme.outline : context.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
