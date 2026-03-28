part of 'medicine_refund_view.dart';

class RefundConfirmationView extends StatelessWidget {
  const RefundConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineRefundNotifier>(
      builder: (context, notifier, _) {
        final String message = notifier.type == ReturnType.toOrigin
            ? 'İade işleminizi tamamlamak için ilacı yerine yerleştirin ve çekmeceyi kapatın.'
            : 'İade işleminizi tamamlamak için ilacı iade kutusuna yerleştirin ve çekmeceyi kapatın.';

        return Dialog(
          child: Container(
            padding: EdgeInsets.all(24.0),
            constraints: const BoxConstraints(
              minWidth: 340,
              maxWidth: 420,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.trayArrowDown(),
                      color: context.colorScheme.onPrimary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- TITLE ---
                Text(
                  notifier.type.label,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // --- MESSAGE ---
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // --- BUTTONS ---
                Row(
                  children: [
                    Expanded(
                      child: PharmedButton(
                        onPressed: () => context.pop(false),
                        label: 'İptal',
                        backgroundColor: context.colorScheme.surfaceContainer,
                        foregroundColor: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PharmedButton(
                        onPressed: () {
                          context.pop(true);
                        },
                        label: 'Tamamla',
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
