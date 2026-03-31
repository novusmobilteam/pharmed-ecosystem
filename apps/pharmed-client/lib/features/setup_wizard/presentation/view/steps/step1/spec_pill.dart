part of 'step1_cabin_type.dart';

class SpecPill extends StatelessWidget {
  const SpecPill({super.key, required this.label, required this.highlighted});
  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0x1A1A6FD8) : MedColors.surface3,
        border: Border.all(color: highlighted ? const Color(0x401A6FD8) : MedColors.border2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: MedFonts.mono,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: highlighted ? MedColors.blue : MedColors.text2,
        ),
      ),
    );
  }
}
