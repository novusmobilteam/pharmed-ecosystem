part of '../view/medicine_management_view.dart';

class _ActionBar extends StatelessWidget {
  final MedicineManagementNotifier notifier;
  final Color accentColor;
  final bool isOrderless;

  const _ActionBar({
    required this.notifier,
    required this.accentColor,
    required this.isOrderless,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          // Sol grup: işlem butonları
          _ActionButton(
            icon: PhosphorIcons.pill(),
            label: 'Serbest İlaç',
            color: accentColor,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => WithdrawView(withdrawType: WithdrawType.free),
            ),
          ),
          const SizedBox(width: 8),
          if (notifier.isUrgentPatientButtonVisible)
            _ActionButton(
              icon: PhosphorIcons.firstAid(),
              label: 'Acil Hasta Oluştur',
              color: const Color(0xFFC62828),
              onPressed: () {
                notifier.createUrgentPatient(
                  onLoading: () => showLoading(context),
                  onFailed: (msg) {
                    hideLoading(context);
                    MessageUtils.showErrorSnackbar(context, msg);
                  },
                  onSuccess: (msg) {
                    hideLoading(context);
                    MessageUtils.showSuccessSnackbar(context, msg);
                    showDialog(
                      context: context,
                      builder: (_) => WithdrawView(
                        withdrawType: WithdrawType.urgent,
                        hospitalization: notifier.urgentPatient,
                      ),
                    );
                  },
                );
              },
            ),

          const Spacer(),

          // Sağ grup: mod değiştirme
          if (notifier.isStatusButtonVisible)
            _ModeToggleButton(
              isOrderless: isOrderless,
              accentColor: accentColor,
              onPressed: notifier.toggleOrderlessStatus,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        shadowColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
      child: Text(label),
    );
  }
}
