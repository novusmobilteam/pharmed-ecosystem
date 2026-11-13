import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../core/report.dart';
import '../core/test_status.dart';
import 'status.dart';

export '../core/test_status.dart';
export 'status.dart';

/// Başlık + içerik kartı.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Test adımı sonucunun rozeti. Görünüm ortak [StatusBadge] ile aynıdır.
class ResultBadge extends StatelessWidget {
  const ResultBadge({super.key, required this.result, required this.label});

  final StepResult result;
  final String label;

  @override
  Widget build(BuildContext context) => StatusBadge(status: result.status, label: label);
}

/// COM port bağlı değilken gösterilen tek tip uyarı.
class NotConnectedHint extends StatelessWidget {
  const NotConnectedHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.link_off, size: 16, color: TestStatus.failed.color),
        const SizedBox(width: MedSpacing.xs),
        Text('Önce COM porta bağlanın.', style: TextStyle(color: TestStatus.failed.color)),
      ],
    );
  }
}

/// Hata metni (servis / tarama hatası).
class ErrorText extends StatelessWidget {
  const ErrorText(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Text(message, style: TextStyle(color: TestStatus.failed.color));
}

/// Sayı girişi (satır, port, göz).
class NumberField extends StatelessWidget {
  const NumberField({super.key, required this.label, required this.controller, this.width = 110});

  final String label;
  final TextEditingController controller;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, isDense: true, border: const OutlineInputBorder()),
      ),
    );
  }
}

void showMessage(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: error ? MedColors.red : null),
  );
}

/// Sonucu [StepResult]'a göre etiketleyen "busy" farkındalıklı buton.
class BusyButton extends StatelessWidget {
  const BusyButton({super.key, required this.label, required this.onPressed, this.busy = false, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: busy ? null : onPressed,
      icon: busy
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(icon ?? Icons.play_arrow),
      label: Text(label),
    );
  }
}
