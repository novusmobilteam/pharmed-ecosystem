// lib/features/setup_wizard/presentation/screen/setup_wizard_screen.dart
//
// [SWREQ-SETUP-UI-016] [IEC 62304 §5.5]
// Setup Wizard ana ekranı.
// Sol panel: 5 adımlı sidebar. Sağ panel: aktif adım widget'ı.
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../shared/widgets/atoms/med_button.dart';
import '../../domain/model/cabin_setup_config.dart';
import '../notifier/setup_wizard_notifier.dart';
import '../state/setup_wizard_ui_state.dart';
import '../../../../core/router/app_router.dart';
import 'steps/step1_cabinet_type.dart';
import 'steps/step2_basic_info.dart';
import 'steps/step3_service_scope.dart';
import 'steps/step4_drawer_config.dart';
import 'steps/step5_summary.dart';

// ─────────────────────────────────────────────────────────────────

class SetupWizardScreen extends ConsumerWidget {
  const SetupWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(setupWizardNotifierProvider);

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Column(
        children: [
          // ── Üst başlık ──
          _WizardTopBar(),

          // ── İçerik ──
          Expanded(
            child: switch (uiState) {
              WizardActive() => _WizardActiveView(state: uiState),
              WizardSaving() => const _WizardSavingView(),
              WizardSaved(:final cabinId, :final cabinName) => _WizardSuccessView(
                cabinId: cabinId,
                cabinName: cabinName,
              ),
              WizardSaveError(:final message) => _WizardErrorView(message: message),
            },
          ),
        ],
      ),
    );
  }
}

// ── Topbar ────────────────────────────────────────────────────────

class _WizardTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: MedColors.surface,
        border: Border(bottom: BorderSide(color: MedColors.border2)),
      ),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.medication_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'MediCab',
            style: TextStyle(
              fontFamily: MedFonts.title,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: MedColors.text,
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: MedColors.border),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(20)),
            child: const Text(
              'İLK KURULUM',
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: MedColors.blue,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Aktif wizard ekranı ───────────────────────────────────────────

class _WizardActiveView extends ConsumerWidget {
  const _WizardActiveView({required this.state});
  final WizardActive state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(setupWizardNotifierProvider.notifier);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: MedColors.border),
              borderRadius: BorderRadius.circular(16),
              boxShadow: MedShadows.md,
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Sol panel: Adım listesi ──
                _StepSidebar(currentStep: state.currentStep, completedSteps: state.completedSteps),

                // Dikey ayraç
                Container(width: 1, color: MedColors.border2),

                // ── Sağ panel: Aktif adım ──
                Expanded(
                  child: _buildStep(context, state: state, notifier: notifier),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context, {required WizardActive state, required SetupWizardNotifier notifier}) {
    final draft = state.draft;

    switch (state.currentStep) {
      case 1:
        return Step1CabinetType(
          selectedType: draft.cabinetType,
          onTypeSelected: notifier.selectCabinetType,
          onNext: () => draft.step1Complete ? notifier.nextStep : null,
        );
      case 2:
        return Step2BasicInfo(
          initial: draft.basicInfo,
          onChanged: notifier.updateBasicInfo,
          onNext: draft.step2Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
        );
      case 3:
        return Step3ServiceScope(
          cabinetType: draft.cabinetType ?? CabinetType.standard,
          initial: draft.serviceScope,
          onChanged: notifier.updateServiceScope,
          onNext: draft.step3Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
        );
      case 4:
        return Step4DrawerConfig(
          cabinetType: draft.cabinetType ?? CabinetType.standard,
          drawerConfig: draft.drawerConfig,
          scanState: state.scanState,
          onScanDevice: () => notifier.scanDevice(),
          onConfigChanged: notifier.updateDrawerConfig,
          onNext: draft.step4Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
        );
      case 5:
        return Step5Summary(draft: draft, onFinish: () => notifier.finish(), onBack: notifier.previousStep);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Sol panel: adım listesi ───────────────────────────────────────

const _kStepDefs = [
  _StepDef(step: 1, title: 'Kabin Tipi', desc: 'Standart veya Mobil'),
  _StepDef(step: 2, title: 'Temel Bilgiler', desc: 'Ad, konum, bağlantı'),
  _StepDef(step: 3, title: 'Hizmet Kapsamı', desc: 'Servis veya oda listesi'),
  _StepDef(step: 4, title: 'Çekmece Yapısı', desc: 'Tarama veya manuel giriş'),
  _StepDef(step: 5, title: 'Özet', desc: 'Gözden geçir ve tamamla'),
];

class _StepDef {
  const _StepDef({required this.step, required this.title, required this.desc});
  final int step;
  final String title;
  final String desc;
}

class _StepSidebar extends StatelessWidget {
  const _StepSidebar({required this.currentStep, required this.completedSteps});

  final int currentStep;
  final Set<int> completedSteps;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        color: MedColors.surface2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KURULUM AŞAMALARI',
              style: TextStyle(
                fontFamily: MedFonts.mono,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: MedColors.text4,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? MedColors.blueLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: circleChild,
          ),
          const SizedBox(width: 10),
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
        height: 16,
        color: isDone ? MedColors.green : MedColors.border,
      ),
    );
  }
}

// ── Kaydediliyor ekranı ───────────────────────────────────────────

class _WizardSavingView extends StatelessWidget {
  const _WizardSavingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(MedColors.blue)),
          SizedBox(height: 16),
          Text(
            'Kabin kaydediliyor…',
            style: TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text3),
          ),
        ],
      ),
    );
  }
}

// ── Başarı ekranı ─────────────────────────────────────────────────

class _WizardSuccessView extends ConsumerStatefulWidget {
  const _WizardSuccessView({required this.cabinId, required this.cabinName});
  final int cabinId;
  final String cabinName;

  @override
  ConsumerState<_WizardSuccessView> createState() => _WizardSuccessViewState();
}

class _WizardSuccessViewState extends ConsumerState<_WizardSuccessView> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: MedColors.surface,
                border: Border.all(color: MedColors.border),
                borderRadius: BorderRadius.circular(20),
                boxShadow: MedShadows.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: const Color(0xFFE6F7F2), borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF0D9E6C)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kurulum Tamamlandı!',
                    style: TextStyle(
                      fontFamily: MedFonts.title,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: MedColors.text,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.cabinName} başarıyla sisteme eklendi.',
                    style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text3),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      'Kabin ID: #${widget.cabinId}',
                      style: const TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: MedColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  MedButton(
                    label: 'Dashboard\'a Git',
                    size: MedButtonSize.lg,
                    prefixIcon: const Icon(Icons.dashboard_rounded, size: 18),
                    onPressed: () =>
                        ref.read(appSetupStatusProvider.notifier).markComplete(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hata ekranı ───────────────────────────────────────────────────

class _WizardErrorView extends ConsumerWidget {
  const _WizardErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(setupWizardNotifierProvider.notifier);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: MedColors.surface,
              border: Border.all(color: const Color(0xFFFCA5A5)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: MedShadows.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(18)),
                  child: const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFFDC2626)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Kayıt Başarısız',
                  style: TextStyle(
                    fontFamily: MedFonts.title,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: MedColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                MedButton(
                  label: 'Geri Dön ve Tekrar Dene',
                  variant: MedButtonVariant.secondary,
                  prefixIcon: const Icon(Icons.refresh_rounded, size: 16),
                  onPressed: notifier.retryFromError,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
