// // [SWREQ-SETUP-UI-016] [IEC 62304 §5.
// // Setup Wizard ana ekranı.
// // Sol panel: 5 adımlı sidebar. Sağ panel: aktif adım widget'ı.
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_client/core/setup/app_setup_notifier.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import '../../auth/auth.dart';
// import '../notifier/setup_wizard_notifier.dart';
// import '../state/setup_wizard_state.dart';
// import 'step1_view.dart';
// import 'step2_view.dart';
// import 'step3_view.dart';
// import 'step4_view.dart';
// import 'step5_view.dart';

// part '../widgets/sidebar_view.dart';

// class SetupWizardScreen extends ConsumerWidget {
//   const SetupWizardScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final uiState = ref.watch(setupWizardNotifierProvider);

//     return Scaffold(
//       backgroundColor: MedColors.bg,
//       body: Column(
//         children: [
//           Expanded(
//             child: switch (uiState) {
//               WizardActive() => WizardActiveView(state: uiState),
//               WizardSaving() => const _WizardSavingView(),
//               WizardSaved(:final cabinId, :final cabinName) => WizardSuccessView(
//                 cabinId: cabinId,
//                 cabinName: cabinName,
//               ),
//               WizardSaveError(:final message) => WizardErrorView(message: message),
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class WizardActiveView extends ConsumerWidget {
//   const WizardActiveView({super.key, required this.state});

//   final WizardActive state;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifier = ref.read(setupWizardNotifierProvider.notifier);

//     return Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 920),
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Container(
//             decoration: BoxDecoration(
//               color: MedColors.surface,
//               border: Border.all(color: MedColors.border),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: MedShadows.md,
//             ),
//             clipBehavior: Clip.hardEdge,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 StepSidebarView(currentStep: state.currentStep, completedSteps: state.completedSteps),
//                 Container(width: 1, color: MedColors.border2),
//                 Expanded(
//                   child: _buildStep(context, state: state, notifier: notifier),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStep(BuildContext context, {required WizardActive state, required SetupWizardNotifier notifier}) {
//     switch (state.currentStep) {
//       case 1:
//         return Step1View();
//       case 2:
//         return Step2View();
//       case 3:
//         return Step3View();
//       case 4:
//         return Step4View();
//       case 5:
//         return Step5View();
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }

// // MARK: Kaydediliyor
// class _WizardSavingView extends StatelessWidget {
//   const _WizardSavingView();

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(MedColors.blue)),
//           SizedBox(height: 16),
//           Text(
//             context.l10n.wizard_savingMessage,
//             style: TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text3),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // MARK: Kurulum başarılı
// class WizardSuccessView extends ConsumerStatefulWidget {
//   const WizardSuccessView({super.key, required this.cabinId, required this.cabinName});
//   final int cabinId;
//   final String cabinName;

//   @override
//   ConsumerState<WizardSuccessView> createState() => WizardSuccessViewState();
// }

// class WizardSuccessViewState extends ConsumerState<WizardSuccessView> with SingleTickerProviderStateMixin {
//   late final AnimationController _ctrl;
//   late final Animation<double> _scale;

//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
//     _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
//   }

//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 480),
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: ScaleTransition(
//             scale: _scale,
//             child: Container(
//               padding: const EdgeInsets.all(40),
//               decoration: BoxDecoration(
//                 color: MedColors.surface,
//                 border: Border.all(color: MedColors.border),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: MedShadows.md,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 72,
//                     height: 72,
//                     decoration: BoxDecoration(color: const Color(0xFFE6F7F2), borderRadius: BorderRadius.circular(20)),
//                     child: const Icon(Icons.check_circle_rounded, size: 36, color: Color(0xFF0D9E6C)),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     context.l10n.wizard_successTitle,
//                     style: const TextStyle(
//                       fontFamily: MedFonts.title,
//                       fontSize: 22,
//                       fontWeight: FontWeight.w800,
//                       color: MedColors.text,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     context.l10n.wizard_successMessage(widget.cabinName),
//                     style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 14, color: MedColors.text3),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     context.l10n.wizard_successReloginPrompt,
//                     style: const TextStyle(
//                       fontFamily: MedFonts.sans,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: MedColors.text2,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
//                     decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: BorderRadius.circular(8)),
//                     child: Text(
//                       context.l10n.wizard_successCabinId(widget.cabinId),
//                       style: const TextStyle(
//                         fontFamily: MedFonts.mono,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: MedColors.blue,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   MedButton(
//                     label: context.l10n.wizard_successLoginButton,
//                     size: MedButtonSize.lg,
//                     prefixIcon: const Icon(Icons.login_rounded, size: 18),
//                     onPressed: () async {
//                       ref.read(authNotifierProvider.notifier).logout();
//                       ref.read(appSetupStatusProvider.notifier).markComplete();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // MARK: Kurulum hatalı
// class WizardErrorView extends ConsumerWidget {
//   const WizardErrorView({super.key, required this.message});

//   final String message;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final notifier = ref.read(setupWizardNotifierProvider.notifier);

//     return Center(
//       child: ConstrainedBox(
//         constraints: const BoxConstraints(maxWidth: 440),
//         child: Padding(
//           padding: const EdgeInsets.all(32),
//           child: Container(
//             padding: const EdgeInsets.all(36),
//             decoration: BoxDecoration(
//               color: MedColors.surface,
//               border: Border.all(color: const Color(0xFFFCA5A5)),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: MedShadows.md,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 64,
//                   height: 64,
//                   decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(18)),
//                   child: const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFFDC2626)),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   context.l10n.wizard_errorTitle,
//                   style: const TextStyle(
//                     fontFamily: MedFonts.title,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     color: MedColors.text,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   message,
//                   style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
//                   textAlign: TextAlign.center,
//                 ),
//                 if (notifier.macAddress != null) Text(notifier.macAddress!, style: MedTextStyles.monoSm()),
//                 const SizedBox(height: 24),
//                 MedButton(
//                   label: context.l10n.wizard_retryButton,
//                   variant: MedButtonVariant.secondary,
//                   prefixIcon: const Icon(Icons.refresh_rounded, size: 16),
//                   onPressed: notifier.retryFromError,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
