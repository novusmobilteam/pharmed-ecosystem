part of '../view/medicine_management_view.dart';

class _ModeToggleButton extends StatelessWidget {
  final bool isOrderless;
  final Color accentColor;
  final VoidCallback onPressed;

  const _ModeToggleButton({
    required this.isOrderless,
    required this.accentColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final targetColor = isOrderless
        ? const Color(0xFF1565C0) // Orderlıya geç → mavi
        : const Color(0xFFE65100); // Ordersıza geç → turuncu

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isOrderless ? PhosphorIcons.clipboardText() : PhosphorIcons.lightning(),
          size: 16,
        ),
        label: Text(
          isOrderless ? 'Orderlı Moda Geç' : 'Ordersız Moda Geç',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: targetColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }
}
