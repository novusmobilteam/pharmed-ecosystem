import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';
import '../notifier/login_notifier.dart';

void showLoginView(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => LoginView(),
  );
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginNotifier>(
      create: (context) => LoginNotifier(
        loginUseCase: context.read(),
        getCurrentUserUseCase: context.read(),
        authStorageNotifier: context.read(),
      ),
      child: const _LoginContent(),
    );
  }
}

class _LoginContent extends StatefulWidget {
  const _LoginContent();

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginNotifier? _notifier;

  void _setupCallbacks(BuildContext context, LoginNotifier vm) {
    vm.setCallbacks(
      key: LoginNotifier.loginOperation,
      onError: (message) {
        MessageUtils.showErrorSnackbar(context, message ?? 'Giriş başarısız.');
      },
      onSuccess: (_) {
        // İşlem başarılı olduğunda dialoğu kapatıyoruz.
        // GoRouter (refreshListenable) sayesinde yönlendirme otomatik gerçekleşecek.
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginNotifier>(
      builder: (context, vm, _) {
        // ViewModel değiştiğinde callback'leri bir kez bağla
        if (_notifier != vm) {
          _notifier = vm;
          _setupCallbacks(context, vm);
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            // Klavye açıldığında taşmayı önlemek için
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LoginCard(
                  formKey: _formKey,
                  notifier: vm,
                ),
                const SizedBox(height: 24),
                //_VersionInfo(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginNotifier notifier;

  const _LoginCard({required this.formKey, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tekrar Hoş Geldiniz',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // E-Posta Alanı
            TextFormField(
              decoration: InputDecoration(
                labelText: 'E-Posta',
                prefixIcon: Icon(PhosphorIcons.envelopeSimple()),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: notifier.onEmailChanged,
              validator: (val) => (val == null || val.isEmpty) ? 'E-posta adresi gerekli' : null,
            ),
            const SizedBox(height: 16),

            // Şifre Alanı
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Şifre',
                prefixIcon: Icon(PhosphorIcons.lockKey()),
                suffixIcon: IconButton(
                  icon: Icon(notifier.obscurePassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash()),
                  onPressed: notifier.toggleObscurePassword,
                ),
              ),
              obscureText: notifier.obscurePassword,
              onChanged: notifier.onPasswordChanged,
              validator: (value) => Validators.cannotBlankValidator(value),
            ),

            const SizedBox(height: 22),

            // Giriş Butonu
            _LoginButton(
              isLoading: notifier.isLoading(LoginNotifier.loginOperation),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  notifier.login();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;

  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator.adaptive());
    } else {
      return SizedBox(
        height: 45,
        child: PharmedButton(
          onPressed: onPressed,
          label: 'Giriş Yap',
        ),
      );
    }
  }
}
