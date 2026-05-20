import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/auth_notifier.dart';
import '../notifier/auth_state.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authNotifierProvider) is AuthLoading;

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: Center(
        child: LoginModal(
          isLoading: isLoading,
          onLogin: (email, password, onError) async {
            await ref.read(authNotifierProvider.notifier).login(email: email, password: password, onError: onError);
          },
        ),
      ),
    );
  }
}
