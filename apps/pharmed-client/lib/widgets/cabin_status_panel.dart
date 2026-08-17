// // [SWREQ-CLI-DASH-CABINSTATUS-001] [IEC 62304 §5.5]
// // Kabin görselleştirmesi + bağlantı durumunu tek panelde toplayan bağımsız
// // widget. Dashboard'a bağlı değildir; kabin özetinin gösterildiği her yerde
// // kullanılabilir.
// //
// // Panel başlığında bağlantı rozeti (nokta/spinner + renkli etiket) yaşar;
// // hata varsa gövdeye "yeniden bağlan" butonu düşer.
// //
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// import '../core/hardware/hardware.dart';

// class CabinStatusPanel extends ConsumerWidget {
//   const CabinStatusPanel({super.key, required this.cabin});

//   final CabinVisualizerData cabin;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final conn = ref.watch(cabinConnectionProvider);
//     final tone = _ConnectionTone.of(conn.status);
//     final isError = conn.status == CabinConnectionStatus.error;

//     return Container(
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: isError ? MedColors.red : MedColors.border, width: isError ? 1.5 : 1),
//         borderRadius: MedRadius.lgAll,
//         boxShadow: MedShadows.sm,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           _Header(
//             title: context.l10n.dashboard_cabinStatusHeader,
//             leading: _ConnectionIndicator(status: conn.status, color: tone.color),
//             trailing: Text(
//               tone.label(context),
//               style: MedTextStyles.bodySm(color: tone.color, weight: FontWeight.w500),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(MedSpacing.xl),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 CabinSummaryView(slots: cabin.slots, cabinId: ''),
//                 if (isError) ...[
//                   const SizedBox(height: MedSpacing.lg),
//                   _ReconnectButton(onTap: () => ref.read(cabinConnectionProvider.notifier).reconnect()),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Panel başlığı ────────────────────────────────────────────────────────────

// class _Header extends StatelessWidget {
//   // ignore: unused_element_parameter
//   const _Header({required this.title, this.icon, this.leading, this.trailing});

//   final String title;
//   final IconData? icon;

//   /// Icon yerine özel bir widget (ör. bağlantı göstergesi) koymak için.
//   final Widget? leading;
//   final Widget? trailing;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl, vertical: MedSpacing.lg),
//       decoration: const BoxDecoration(
//         color: MedColors.surface2,
//         border: Border(bottom: BorderSide(color: MedColors.border2)),
//         borderRadius: BorderRadius.only(topLeft: MedRadius.lg, topRight: MedRadius.lg),
//       ),
//       child: Row(
//         children: [
//           if (leading != null) leading! else if (icon != null) Icon(icon, size: 18, color: MedColors.text3),
//           const SizedBox(width: MedSpacing.md),
//           Expanded(child: Text(title, style: MedTextStyles.titleSm())),
//           ?trailing,
//         ],
//       ),
//     );
//   }
// }

// // ── Bağlantı göstergesi: bağlanıyorsa spinner, aksi halde durum noktası ─────────

// class _ConnectionIndicator extends StatelessWidget {
//   const _ConnectionIndicator({required this.status, required this.color});

//   final CabinConnectionStatus status;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     if (status == CabinConnectionStatus.connecting) {
//       return SizedBox(
//         width: 10,
//         height: 10,
//         child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
//       );
//     }
//     return StatusDot(color: color, size: 8);
//   }
// }

// // ── Yeniden bağlan butonu ──────────────────────────────────────────────────────

// class _ReconnectButton extends StatelessWidget {
//   const _ReconnectButton({required this.onTap});

//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: MedRadius.mdAll,
//         child: Container(
//           height: MedSpacing.touchTarget,
//           decoration: BoxDecoration(color: MedColors.red, borderRadius: MedRadius.mdAll, boxShadow: MedShadows.sm),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(PhosphorIcons.arrowClockwise(), size: 16, color: Colors.white),
//               const SizedBox(width: MedSpacing.sm),
//               Text(
//                 context.l10n.dashboard_cabinConnection_reconnectButton,
//                 style: MedTextStyles.bodyMd(color: Colors.white, weight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ── Bağlantı durumu → renk + etiket ────────────────────────────────────────────

// enum _ConnectionTone {
//   connected(MedColors.green),
//   connecting(MedColors.amber),
//   error(MedColors.red),
//   disconnected(MedColors.text3);

//   const _ConnectionTone(this.color);

//   final Color color;

//   static _ConnectionTone of(CabinConnectionStatus status) => switch (status) {
//     CabinConnectionStatus.connected => _ConnectionTone.connected,
//     CabinConnectionStatus.connecting => _ConnectionTone.connecting,
//     CabinConnectionStatus.error => _ConnectionTone.error,
//     CabinConnectionStatus.disconnected => _ConnectionTone.disconnected,
//   };

//   String label(BuildContext context) => switch (this) {
//     _ConnectionTone.connected => context.l10n.dashboard_cabinConnectionStatus_connected,
//     _ConnectionTone.connecting => context.l10n.dashboard_cabinConnectionStatus_connecting,
//     _ConnectionTone.error => context.l10n.dashboard_cabinConnectionStatus_error,
//     _ConnectionTone.disconnected => context.l10n.dashboard_cabinConnectionStatus_disconnected,
//   };
// }
