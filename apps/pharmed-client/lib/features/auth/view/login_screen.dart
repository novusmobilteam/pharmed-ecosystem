import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:provider/provider.dart';

import '../../settings/notifier/settings_notifier.dart';
import '../notifier/auth_notifier.dart';
import '../notifier/auth_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final settings = context.watch<SettingsNotifier>();
    final isLoading = auth.state is AuthLoading;

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Center(
        child: LoginModal(
          isLoading: isLoading,
          onLogin: (email, password, onError) async {
            await auth.login(email: email, password: password, onError: onError);
          },
          onLoginWithBadge: (cardData, onError) async {
            await auth.loginWithBadge(cardData: cardData, onError: onError);
          },
          currentLanguage: settings.language,
          onLanguageChanged: settings.setLanguage,
        ),
      ),
    );
  }
}
