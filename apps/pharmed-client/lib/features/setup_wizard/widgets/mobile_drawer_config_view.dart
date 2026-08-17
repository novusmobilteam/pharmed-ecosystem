// part of '../view/step4_view.dart';

// // [SWREQ-SETUP-UI-011] [IEC 62304 §5.5]
// // Mobil kabin wizard adım 4 — çekmece yapılandırma + port keşfi arayüzü.
// // Sınıf: Class B

// class MobileDrawerConfigView extends ConsumerWidget {
//   const MobileDrawerConfigView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(step4MobileNotifierProvider);
//     final notifier = ref.read(step4MobileNotifierProvider.notifier);
//     final layout = state.mobileLayout;

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(32),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SectionLabel(label: context.l10n.wizard_drawerCountLabel),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               MedCounter(
//                 value: layout.drawerCount,
//                 min: 1,
//                 max: 8,
//                 onDecrement: () => notifier.updateDrawerCount(layout.drawerCount - 1),
//                 onIncrement: () => notifier.updateDrawerCount(layout.drawerCount + 1),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 context.l10n.wizard_drawerCountRangeHint,
//                 style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: MedColors.text3),
//               ),
//             ],
//           ),
//           const SizedBox(height: 24),

//           // Tüm çekmeceler aynı yapıda toggle
//           _SameConfigToggle(
//             value: layout.sameConfig,
//             onChanged: (val) => notifier.toggleSameConfig(value: val),
//           ),
//           const SizedBox(height: 24),

//           // Çekmece listesi
//           for (final drawer in layout.sameConfig ? layout.drawers.take(1).toList() : layout.drawers)
//             _DrawerConfigCard(
//               drawer: drawer,
//               onConfigChanged: (rowColumns) => notifier.updateDrawerConfig(drawer.drawerIndex, rowColumns),
//             ),

//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }
// }

// class _SameConfigToggle extends StatelessWidget {
//   const _SameConfigToggle({required this.value, required this.onChanged});

//   final bool value;
//   final ValueChanged<bool> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => onChanged(!value),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//         decoration: BoxDecoration(
//           color: value ? MedColors.blueLight : MedColors.surface2,
//           border: Border.all(color: value ? MedColors.blue.withAlpha(102) : MedColors.border),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               width: 44,
//               height: 24,
//               decoration: BoxDecoration(
//                 color: value ? MedColors.blue : MedColors.border,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: AnimatedAlign(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 alignment: value ? Alignment.centerRight : Alignment.centerLeft,
//                 child: Container(
//                   width: 18,
//                   height: 18,
//                   margin: const EdgeInsets.symmetric(horizontal: 3),
//                   decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     context.l10n.wizard_sameConfigToggleLabel,
//                     style: TextStyle(
//                       fontFamily: MedFonts.sans,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: MedColors.text,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     value
//                         ? context.l10n.wizard_sameConfigToggleOnDesc
//                         : context.l10n.wizard_sameConfigToggleOffDesc,
//                     style: TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.text3),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _DrawerConfigCard extends StatefulWidget {
//   const _DrawerConfigCard({required this.drawer, required this.onConfigChanged});

//   final WizardDrawerConfig drawer;
//   final ValueChanged<List<int>> onConfigChanged;

//   @override
//   State<_DrawerConfigCard> createState() => _DrawerConfigCardState();
// }

// class _DrawerConfigCardState extends State<_DrawerConfigCard> {
//   bool _expanded = false;

//   @override
//   void initState() {
//     super.initState();
//     _expanded = widget.drawer.drawerIndex == 0;
//   }

//   void _updateRow(int rowIndex, int columns) {
//     final updated = widget.drawer.withRowColumns(rowIndex, columns);
//     widget.onConfigChanged(updated.rowColumns);
//   }

//   void _addRow() {
//     final updated = widget.drawer.withRowAdded();
//     widget.onConfigChanged(updated.rowColumns);
//   }

//   void _removeLastRow() {
//     if (widget.drawer.rowCount <= 1) return;
//     final updated = widget.drawer.withRowRemoved(widget.drawer.rowCount - 1);
//     widget.onConfigChanged(updated.rowColumns);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final drawer = widget.drawer;
//     final summary = context.l10n.wizard_drawerRowCellSummary(drawer.rowCount, drawer.totalCells);

//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: MedColors.surface,
//         border: Border.all(color: _expanded ? MedColors.blue.withAlpha(50) : MedColors.border),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () => setState(() => _expanded = !_expanded),
//             behavior: HitTestBehavior.opaque,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 28,
//                     height: 28,
//                     decoration: BoxDecoration(
//                       color: _expanded ? MedColors.blue : MedColors.surface2,
//                       shape: BoxShape.circle,
//                       border: Border.all(color: _expanded ? MedColors.blue : MedColors.border),
//                     ),
//                     alignment: Alignment.center,
//                     child: Text(
//                       '${drawer.drawerIndex + 1}',
//                       style: TextStyle(
//                         fontFamily: MedFonts.mono,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         color: _expanded ? Colors.white : MedColors.text3,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           context.l10n.wizard_summaryLabelDrawerIndexed(drawer.drawerIndex + 1),
//                           style: TextStyle(
//                             fontFamily: MedFonts.sans,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600,
//                             color: MedColors.text,
//                           ),
//                         ),
//                         if (drawer.portNumber != null)
//                           Text(
//                             context.l10n.wizard_drawerPortLabel(drawer.portNumber!),
//                             style: MedTextStyles.monoXs(color: MedColors.text3),
//                           ),
//                       ],
//                     ),
//                   ),
//                   Text(
//                     summary,
//                     style: TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
//                   ),
//                   const SizedBox(width: 8),
//                   Icon(
//                     _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
//                     size: 20,
//                     color: MedColors.text3,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (_expanded) ...[
//             const Divider(height: 1, thickness: 1, color: MedColors.border2),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//               child: Column(
//                 children: [
//                   for (int i = 0; i < drawer.rowCount; i++)
//                     _RowConfigItem(
//                       rowIndex: i,
//                       columns: drawer.rowColumns[i],
//                       maxColumns: 8,
//                       onChanged: (v) => _updateRow(i, v),
//                     ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       _ActionChip(
//                         icon: Icons.add_rounded,
//                         label: context.l10n.wizard_addRowButton,
//                         enabled: drawer.rowCount < 8,
//                         onTap: _addRow,
//                       ),
//                       const SizedBox(width: 8),
//                       _ActionChip(
//                         icon: Icons.remove_rounded,
//                         label: context.l10n.wizard_removeLastRowButton,
//                         enabled: drawer.rowCount > 1,
//                         danger: true,
//                         onTap: _removeLastRow,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }

// class _RowConfigItem extends StatelessWidget {
//   const _RowConfigItem({
//     required this.rowIndex,
//     required this.columns,
//     required this.maxColumns,
//     required this.onChanged,
//   });

//   final int rowIndex;
//   final int columns;
//   final int maxColumns;
//   final ValueChanged<int> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 56,
//             child: Text(
//               context.l10n.wizard_rowLabel(rowIndex + 1),
//               style: TextStyle(
//                 fontFamily: MedFonts.mono,
//                 fontSize: 9,
//                 fontWeight: FontWeight.w600,
//                 letterSpacing: 0.6,
//                 color: MedColors.text3,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           MedCounter(
//             value: columns,
//             min: 1,
//             max: maxColumns,
//             onDecrement: () => onChanged(columns - 1),
//             onIncrement: () => onChanged(columns + 1),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: _RowBarPreview(columns: columns, maxColumns: maxColumns),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _RowBarPreview extends StatelessWidget {
//   const _RowBarPreview({required this.columns, required this.maxColumns});

//   final int columns;
//   final int maxColumns;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 20,
//       child: Row(
//         children: List.generate(maxColumns, (i) {
//           final active = i < columns;
//           return Expanded(
//             child: Container(
//               margin: const EdgeInsets.symmetric(horizontal: 1.5),
//               decoration: BoxDecoration(
//                 color: active ? MedColors.blue.withAlpha(51) : MedColors.surface2,
//                 border: Border.all(color: active ? MedColors.blue.withAlpha(102) : MedColors.border2),
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }

// class _ActionChip extends StatelessWidget {
//   const _ActionChip({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//     this.enabled = true,
//     this.danger = false,
//     // ignore: unused_element_parameter
//     this.primary = false,
//   });

//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   final bool enabled;
//   final bool danger;
//   final bool primary;

//   @override
//   Widget build(BuildContext context) {
//     final color = !enabled
//         ? MedColors.text4
//         : danger
//         ? MedColors.red
//         : primary
//         ? Colors.white
//         : MedColors.blue;
//     final bgColor = !enabled
//         ? MedColors.surface2
//         : danger
//         ? MedColors.red.withAlpha(15)
//         : primary
//         ? MedColors.blue
//         : MedColors.blueLight;
//     final borderColor = !enabled
//         ? MedColors.border
//         : danger
//         ? MedColors.red.withAlpha(64)
//         : primary
//         ? MedColors.blue
//         : MedColors.blue.withAlpha(77);

//     return GestureDetector(
//       onTap: enabled ? onTap : null,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 120),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: bgColor,
//           border: Border.all(color: borderColor),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 14, color: color),
//             const SizedBox(width: 5),
//             Text(
//               label,
//               style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, fontWeight: FontWeight.w500, color: color),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
