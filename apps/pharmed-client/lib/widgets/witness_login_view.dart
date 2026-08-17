// // [SWREQ-CLI-WITNESS-001] [IEC 62304 §5.5]
// // Şahit doğrulama dialog'u — GENEL, herhangi bir feature'ın item tipine
// // bağlı değil. Alım ve fire/imha (ileride başka işlemler de) bunu ortak
// // kullanır. Önceki sürüm IntakeItem'a sıkı bağlıydı (widget.item.witnesses/
// // .medicine/.witness) — bu sürüm sadece ham witnesses/selectedWitness/
// // subtitle alır, çağıran ekran kendi domain modelinden bunları çözer.
// //
// // Kurallar:
// //   - Aktif (login) kullanıcı şahit OLAMAZ; girerse hata gösterilir.
// //   - Başarılı login → onWitnessLoggedIn(user); yayılma mantığı (diğer
// //     seçili kalemlere otomatik atama) ÇAĞIRAN notifier'ın sorumluluğu.
// //
// // Sınıf: Class B

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';
// import 'package:pharmed_utils/pharmed_utils.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// import '../core/providers/providers.dart';
// import '../features/auth/auth.dart';

// class WitnessLoginView extends ConsumerStatefulWidget {
//   const WitnessLoginView({
//     super.key,
//     required this.witnesses,
//     required this.selectedWitness,
//     required this.onWitnessLoggedIn,
//     this.subtitle,
//   });

//   /// Bu kalem için yetkili şahit listesi. Boşsa "herkes şahit olabilir" bilgisi gösterilir.
//   final List<User> witnesses;

//   /// Halihazırda atanmış şahit (chip vurgusu için).
//   final User? selectedWitness;

//   /// Dialog başlığının altında gösterilen bağlam (örn. ilaç adı) — opsiyonel.
//   final String? subtitle;

//   final ValueChanged<User> onWitnessLoggedIn;

//   @override
//   ConsumerState<WitnessLoginView> createState() => _WitnessLoginViewState();
// }

// class _WitnessLoginViewState extends ConsumerState<WitnessLoginView> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleLogin() async {
//     if (!_formKey.currentState!.validate()) return;
//     setState(() => _isLoading = true);

//     final mac = await DeviceInfo.getMacAddress();

//     final result = await ref
//         .read(loginWitnessUseCaseProvider)
//         .call(
//           WitnessUserLoginParams(
//             email: _usernameController.text.trim(),
//             password: _passwordController.text,
//             macAddress: mac,
//           ),
//         );

//     if (!mounted) return;
//     setState(() => _isLoading = false);

//     result.when(
//       ok: (user) {
//         if (user == null) return;

//         final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;
//         if (currentUserId != null && user.id == currentUserId) {
//           MessageUtils.showErrorSnackbar(context, context.l10n.witnessDialog_error_selfWitness);
//           return;
//         }

//         widget.onWitnessLoggedIn(user);
//         MessageUtils.showSuccessSnackbar(context, context.l10n.witnessDialog_success_confirmed(user.fullName));
//         Navigator.of(context).pop(true);
//       },
//       error: (e) => MessageUtils.showErrorSnackbar(context, e.message),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MedDialog(
//       title: context.l10n.witnessDialog_title,
//       subtitle: widget.subtitle,
//       icon: PhosphorIcons.shieldCheck(),
//       width: 520,
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           spacing: 16,
//           children: [
//             if (widget.witnesses.isEmpty)
//               const _AnyoneCanWitnessInfo()
//             else
//               _WitnessChips(witnesses: widget.witnesses, selected: widget.selectedWitness),
//             MedTextInputField(
//               controller: _usernameController,
//               label: context.l10n.witnessDialog_usernameLabel,
//               prefixIcon: Icon(PhosphorIcons.user(), color: MedColors.text3),
//               validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.witnessDialog_usernameRequired : null,
//               onChanged: (_) {},
//             ),
//             MedTextInputField(
//               controller: _passwordController,
//               label: context.l10n.witnessDialog_passwordLabel,
//               obscureText: true,
//               prefixIcon: Icon(PhosphorIcons.lock(), color: MedColors.text3),
//               validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.witnessDialog_passwordRequired : null,
//               onChanged: (_) {},
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: MedButton(
//                 label: context.l10n.witnessDialog_confirmButton,
//                 isLoading: _isLoading,
//                 onPressed: _handleLogin,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _AnyoneCanWitnessInfo extends StatelessWidget {
//   const _AnyoneCanWitnessInfo();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: MedSpacing.insetMd,
//       decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
//       child: Row(
//         spacing: 10,
//         children: [
//           Icon(PhosphorIcons.users(), size: 16, color: MedColors.blue),
//           Expanded(
//             child: Text(context.l10n.witnessDialog_anyoneInfo, style: MedTextStyles.bodySm(color: MedColors.text3)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _WitnessChips extends StatelessWidget {
//   const _WitnessChips({required this.witnesses, required this.selected});

//   final List<User> witnesses;
//   final User? selected;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       spacing: 8,
//       children: [
//         Text(
//           context.l10n.witnessDialog_authorizedWitnesses(witnesses.length),
//           style: MedTextStyles.bodySm(color: MedColors.text3),
//         ),
//         Wrap(
//           spacing: 6,
//           runSpacing: 6,
//           children: witnesses.map((u) {
//             final isSel = selected?.id == u.id;
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: isSel ? MedColors.greenLight : MedColors.surface2,
//                 border: Border.all(color: isSel ? MedColors.green : MedColors.border),
//                 borderRadius: MedRadius.smAll,
//               ),
//               child: Text(u.fullName, style: MedTextStyles.bodySm(color: isSel ? MedColors.green : MedColors.text2)),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

// class WitnessInlineRow extends StatelessWidget {
//   const WitnessInlineRow({super.key, required this.witness, required this.onTap});

//   final User? witness;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     final hasWitness = witness != null;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: MedRadius.mdAll,
//       child: Container(
//         padding: MedSpacing.insetMd,
//         decoration: BoxDecoration(
//           color: hasWitness ? MedColors.greenLight : MedColors.amberLight,
//           borderRadius: MedRadius.mdAll,
//           border: Border.all(color: hasWitness ? MedColors.green : MedColors.amber),
//         ),
//         child: Row(
//           spacing: 8,
//           children: [
//             Expanded(
//               child: Text(
//                 hasWitness
//                     ? context.l10n.witnessDialog_assignedLabel(witness!.fullName)
//                     : context.l10n.witnessDialog_requiredHint,
//                 style: MedTextStyles.bodyMd(color: hasWitness ? MedColors.green : MedColors.amber),
//               ),
//             ),
//             if (!hasWitness) Icon(PhosphorIcons.caretRight(), size: 14, color: MedColors.amber),
//           ],
//         ),
//       ),
//     );
//   }
// }
