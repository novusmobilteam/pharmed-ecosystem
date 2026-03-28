part of 'medicine_unload_view.dart';

class UnloadConfirmationView extends StatelessWidget {
  const UnloadConfirmationView({super.key, required this.inputs, this.assignment});

  final List<CabinInputData> inputs;
  final CabinAssignment? assignment;

  Future<void> _handleComplete(
    BuildContext context,
    MedicineUnloadNotifier notifier,
    UnloadType type,
  ) async {
    await notifier.completeUnload(
      type,
      inputs,
      onFailed: (msg) => MessageUtils.showErrorSnackbar(context, msg),
      onSuccess: (msg) {
        context.pop();
        MessageUtils.showSuccessSnackbar(context, msg);
      },
    );

    if (!context.mounted) return;

    final completedType = notifier.completedType;
    if (completedType == null) return;

    if (completedType == UnloadType.changeAssignment) {
      await showCabinAssignmentFormView(context, assignment);
    }

    if (context.mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final theme = context.theme;

    return Consumer<MedicineUnloadNotifier>(
      builder: (context, notifier, _) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 340,
              maxWidth: 620,
            ),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
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
                Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      PhosphorIcons.arrowsLeftRight(),
                      color: colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'İlaç Atama Güncelleme',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tüm ilaçları boşaltıyorsunuz. Atamayı silmek ya da değiştirmek istiyor musunuz?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: context.width,
                  child: PharmedButton(
                    onPressed: () => _handleComplete(context, notifier, UnloadType.basic),
                    label: 'İşlemi Tamamla',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: PharmedButton(
                        onPressed: () => _handleComplete(context, notifier, UnloadType.deleteAssignment),
                        label: 'Tamamla ve Atamayı Sil',
                        backgroundColor: Colors.red,
                      ),
                    ),
                    Expanded(
                      child: PharmedButton(
                        onPressed: () => _handleComplete(context, notifier, UnloadType.changeAssignment),
                        label: 'Tamamla ve Atamayı Değiştir',
                        backgroundColor: Colors.amber,
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
