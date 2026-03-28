import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/auth/auth.dart';
import 'main.dart';

class SessionTimeoutManager extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const SessionTimeoutManager({
    super.key,
    required this.child,
    required this.duration,
  });

  @override
  State<SessionTimeoutManager> createState() => _SessionTimeoutManagerState();
}

class _SessionTimeoutManagerState extends State<SessionTimeoutManager> {
  Timer? _timer;
  final FocusNode _trapFocusNode = FocusNode();
  bool _isTextFieldFocused = false;

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _trapFocusNode.requestFocus();
      }
    });

    // Focus değişikliklerini dinle
    FocusManager.instance.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _trapFocusNode.dispose();
    FocusManager.instance.removeListener(_handleFocusChange);
    super.dispose();
  }

  void _handleFocusChange() {
    final primaryFocus = FocusManager.instance.primaryFocus;

    // TextField focus'u kontrolü
    if (primaryFocus != null && primaryFocus.context != null) {
      final widget = primaryFocus.context!.widget;
      _isTextFieldFocused = widget is EditableText ||
          primaryFocus.context!.findAncestorWidgetOfExactType<TextField>() != null ||
          primaryFocus.context!.findAncestorWidgetOfExactType<TextFormField>() != null;
    } else {
      _isTextFieldFocused = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(widget.duration, _handleTimeout);
  }

  void _onUserInteraction() {
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: RawKeyboardListener(
        focusNode: _trapFocusNode,
        onKey: (_) {}, // Klavye event'lerini sessizce yakala
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapDown: (_) => _onUserInteraction(),
          onPanDown: (_) => _onUserInteraction(),
          onTap: () {
            // TextField focus'u yoksa klavyeyi kapat
            if (!_isTextFieldFocused) {
              _closeKeyboard();
            }
          },
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  void _closeKeyboard() {
    Future.microtask(() {
      if (mounted) {
        // Mevcut focus'u kontrol et
        final currentFocus = FocusManager.instance.primaryFocus;

        // Eğer focus bir TextField'da değilse kapat
        if (currentFocus != null && currentFocus.context != null) {
          final widget = currentFocus.context!.widget;
          if (widget is! EditableText) {
            currentFocus.unfocus();
            _trapFocusNode.requestFocus();
          }
        } else {
          _trapFocusNode.requestFocus();
        }
      }
    });
  }

  void _handleTimeout() {
    final context = navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    // Timeout'ta klavyeyi kapat
    _closeKeyboard();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text("Oturum Zaman Aşımı"),
          content: const Text("Uzun süre işlem yapmadığınız için ekran kilitlendi."),
          actions: [
            TextButton(
              onPressed: () {
                context.read<AuthStorageNotifier>().clearAuth();
                _startTimer();
                Future.delayed(Duration.zero, () {
                  if (mounted) {
                    _trapFocusNode.requestFocus();
                  }
                });
              },
              child: const Text("Çıkış Yap"),
            )
          ],
        ),
      ),
    );
  }
}
