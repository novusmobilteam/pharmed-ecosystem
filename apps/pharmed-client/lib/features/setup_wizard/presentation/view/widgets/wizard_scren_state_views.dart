part of '../setup_wizard_screen.dart';

// MARK: Anlık görsel
class WizardActiveView extends ConsumerWidget {
  const WizardActiveView({super.key, required this.state});

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
                StepSidebarView(currentStep: state.currentStep, completedSteps: state.completedSteps),
                Container(width: 1, color: MedColors.border2),
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
          onNext: () => draft.step1Complete ? notifier.nextStep() : null,
        );
      case 2:
        return Step2BasicInfo(
          initial: draft.basicInfo,
          onChanged: notifier.updateBasicInfo,
          onNext: draft.step2Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
          availablePorts: state.availablePorts,
          onTestRfid: notifier.testRfidConnection,
          rfidTestState: state.rfidTestState,
          rfidReaderInfo: state.rfidReaderInfo,
          rfidTestError: state.rfidTestError,
          onTestCabinCard: notifier.testCabinConnection,
          cabinCardTestState: state.cabinCardTestState,
          cabinTestError: state.cabinCardTestError,
        );
      case 3:
        return Step3StationScope(
          cabinetType: draft.cabinetType!,
          currentScope: draft.serviceScope,
          stationsLoadState: state.stationsLoadState,
          stations: state.stations,
          stationsError: state.stationsError,
          onScopeChanged: notifier.updateServiceScope,
          onRetryStations: () => notifier.loadStations(),
          onNext: draft.step3Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
          onStationSelected: (station) => notifier.onStationSelected(station),
          servicesLoadState: state.servicesLoadState,
          services: state.services,
        );
      case 4:
        return Step4DrawerConfig(
          cabinetType: draft.cabinetType!,
          scanState: state.scanState,
          mobileLayout: draft.mobileLayout,
          onScanDevice: notifier.scanDevice,
          onResetScan: notifier.resetScan,
          onDrawerCountChanged: notifier.updateDrawerCount,
          onDrawerConfigChanged: notifier.updateDrawerConfig,
          onNext: draft.step4Complete ? notifier.nextStep : null,
          onBack: notifier.previousStep,
          onSameConfigToggled: (val) => notifier.toggleSameConfig(value: val),
          scanLogs: state.scanLogs,
          scannedLayout: draft.scannedLayout ?? [],
        );
      case 5:
        return Step5Summary(draft: draft, onFinish: notifier.finish, onBack: notifier.previousStep);

      default:
        return const SizedBox.shrink();
    }
  }
}

// MARK: Kaydediliyor
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

// MARK: Kurulum başarılı
class WizardSuccessView extends ConsumerStatefulWidget {
  const WizardSuccessView({super.key, required this.cabinId, required this.cabinName});
  final int cabinId;
  final String cabinName;

  @override
  ConsumerState<WizardSuccessView> createState() => WizardSuccessViewState();
}

class WizardSuccessViewState extends ConsumerState<WizardSuccessView> with SingleTickerProviderStateMixin {
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
                    onPressed: () => ref.read(appSetupStatusProvider.notifier).markComplete(),
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

// MARK: Kurulum hatalı
class WizardErrorView extends ConsumerWidget {
  const WizardErrorView({super.key, required this.message});

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
