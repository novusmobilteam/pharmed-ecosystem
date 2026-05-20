part of 'patient_medicine_define_view.dart';

Future<bool> showDefineConfirmDialog(BuildContext context) async {
  final result = await showDialog(context: context, builder: (context) => DefineConfirmDialog());

  return result;
}

class DefineConfirmDialog extends StatelessWidget {
  const DefineConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Çekmece açıldı. Lütfen belirtilen dozda ürünün dolum işlemini gerçekleştiriniz.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            Divider(height: 22, color: context.colorScheme.onSurfaceVariant.withAlpha(80)),

            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: MedButton(
                    label: 'Sorun Var',
                    onPressed: () => Navigator.pop(context, false), // İptal
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MedButton(
                    label: 'Dolum Yapıldı',
                    variant: MedButtonVariant.success,
                    onPressed: () => Navigator.pop(context, true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
