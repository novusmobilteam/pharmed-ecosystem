part of '../setup_wizard_screen.dart';

class _StepDef {
  const _StepDef({required this.step, required this.title, required this.desc});
  final int step;
  final String title;
  final String desc;
}

const _kStepDefs = [
  _StepDef(step: 1, title: 'Kabin Tipi', desc: 'Standart veya Mobil'),
  _StepDef(step: 2, title: 'Temel Bilgiler', desc: 'Ad, konum, bağlantı'),
  _StepDef(step: 3, title: 'Hizmet Kapsamı', desc: 'Servis veya oda tanımları'),
  _StepDef(step: 4, title: 'Çekmece Yapısı', desc: 'Tarama veya manuel giriş'),
  _StepDef(step: 5, title: 'Özet', desc: 'Gözden geçir ve tamamla'),
];

class StepSidebarView extends StatelessWidget {
  const StepSidebarView({super.key, required this.currentStep, required this.completedSteps});

  final int currentStep;
  final Set<int> completedSteps;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 20, 20),
        decoration: BoxDecoration(color: MedColors.surface2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kabin Kurulumu',
              style: TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: MedColors.text,
                height: 1.1,
              ),
            ),
            const Text(
              'Yeni cihaz yapılandırması',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MedColors.text3,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 40),
            for (var i = 0; i < _kStepDefs.length; i++) ...[
              _StepItem(
                def: _kStepDefs[i],
                isActive: _kStepDefs[i].step == currentStep,
                isDone: completedSteps.contains(_kStepDefs[i].step),
              ),
              if (i < _kStepDefs.length - 1) _StepConnector(isDone: completedSteps.contains(_kStepDefs[i].step)),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({required this.def, required this.isActive, required this.isDone});

  final _StepDef def;
  final bool isActive;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final Color circleColor;
    final Color textColor;
    final Widget circleChild;

    if (isDone) {
      circleColor = MedColors.green;
      textColor = MedColors.text2;
      circleChild = const Icon(Icons.check_rounded, size: 12, color: Colors.white);
    } else if (isActive) {
      circleColor = MedColors.blue;
      textColor = MedColors.text;
      circleChild = Text(
        '${def.step}',
        style: const TextStyle(
          fontFamily: MedFonts.title,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      );
    } else {
      circleColor = MedColors.border;
      textColor = MedColors.text3;
      circleChild = Text(
        '${def.step}',
        style: const TextStyle(
          fontFamily: MedFonts.title,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MedColors.text3,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: isDone && !isActive ? 0 : 8),
      decoration: BoxDecoration(
        color: isActive ? MedColors.blueLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 10.0,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: circleChild,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  def.title,
                  style: TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Text(
                  def.desc,
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 10, color: MedColors.text4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 21),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 2,
        height: 20,
        color: isDone ? MedColors.green : MedColors.border,
      ),
    );
  }
}
