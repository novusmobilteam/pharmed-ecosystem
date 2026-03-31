part of 'step2_basic_info.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: MedFonts.sans,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: MedColors.text2,
      ),
    );
  }
}
