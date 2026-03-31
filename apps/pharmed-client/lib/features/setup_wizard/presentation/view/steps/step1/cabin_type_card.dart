part of 'step1_cabin_type.dart';

class CabinTypeCard extends StatelessWidget {
  const CabinTypeCard({
    super.key,
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.visual,
    required this.specs,
    required this.description,
  });

  final CabinType type;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget visual;
  final List<String> specs;
  final String description;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        height: 340,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBF4FF) : MedColors.surface,
          border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x1F1A6FD8), blurRadius: 0, spreadRadius: 3),
                  BoxShadow(color: Color(0x171E3259), blurRadius: 12, offset: Offset(0, 4)),
                ]
              : MedShadows.sm,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                visual,
                const SizedBox(height: 16),
                Text(
                  type.label,
                  style: TextStyle(
                    fontFamily: MedFonts.title,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? MedColors.blue : MedColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: specs.map((s) => SpecPill(label: s, highlighted: isSelected)).toList(),
                ),
              ],
            ),
            // Checkmark rozeti
            Positioned(
              top: 0,
              right: 0,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.elasticOut,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
