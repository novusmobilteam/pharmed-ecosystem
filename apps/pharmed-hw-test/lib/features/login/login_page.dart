import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../core/env.dart';
import '../../core/providers.dart';
import '../../core/report.dart';

/// Kullanıcı kendi hesabıyla giriş yapar; token çekmece tanımlarını ve
/// istasyon/kabin bilgisini servisten çekmek için gereklidir.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Kullanıcı adı ve şifre girin.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await LoginUseCase(ref.read(authRepositoryProvider))(LoginParams(email: email, password: password));
    if (!mounted) return;

    result.when(
      ok: (token) {
        ref.read(tokenHolderProvider).setToken(token.accessToken);
        ref.read(testReportProvider).add('Giriş: ${token.user.fullName}', StepResult.info);
        ref.read(sessionProvider.notifier).setUser(token.user);
      },
      error: (e) => setState(() {
        _busy = false;
        _error = e.message;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.memory, size: 40, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('PharMed Donanım Testi', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    'Sürüm ${AppEnv.version} · ${AppEnv.instance.flavor}',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    decoration: const InputDecoration(labelText: 'Kullanıcı adı / e-posta', border: OutlineInputBorder()),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                    onSubmitted: (_) => _login(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _login,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: _busy
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Giriş yap'),
                    ),
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
