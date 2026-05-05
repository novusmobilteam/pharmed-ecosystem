// [SWREQ-SETUP-UI-011]
// Adımlar arası ortak header / footer bileşenleri.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.badge, required this.title, required this.subtitle});

  final String badge;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(20)),
            child: Text(
              badge,
              style: const TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: MedColors.blue,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: MedFonts.title,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: MedColors.text,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

class StepFooter extends StatelessWidget {
  const StepFooter({super.key, this.note, this.onBack, this.onNext, this.nextLabel = 'Devam Et', this.nextIcon});

  final String? note;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final Widget? nextIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: MedColors.surface2,
        border: Border(top: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            MedButton(
              label: 'Geri',
              variant: MedButtonVariant.ghost,
              prefixIcon: const Icon(Icons.arrow_back_rounded, size: 16),
              onPressed: onBack,
            ),
          if (note != null) ...[
            const SizedBox(width: 12),
            Text(
              note!,
              style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
            ),
          ],
          const Spacer(),
          if (onNext != null)
            MedButton(label: nextLabel, size: MedButtonSize.lg, onPressed: onNext, prefixIcon: nextIcon),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: MedColors.text3,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: MedColors.border2)),
      ],
    );
  }
}
