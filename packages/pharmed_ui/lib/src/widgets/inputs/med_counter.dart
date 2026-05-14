import 'package:flutter/material.dart';

import 'package:pharmed_ui/pharmed_ui.dart';

class MedCounter extends StatelessWidget {
  const MedCounter({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int value;
  final int min;
  final int max;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterBtn(icon: Icons.remove_rounded, onTap: value > min ? onDecrement : null),
          Container(
            width: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: MedColors.border),
                right: BorderSide(color: MedColors.border),
              ),
            ),
            child: Text(
              '$value',
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: MedColors.text,
              ),
            ),
          ),
          _CounterBtn(icon: Icons.add_rounded, onTap: value < max ? onIncrement : null),
        ],
      ),
    );
  }
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(icon, size: 20, color: onTap != null ? MedColors.text2 : MedColors.text4),
      ),
    );
  }
}
