import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:pharmed_ui/pharmed_ui.dart'; // MedButton buradan gelir

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
    VoidCallback? onCancel,
    String? customTitle,
    String? customMessage,
    String? confirmButtonText,
    String? cancelButtonText,
    Color? color,
    IconData? iconData,
    bool barrierDismissible = false,
  }) {
    final theme = Theme.of(context);
    final dialogContent = _getConfirmDialogContent(action, context);
    final resolvedConfirmButtonText = confirmButtonText ?? context.l10n.common_confirmButton;
    final resolvedCancelButtonText = cancelButtonText ?? context.l10n.common_dismissButton;

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(minWidth: 320, maxWidth: 400),
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: MedColors.surface,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: MedColors.border, width: 1),
            boxShadow: const [
              BoxShadow(color: Color(0x1F1E325A), blurRadius: 32, offset: Offset(0, 12)),
              BoxShadow(color: Color(0x0F1E325A), blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ICON AREA ---
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: color != null ? color.withValues(alpha: 0.1) : dialogContent.iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(iconData ?? dialogContent.icon, color: color ?? dialogContent.iconColor, size: 28),
                ),
              ),
              const SizedBox(height: 20),

              // --- TITLE ---
              Text(
                customTitle ?? dialogContent.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MedColors.text,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              // --- MESSAGE ---
              Text(
                customMessage ?? dialogContent.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: MedColors.text2, height: 1.55),
              ),
              const SizedBox(height: 24),

              // --- BUTTONS ---
              Row(
                children: [
                  Expanded(
                    child: MedButton(
                      label: resolvedCancelButtonText,
                      variant: MedButtonVariant.ghost,
                      size: MedButtonSize.sm,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MedButton(
                      label: resolvedConfirmButtonText,
                      variant: dialogContent.buttonVariant,
                      size: MedButtonSize.sm,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        onConfirm();
                      },
                    ),
                  ),
                ],
              ),
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
      confirmButtonText: context.l10n.common_deleteTooltip,
      customMessage: itemName != null ? context.l10n.dialog_deleteItemMessage(itemName) : null,
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
      confirmButtonText: context.l10n.dialog_exitConfirmButtonText,
      customMessage: hasUnsavedChanges
          ? context.l10n.dialog_exitConfirmMessage
          : context.l10n.dialog_exitConfirmMessageNoChanges,
    );
  }

  static void showConfirmSaveDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(
      context: context,
      action: ConfirmAction.save,
      onConfirm: onConfirm,
      confirmButtonText: context.l10n.common_saveButton,
    );
  }

  static void showConfirmDiscardDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(
      context: context,
      action: ConfirmAction.discard,
      onConfirm: onConfirm,
      confirmButtonText: context.l10n.dialog_confirmDiscardButton,
    );
  }

  static void showConfirmLogoutDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showConfirmDialog(
      context: context,
      customTitle: context.l10n.dialog_logoutTitle,
      customMessage: context.l10n.dialog_logoutMessage,
      iconData: PhosphorIcons.signOut(),
      action: ConfirmAction.exit,
      onConfirm: onConfirm,
      confirmButtonText: context.l10n.dialog_exitConfirmButtonText,
    );
  }

  // === SNACKBAR / TOAST MESSAGE METHODS ===

  static void showSnackbar({
    required BuildContext context,
    required String message,
    required MessageType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final themeData = _getToastThemeData(type);
    final icon = _getIconByType(type);

    _showCustomToast(
      context: context,
      message: message,
      icon: icon,
      backgroundColor: themeData.backgroundColor,
      textColor: themeData.textColor,
      iconColor: themeData.iconColor,
      iconBgColor: themeData.iconBgColor,
      duration: duration,
    );
  }

  static void showSuccessSnackbar(BuildContext context, String? message) {
    showSnackbar(
      context: context,
      message: message ?? context.l10n.common_operationSuccessMessage,
      type: MessageType.success,
    );
  }

  static void showErrorSnackbar(BuildContext context, String? message) {
    showSnackbar(
      context: context,
      message: message ?? context.l10n.core_genericErrorRetryMessage,
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

  static void showErrorDialog(BuildContext context, String? message, {String? description}) {
    final resolvedMessage = message ?? context.l10n.core_genericErrorRetryMessage;
    showDialog(
      context: context,
      builder: (context) =>
          _CustomMessageDialog(message: resolvedMessage, type: MessageType.error, description: description),
    );
  }

  static void showSuccessDialog(BuildContext context, String? message, {String? description}) {
    final resolvedMessage = message ?? context.l10n.common_operationSuccessMessage;
    showDialog(
      context: context,
      builder: (context) =>
          _CustomMessageDialog(message: resolvedMessage, type: MessageType.success, description: description),
    );
  }

  static void showWarningDialog(BuildContext context, String? message, {String? description}) {
    final resolvedMessage = message ?? context.l10n.common_warningTitle;
    showDialog(
      context: context,
      builder: (context) =>
          _CustomMessageDialog(message: resolvedMessage, type: MessageType.warning, description: description),
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
    required Color iconBgColor,
    required Duration duration,
  }) {
    FToast fToast = FToast();
    fToast.init(context);

    final toast = Container(
      margin: const EdgeInsets.only(bottom: 50.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: backgroundColor,
        border: Border.all(color: MedColors.border, width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x141E325A), blurRadius: 12, offset: Offset(0, 4)),
          BoxShadow(color: Color(0x0A1E325A), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Center(child: Icon(icon, color: iconColor, size: 16)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                height: 1.4,
              ),
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
      fadeDuration: const Duration(milliseconds: 250),
    );
  }

  static _ToastThemeData _getToastThemeData(MessageType type) {
    switch (type) {
      case MessageType.success:
        return _ToastThemeData(
          backgroundColor: MedColors.surface,
          textColor: MedColors.text,
          iconColor: MedColors.green,
          iconBgColor: MedColors.greenLight,
        );
      case MessageType.error:
        return _ToastThemeData(
          backgroundColor: MedColors.surface,
          textColor: MedColors.text,
          iconColor: MedColors.red,
          iconBgColor: MedColors.redLight,
        );
      case MessageType.warning:
        return _ToastThemeData(
          backgroundColor: MedColors.surface,
          textColor: MedColors.text,
          iconColor: MedColors.amber,
          iconBgColor: MedColors.amberLight,
        );
      case MessageType.info:
        return _ToastThemeData(
          backgroundColor: MedColors.surface,
          textColor: MedColors.text,
          iconColor: MedColors.blue,
          iconBgColor: MedColors.blueLight,
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
    switch (action) {
      case ConfirmAction.delete:
        return _ConfirmDialogContent(
          title: context.l10n.dialog_deleteTitle,
          message: context.l10n.dialog_deleteDefaultMessage,
          icon: PhosphorIcons.trash(),
          iconColor: MedColors.red,
          iconBgColor: MedColors.redLight,
          buttonVariant: MedButtonVariant.danger,
        );
      case ConfirmAction.exit:
        return _ConfirmDialogContent(
          title: 'Çıkış',
          message: 'Kaydetmediğiniz değişiklikler kaybolabilir.',
          icon: PhosphorIcons.signOut(),
          iconColor: MedColors.amber,
          iconBgColor: MedColors.amberLight,
          buttonVariant: MedButtonVariant.secondary,
        );
      case ConfirmAction.save:
        return _ConfirmDialogContent(
          title: 'Kaydet',
          message: 'Değişiklikleri kaydetmek istiyor musunuz?',
          icon: PhosphorIcons.floppyDisk(),
          iconColor: MedColors.blue,
          iconBgColor: MedColors.blueLight,
          buttonVariant: MedButtonVariant.primary,
        );
      case ConfirmAction.discard:
        return _ConfirmDialogContent(
          title: 'İptal Et',
          message: 'Yapılan değişiklikler geri alınacak.',
          icon: PhosphorIcons.xCircle(),
          iconColor: MedColors.amber,
          iconBgColor: MedColors.amberLight,
          buttonVariant: MedButtonVariant.secondary,
        );
      case ConfirmAction.custom:
        return _ConfirmDialogContent(
          title: 'Onay',
          message: 'İşlemi onaylıyor musunuz?',
          icon: PhosphorIcons.question(),
          iconColor: MedColors.blue,
          iconBgColor: MedColors.blueLight,
          buttonVariant: MedButtonVariant.primary,
        );
    }
  }
}

// === SUPPORTING CLASSES ===

class _ToastThemeData {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color iconBgColor;

  _ToastThemeData({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class _ConfirmDialogContent {
  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final MedButtonVariant buttonVariant;

  _ConfirmDialogContent({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.buttonVariant,
  });
}

class _CustomMessageDialog extends StatelessWidget {
  final String message;
  final MessageType type;
  final String? description;

  const _CustomMessageDialog({required this.message, required this.type, this.description});

  @override
  Widget build(BuildContext context) {
    final themeData = MessageUtils._getToastThemeData(type);
    final icon = MessageUtils._getIconByType(type);

    final MedButtonVariant buttonVariant = switch (type) {
      MessageType.error => MedButtonVariant.danger,
      MessageType.success => MedButtonVariant.success,
      MessageType.warning => MedButtonVariant.secondary,
      MessageType.info => MedButtonVariant.primary,
    };

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 360),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
        decoration: BoxDecoration(
          color: MedColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: MedColors.border, width: 1),
          boxShadow: const [
            BoxShadow(color: Color(0x1F1E325A), blurRadius: 32, offset: Offset(0, 12)),
            BoxShadow(color: Color(0x0F1E325A), blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: themeData.iconBgColor, shape: BoxShape.circle),
              child: Center(child: Icon(icon, color: themeData.iconColor, size: 28)),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: MedTextStyles.bodyLg().copyWith(fontWeight: FontWeight.w600, color: MedColors.text, height: 1.55),
            ),
            if (description != null)
              Text(
                description!,
                textAlign: TextAlign.center,
                style: MedTextStyles.bodySm(color: MedColors.text),
              ),
            const SizedBox(height: 12),
            MedButton(
              label: context.l10n.common_okButton,
              variant: buttonVariant,
              size: MedButtonSize.sm,
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
