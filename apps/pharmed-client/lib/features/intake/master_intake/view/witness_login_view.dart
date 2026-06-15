// [SWREQ-CLI-MINTAKE-008] [IEC 62304 §5.5]
// Şahit doğrulama dialog'u (client / Riverpod sürümü).
//
// MedDialog kabuğu kullanır (tasarım dili). Provider yerine Riverpod,
// Theme.of yerine MedColors/MedTextStyles token'ları.
// Alım ve (ileride) fire/imha işlemlerinde ortak kullanılabilir.
//
// Kurallar:
//   - Aktif (login) kullanıcı şahit OLAMAZ; girerse hata gösterilir.
//   - Başarılı login → onWitnessLoggedIn(user); notifier uygun diğer kalemlere yayar.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:pharmed_utils/pharmed_utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/providers.dart';
import '../../../auth/notifier/auth_notifier.dart';

class WitnessLoginView extends ConsumerStatefulWidget {
  const WitnessLoginView({super.key, required this.item, required this.onWitnessLoggedIn});

  final IntakeItem item;
  final ValueChanged<User> onWitnessLoggedIn;

  @override
  ConsumerState<WitnessLoginView> createState() => _WitnessLoginViewState();
}

class _WitnessLoginViewState extends ConsumerState<WitnessLoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final mac = await DeviceInfo.getMacAddress();

    final result = await ref
        .read(loginWitnessUseCaseProvider)
        .call(
          WitnessUserLoginParams(
            email: _usernameController.text.trim(),
            password: _passwordController.text,
            macAddress: mac,
          ),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      ok: (user) {
        if (user == null) return;

        // Aktif (login) kullanıcı kendi işlemine şahit olamaz.
        final currentUserId = ref.read(authNotifierProvider.notifier).currentUser?.id;
        if (currentUserId != null && user.id == currentUserId) {
          MessageUtils.showErrorSnackbar(context, 'İşlemi yapan kullanıcı aynı işleme şahit olamaz.');
          return;
        }

        widget.onWitnessLoggedIn(user);
        MessageUtils.showSuccessSnackbar(context, '${user.fullName} şahit olarak onaylandı.');
        Navigator.of(context).pop(true);
      },
      error: (e) => MessageUtils.showErrorSnackbar(context, e.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final witnesses = widget.item.witnesses;

    return MedDialog(
      title: 'Şahit Doğrulaması',
      subtitle: widget.item.medicine?.name,
      icon: PhosphorIcons.shieldCheck(),
      width: 520,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            if (witnesses.isEmpty)
              const _AnyoneCanWitnessInfo()
            else
              _WitnessChips(witnesses: witnesses, selected: widget.item.witness),
            MedTextInputField(
              controller: _usernameController,
              label: 'Şahit Kullanıcı Adı',
              prefixIcon: Icon(PhosphorIcons.user(), color: MedColors.text3),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı giriniz' : null,
              onChanged: (_) {},
            ),
            MedTextInputField(
              controller: _passwordController,
              label: 'Şahit Şifresi',
              obscureText: true,
              prefixIcon: Icon(PhosphorIcons.lock(), color: MedColors.text3),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Şifre giriniz' : null,
              onChanged: (_) {},
            ),
            SizedBox(
              width: double.infinity,
              child: MedButton(label: 'Şahitliği Onayla', isLoading: _isLoading, onPressed: _handleLogin),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnyoneCanWitnessInfo extends StatelessWidget {
  const _AnyoneCanWitnessInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: MedSpacing.insetMd,
      decoration: BoxDecoration(color: MedColors.surface2, borderRadius: MedRadius.mdAll),
      child: Row(
        spacing: 10,
        children: [
          Icon(PhosphorIcons.users(), size: 16, color: MedColors.blue),
          Expanded(
            child: Text(
              'Bu işlem için herhangi bir personel şahitlik yapabilir.',
              style: MedTextStyles.bodySm(color: MedColors.text3),
            ),
          ),
        ],
      ),
    );
  }
}

class _WitnessChips extends StatelessWidget {
  const _WitnessChips({required this.witnesses, required this.selected});

  final List<User> witnesses;
  final User? selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text('Yetkili Şahitler (${witnesses.length})', style: MedTextStyles.bodySm(color: MedColors.text3)),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: witnesses.map((u) {
            final isSel = selected?.id == u.id;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? MedColors.greenLight : MedColors.surface2,
                border: Border.all(color: isSel ? MedColors.green : MedColors.border),
                borderRadius: MedRadius.smAll,
              ),
              child: Text(u.fullName, style: MedTextStyles.bodySm(color: isSel ? MedColors.green : MedColors.text2)),
            );
          }).toList(),
        ),
      ],
    );
  }
}
