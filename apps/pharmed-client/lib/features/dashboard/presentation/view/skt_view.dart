// part of 'dashboard_screen.dart';

// class SktView extends StatelessWidget {
//   const SktView({super.key, required this.skt, required this.isStale});

//   final List<CabinStock> skt;
//   final bool isStale;

//   @override
//   Widget build(BuildContext context) {
//     final items = skt.map((stock) {
//       return SktItem(
//         medicineName: stock.medicine?.name ?? '—',
//         detail: [
//           //stock.assignment?.cabin?.name,
//           if (stock.quantity != null) '${stock.quantity} ${stock.assignment?.operationUnit ?? ''}',
//           //if (stock.lotNumber != null) 'Lot: ${stock.lotNumber}',
//         ].join(' · '),
//         status: stock.sktStatus,
//         daysRemaining: stock.remainingDay,
//       );
//     }).toList();

//     return SktList(items: items, isStale: isStale);
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// // SktList
// // [SWREQ-UI-005] [HAZ-008]
// // Son kullanma tarihi yaklaşan/geçen ilaç listesi.
// // Geçmiş SKT ayrı renk + "imha et" etiketiyle gösterilir.
// // Sınıf: Class B — Geçmiş SKT gözden kaçarsa [HAZ-008]
// // ─────────────────────────────────────────────────────────────────

// class SktItem {
//   const SktItem({
//     required this.medicineName,
//     required this.detail,
//     required this.status,
//     this.daysRemaining,
//     this.onTap,
//   });

//   final String medicineName;
//   final String detail;
//   final SktStatus status;
//   final int? daysRemaining;
//   final VoidCallback? onTap;
// }

// class SktList extends StatelessWidget {
//   const SktList({super.key, required this.items, this.isStale = false});

//   final List<SktItem> items;

//   /// [HAZ-007] true → header badge soluklaşır
//   final bool isStale;

//   @override
//   Widget build(BuildContext context) {
//     // [HAZ-008] Otomatik sınıflandırma — sayım hesapları
//     final expiredCount = items.where((i) => i.status == SktStatus.expired).length;
//     final criticalCount = items.where((i) => i.status == SktStatus.critical).length;
//     final warningCount = items.where((i) => i.status == SktStatus.warning).length;
//     final total = items.length;

//     return Container(
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: MedColors.border),
//         borderRadius: MedRadius.lgAll,
//         boxShadow: MedShadows.md,
//       ),
//       child: Column(
//         children: [
//           _SktHeader(itemCount: total, isStale: isStale),
//           Padding(
//             padding: const EdgeInsets.all(8),
//             child: Column(
//               children: [
//                 for (int i = 0; i < items.length; i++) ...[
//                   SktRow(
//                     medicineName: items[i].medicineName,
//                     detail: items[i].detail,
//                     status: items[i].status,
//                     daysRemaining: items[i].daysRemaining,
//                     onTap: items[i].onTap,
//                   ),
//                   if (i < items.length - 1) const SizedBox(height: 4),
//                 ],
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: const BoxDecoration(
//               border: Border(top: BorderSide(color: MedColors.border2)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 MedRingChart(
//                   count: criticalCount,
//                   total: total,
//                   color: MedColors.red,
//                   label: context.l10n.dashboard_sktCriticalRingLabel,
//                 ),
//                 MedRingChart(
//                   count: warningCount,
//                   total: total,
//                   color: MedColors.amber,
//                   label: context.l10n.dashboard_sktWarningRingLabel,
//                 ),
//                 MedRingChart(
//                   count: expiredCount,
//                   total: total,
//                   color: MedColors.redDark,
//                   label: context.l10n.dashboard_sktExpiredRingLabel,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SktHeader extends StatelessWidget {
//   const _SktHeader({required this.itemCount, required this.isStale});

//   final int itemCount;
//   final bool isStale;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: MedColors.border2)),
//       ),
//       child: Row(
//         children: [
//           MedStatusDot(color: MedColors.amber),
//           const SizedBox(width: 8),
//           Text(context.l10n.dashboard_sktStatusHeader, style: MedTextStyles.titleSm()),
//           const Spacer(),
//           AnimatedOpacity(
//             opacity: isStale ? 0.45 : 1.0,
//             duration: const Duration(milliseconds: 300),
//             child: MedBadge(label: context.l10n.dashboard_sktItemCountBadge(itemCount), variant: MedBadgeVariant.amber),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// // SktRow
// // [SWREQ-UI-MOL-002] [HAZ-008]
// // Kullanım: SKT listesindeki tek satır — yaklaşan/geçmiş ilaç.
// // Sınıf  : Class B — geçmiş SKT gözden kaçarsa hasta riski oluşur.
// // ─────────────────────────────────────────────────────────────────

// enum SktStatus { expired, critical, warning }

// class SktRow extends StatelessWidget {
//   const SktRow({
//     super.key,
//     required this.medicineName,
//     required this.detail,
//     required this.status,
//     this.daysRemaining,
//     this.onTap,
//   });

//   final String medicineName;

//   /// Örn: "A-12 · 6 torba · Lot: SF22A"
//   final String detail;

//   final SktStatus status;

//   /// null → geçmiş SKT (expired)
//   final int? daysRemaining;

//   final VoidCallback? onTap;

//   @override
//   Widget build(BuildContext context) {
//     final colors = _resolveColors(status);

//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
//         decoration: BoxDecoration(
//           color: colors.background,
//           border: Border.all(color: colors.border),
//           borderRadius: MedRadius.mdAll,
//         ),
//         child: Row(
//           children: [
//             MedStatusBar(color: colors.bar, height: 38),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   MedLabel(
//                     text: medicineName,
//                     variant: MedLabelVariant.monoValue,
//                     color: status == SktStatus.expired ? MedColors.red : MedColors.text,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 2),
//                   MedLabel(text: detail, variant: MedLabelVariant.monoDetail),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 8),
//             _DaysIndicator(status: status, daysRemaining: daysRemaining),
//           ],
//         ),
//       ),
//     );
//   }

//   _SktColors _resolveColors(SktStatus status) {
//     return switch (status) {
//       SktStatus.expired => _SktColors(
//         background: const Color(0xFFFFF8F8),
//         border: const Color(0xFFFCA5A5),
//         bar: MedColors.redDark,
//       ),
//       SktStatus.critical => _SktColors(background: MedColors.surface2, border: MedColors.border2, bar: MedColors.red),
//       SktStatus.warning => _SktColors(background: MedColors.surface2, border: MedColors.border2, bar: MedColors.amber),
//     };
//   }
// }

// class _DaysIndicator extends StatelessWidget {
//   const _DaysIndicator({required this.status, required this.daysRemaining});

//   final SktStatus status;
//   final int? daysRemaining;

//   @override
//   Widget build(BuildContext context) {
//     if (status == SktStatus.expired) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             context.l10n.dashboard_sktExpiredTag,
//             style: TextStyle(
//               fontFamily: MedFonts.mono,
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               letterSpacing: 0.3,
//               color: MedColors.red,
//             ),
//           ),
//           const SizedBox(height: 1),
//           Text(context.l10n.dashboard_sktDestroyHint, style: MedTextStyles.monoXs(color: MedColors.red)),
//         ],
//       );
//     }

//     final color = switch (status) {
//       SktStatus.critical => MedColors.red,
//       SktStatus.warning => MedColors.amber,
//       SktStatus.expired => MedColors.red,
//     };

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         Text('${daysRemaining ?? 0}', style: MedTextStyles.titleMd(color: color)),
//         const SizedBox(height: 1),
//         Text(context.l10n.dashboard_sktDaysRemainingLabel(daysRemaining ?? 0), style: MedTextStyles.monoXs()),
//       ],
//     );
//   }
// }

// final class _SktColors {
//   const _SktColors({required this.background, required this.border, required this.bar});
//   final Color background;
//   final Color border;
//   final Color bar;
// }
