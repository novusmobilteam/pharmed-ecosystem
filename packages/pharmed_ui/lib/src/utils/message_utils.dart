import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum MessageType { success, error, warning, info }

enum ConfirmAction { delete, exit, save, discard, custom }

class MessageUtils {
  // === TOAST INITIALIZATION ===

  static void initFToast(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
  }

  // === CONFIRM DIALOG METHODS ===

  static void showConfirmDialog({
    required BuildContext context,
    required ConfirmAction action,
    required VoidCallback onConfirm,
    String? customTitle,
    String? customMessage,
    String confirmButtonText = 'Onayla',
    String cancelButtonText = 'Vazgeç',
    Color? color,
    IconData? iconData,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dialogContent = _getConfirmDialogContent(action, context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 340, maxWidth: 420),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24.0), // Daha yuvarlak köşeler
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ICON AREA (Modern Circle) ---
              Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  color: (color ?? dialogContent.backgroundColor).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(iconData ?? dialogContent.icon, color: color ?? dialogContent.backgroundColor, size: 32),
                ),
              ),
              const SizedBox(height: 24),

              // --- TITLE ---
              Text(
                customTitle ?? dialogContent.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5, // Modern font spacing
                ),
              ),
              const SizedBox(height: 12),

              // --- MESSAGE ---
              Text(
                customMessage ?? dialogContent.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5, // Daha iyi okunabilirlik
                ),
              ),
              const SizedBox(height: 32),

              // --- BUTTONS ---
              // Row(
              //   children: [
              //     Expanded(
              //       child: PharmedButton(
              //         onPressed: () => context.pop(),
              //         label: cancelButtonText,
              //         backgroundColor: colorScheme.surfaceContainer,
              //         foregroundColor: colorScheme.onSurface,
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: PharmedButton(
              //         onPressed: () {
              //           context.pop();
              //           onConfirm();
              //         },
              //         label: confirmButtonText,
              //         backgroundColor: dialogContent.buttonColor,
              //         foregroundColor: dialogContent.buttonTextColor,
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  // === SHORTCUT METHODS FOR COMMON ACTIONS ===

  static void showConfirmDeleteDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    String? itemName,
  }) {
    showConfirmDialog(
      context: context,
      action: ConfirmAction.delete,
      onConfirm: onConfirm,
      confirmButtonText: 'Sil',
      customMessage: itemName != null
          ? '"$itemName" öğesini silmek istediğinizden emin misiniz?\nBu işlem geri alınamaz.'
          : null,
    );
  }

  static void showConfirmExitDialog({
    required BuildContext context,
    required VoidCallback onConfirm,
    bool hasUnsavedChanges = true,
  }) {
    showConfirmDialog(
      context: context,
      action: ConfirmAction.exit,
      onConfirm: onConfirm,
      confirmButtonText: 'Çıkış Yap',
      customMessage: hasUnsavedChanges
          ? 'Kaydetmediğiniz değişiklikler var. Çıkış yaparsanız bu değişiklikler silinecektir.'
          : 'Sayfadan çıkmak istediğinizden emin misiniz?',
    );
  }

  static void showConfirmSaveDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(context: context, action: ConfirmAction.save, onConfirm: onConfirm, confirmButtonText: 'Kaydet');
  }

  static void showConfirmDiscardDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(
      context: context,
      action: ConfirmAction.discard,
      onConfirm: onConfirm,
      confirmButtonText: 'Evet, İptal Et',
    );
  }

  static void showConfirmLogoutDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(
      context: context,
      customTitle: 'Çıkış Yap',
      customMessage: 'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
      iconData: PhosphorIcons.signOut(),
      action: ConfirmAction.delete,
      onConfirm: onConfirm,
      confirmButtonText: 'Çıkış Yap',
    );
  }

  // === SNACKBAR / TOAST MESSAGE METHODS ===

  static void showSnackbar({
    required BuildContext context,
    required String message,
    required MessageType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final themeData = _getThemeDataByType(type, context);
    final icon = _getIconByType(type);

    _showCustomToast(
      context: context,
      message: message,
      icon: icon,
      backgroundColor: themeData.backgroundColor,
      textColor: themeData.textColor,
      iconColor: themeData.iconColor,
      duration: duration,
    );
  }

  static void showSuccessSnackbar(BuildContext context, String? message) {
    showSnackbar(context: context, message: message ?? 'İşleminiz başarıyla tamamlandı.', type: MessageType.success);
  }

  static void showErrorSnackbar(BuildContext context, String? message) {
    showSnackbar(
      context: context,
      message: message ?? 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.',
      type: MessageType.error,
    );
  }

  static void showWarningSnackbar(BuildContext context, String message) {
    showSnackbar(context: context, message: message, type: MessageType.warning);
  }

  static void showInfoSnackbar(BuildContext context, String message) {
    showSnackbar(context: context, message: message, type: MessageType.info);
  }

  // === DIALOG MESSAGE METHODS ===

  static void showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (context) => _CustomMessageDialog(
        message: message ?? 'Bir hata oluştu. Lütfen daha sonra tekrar deneyiniz.',
        type: MessageType.error,
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (context) =>
          _CustomMessageDialog(message: message ?? 'İşleminiz başarıyla tamamlandı.', type: MessageType.success),
    );
  }

  static void showWarningDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (context) => _CustomMessageDialog(message: message ?? 'Uyarı!', type: MessageType.warning),
    );
  }

  // === PRIVATE HELPERS ===

  static void _showCustomToast({
    required BuildContext context,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color iconColor,
    required Duration duration,
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    Widget toast = Container(
      margin: const EdgeInsets.only(bottom: 50.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0), // Daha modern radius
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],

        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
      fadeDuration: const Duration(milliseconds: 300),
    );
  }

  // Renkleri Temadan Türeten Helper
  static _DialogThemeData _getThemeDataByType(MessageType type, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (type) {
      case MessageType.success:
        return _DialogThemeData(
          // Koyu yeşil tonları modern UI'da daha profesyonel durur
          backgroundColor: const Color(0xFF2E7D32), // Green 800
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case MessageType.error:
        return _DialogThemeData(
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          iconColor: colorScheme.onError,
        );
      case MessageType.warning:
        return _DialogThemeData(
          backgroundColor: const Color(0xFFEF6C00), // Orange 800
          textColor: Colors.white,
          iconColor: Colors.white,
        );
      case MessageType.info:
        return _DialogThemeData(
          backgroundColor: colorScheme.primary, // Marka rengi
          textColor: colorScheme.onPrimary,
          iconColor: colorScheme.onPrimary,
        );
    }
  }

  static IconData _getIconByType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
      case MessageType.error:
        return PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
      case MessageType.warning:
        return PhosphorIcons.warning(PhosphorIconsStyle.fill);
      case MessageType.info:
        return PhosphorIcons.info(PhosphorIconsStyle.fill);
    }
  }

  static _ConfirmDialogContent _getConfirmDialogContent(ConfirmAction action, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (action) {
      case ConfirmAction.delete:
        return _ConfirmDialogContent(
          title: 'Silme İşlemi',
          message: 'Bu öğeyi silmek istediğinizden emin misiniz?',
          icon: PhosphorIcons.trash(),
          backgroundColor: colorScheme.error,
          buttonColor: colorScheme.error,
          buttonTextColor: colorScheme.onError,
        );
      case ConfirmAction.exit:
        return _ConfirmDialogContent(
          title: 'Çıkış',
          message: 'Kaydetmediğiniz değişiklikler kaybolabilir.',
          icon: PhosphorIcons.signOut(),
          backgroundColor: const Color(0xFFEF6C00),
          buttonColor: const Color(0xFFEF6C00),
          buttonTextColor: Colors.white,
        );
      case ConfirmAction.save:
        return _ConfirmDialogContent(
          title: 'Kaydet',
          message: 'Değişiklikleri kaydetmek istiyor musunuz?',
          icon: PhosphorIcons.floppyDisk(),
          backgroundColor: const Color(0xFF1565C0), // Blue 800
          buttonColor: const Color(0xFF1565C0),
          buttonTextColor: Colors.white,
        );
      case ConfirmAction.discard:
        return _ConfirmDialogContent(
          title: 'İptal Et',
          message: 'Yapılan değişiklikler geri alınacak.',
          icon: PhosphorIcons.xCircle(),
          backgroundColor: colorScheme.secondary,
          buttonColor: colorScheme.secondary,
          buttonTextColor: colorScheme.onSecondary,
        );
      case ConfirmAction.custom:
        return _ConfirmDialogContent(
          title: 'Onay',
          message: 'İşlemi onaylıyor musunuz?',
          icon: PhosphorIcons.question(),
          backgroundColor: colorScheme.primary,
          buttonColor: colorScheme.primary,
          buttonTextColor: colorScheme.onPrimary,
        );
    }
  }
}

// === SUPPORTING CLASSES ===

class _DialogThemeData {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  _DialogThemeData({required this.backgroundColor, required this.textColor, required this.iconColor});
}

class _ConfirmDialogContent {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color buttonColor;
  final Color buttonTextColor;

  _ConfirmDialogContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.buttonColor,
    required this.buttonTextColor,
  });
}

class _CustomMessageDialog extends StatelessWidget {
  final String message;
  final MessageType type;

  const _CustomMessageDialog({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeData = MessageUtils._getThemeDataByType(type, context);
    final icon = MessageUtils._getIconByType(type);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 380),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24.0),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Icon Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeData.backgroundColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: themeData.backgroundColor, size: 40),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Button
            // SizedBox(
            //   width: double.infinity,
            //   child: PharmedButton(
            //     onPressed: () => context.pop(),
            //     label: 'Tamam',
            //     backgroundColor: themeData.backgroundColor,
            //     foregroundColor: themeData.textColor,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
