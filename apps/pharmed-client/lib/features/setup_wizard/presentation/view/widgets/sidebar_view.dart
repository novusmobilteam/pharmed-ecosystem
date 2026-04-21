part of '../setup_wizard_screen.dart';

class _StepDef {
  const _StepDef({required this.step, required this.title, required this.desc});
  final int step;
  final String title;
  final String desc;
}

// Step definitions are built at runtime inside StepSidebarView.build to support l10n.

class StepSidebarView extends StatelessWidget {
  const StepSidebarView({super.key, required this.currentStep, required this.completedSteps});

  final int currentStep;
  final Set<int> completedSteps;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepDef(step: 1, title: context.l10n.wizard_step1SidebarTitle, desc: context.l10n.wizard_step1SidebarDesc),
      _StepDef(step: 2, title: context.l10n.wizard_step2SidebarTitle, desc: context.l10n.wizard_step2SidebarDesc),
      _StepDef(step: 3, title: context.l10n.wizard_step3SidebarTitle, desc: context.l10n.wizard_step3SidebarDesc),
      _StepDef(step: 4, title: context.l10n.wizard_step4SidebarTitle, desc: context.l10n.wizard_step4SidebarDesc),
      _StepDef(step: 5, title: context.l10n.wizard_step5SidebarTitle, desc: context.l10n.wizard_step5SidebarDesc),
    ];

    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 20, 20),
        decoration: BoxDecoration(color: MedColors.surface2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.wizard_sidebarTitle,
              style: const TextStyle(
                fontFamily: MedFonts.title,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: MedColors.text,
                height: 1.1,
              ),
            ),
            Text(
              context.l10n.wizard_sidebarSubtitle,
              style: const TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: MedColors.text3,
                height: 1.1,
              ),
            ),

            const SizedBox(height: 40),
            for (var i = 0; i < steps.length; i++) ...[
              _StepItem(
                def: steps[i],
                isActive: steps[i].step == currentStep,
                isDone: completedSteps.contains(steps[i].step),
              ),
              if (i < steps.length - 1) _StepConnector(isDone: completedSteps.contains(steps[i].step)),
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
