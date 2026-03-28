import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../../../user/user.dart';
import '../../domain/entity/cabin_operation_item.dart';
import '../notifier/witness_notifier.dart';

/// Şahit doğrulama dialog'u.
/// Alım ve fire/imha işlemlerinde ortak kullanılır.
/// medicine_management/presentation/view/ altında yaşar.
class WitnessLoginView extends StatefulWidget {
  const WitnessLoginView({
    super.key,
    required this.item,
    required this.onWitnessLoggedIn,
  });

  final CabinOperationItem item;
  final Function(User user) onWitnessLoggedIn;

  @override
  State<WitnessLoginView> createState() => _WitnessLoginViewState();
}

class _WitnessLoginViewState extends State<WitnessLoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WitnessNotifier(
        item: widget.item,
        loginUseCase: context.read(),
        authPersistence: context.read(),
      ),
      child: Consumer<WitnessNotifier>(
        builder: (context, notifier, _) {
          return CustomDialog(
            title: 'Şahit Doğrulaması',
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WitnessListSection(
                      item: widget.item,
                      witnesses: widget.item.witnesses,
                    ),
                    const SizedBox(height: 20),
                    _WitnessLoginForm(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                    ),
                    const SizedBox(height: 24),
                    _ConfirmButton(
                      isLoading: notifier.isLoading(notifier.loginOp),
                      onPressed: () => _handleLogin(context, notifier),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogin(BuildContext context, WitnessNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    await notifier.loginWitness(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      onSuccess: (user) {
        widget.onWitnessLoggedIn(user);
        MessageUtils.showSuccessSnackbar(
          context,
          '${user.fullName} şahit olarak onaylandı.',
        );
        context.pop(true);
      },
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
    );
  }
}

// =============================================================================
// _WitnessListSection
// =============================================================================

class _WitnessListSection extends StatelessWidget {
  const _WitnessListSection({
    required this.item,
    required this.witnesses,
  });

  final CabinOperationItem item;
  final List<User> witnesses;

  @override
  Widget build(BuildContext context) {
    if (witnesses.isEmpty) return const _AnyoneCanWitnessInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WitnessListHeader(count: witnesses.length),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: witnesses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => _WitnessCard(
              user: witnesses[index],
              colorIndex: index,
              // witness artık CabinOperationItem.witness üzerinden geliyor
              isSelected: item.witness?.id == witnesses[index].id,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// _WitnessListHeader
// =============================================================================

class _WitnessListHeader extends StatelessWidget {
  const _WitnessListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            PhosphorIcons.shieldCheck(),
            size: 17,
            color: const Color(0xFF2E7D32),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Yetkili Şahitler',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A2B1A),
            letterSpacing: 0.1,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count kişi',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// _WitnessCard
// =============================================================================

class _WitnessCard extends StatelessWidget {
  const _WitnessCard({
    required this.user,
    required this.colorIndex,
    required this.isSelected,
  });

  final User user;
  final int colorIndex;
  final bool isSelected;

  static const _colorPalette = [
    [Color(0xFFE3F2FD), Color(0xFF1565C0)],
    [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
    [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
    [Color(0xFFFFF3E0), Color(0xFFE65100)],
    [Color(0xFFE0F7FA), Color(0xFF00695C)],
  ];

  @override
  Widget build(BuildContext context) {
    final colorPair = _colorPalette[colorIndex % _colorPalette.length];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 128,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? colorPair[0] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? colorPair[1].withValues(alpha: 0.6) : const Color(0xFFE5E7EB),
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected ? colorPair[1].withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.04),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: colorPair[0],
                child: Text(
                  user.fullName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorPair[1],
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorPair[1],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(Icons.check, size: 8, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? colorPair[1] : const Color(0xFF111827),
                  ),
                ),
                if (user.fullName.contains(' '))
                  Text(
                    user.fullName.split(' ').skip(1).join(' '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? colorPair[1].withValues(alpha: 0.7) : const Color(0xFF6B7280),
                    ),
                  ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'Seçili Şahit',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: colorPair[1],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _AnyoneCanWitnessInfo
// =============================================================================

class _AnyoneCanWitnessInfo extends StatelessWidget {
  const _AnyoneCanWitnessInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              PhosphorIcons.users(),
              size: 16,
              color: const Color(0xFF4B6CB7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bu işlem için herhangi bir personel şahitlik yapabilir.',
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _WitnessLoginForm
// =============================================================================

class _WitnessLoginForm extends StatelessWidget {
  const _WitnessLoginForm({
    required this.usernameController,
    required this.passwordController,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Şahit Kullanıcı Adı',
            prefixIcon: Icon(PhosphorIcons.user()),
            border: const OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Kullanıcı adı giriniz' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Şahit Şifresi',
            prefixIcon: Icon(PhosphorIcons.lock()),
            border: const OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Şifre giriniz' : null,
        ),
      ],
    );
  }
}

// =============================================================================
// _ConfirmButton
// =============================================================================

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isLoading
          ? const Center(child: CircularProgressIndicator.adaptive())
          : PharmedButton(
              onPressed: onPressed,
              label: 'Şahitliği Onayla',
            ),
    );
  }
}
