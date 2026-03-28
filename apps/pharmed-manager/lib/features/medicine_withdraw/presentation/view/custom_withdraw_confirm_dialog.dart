part of 'custom_withdraw_view.dart';

class CustomWithdrawConfirmDialog extends StatelessWidget {
  final WithdrawItem item;

  const CustomWithdrawConfirmDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Çekmece açıldı. Lütfen belirtilen miktarda ürünü alınız.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            Divider(
              height: 22,
              color: context.colorScheme.onSurfaceVariant.withAlpha(80),
            ),

            // İlaç Bilgisi
            Text(
              item.medicine?.name ?? '-',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.colorScheme.secondary.withAlpha(120),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "Alınacak Miktar",
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    item.dosePiece.formatFractional,
                    style: TextStyle(
                      fontSize: 28,
                      color: context.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: PharmedButton(
                    label: 'Sorun Var',
                    onPressed: () => Navigator.pop(context, false), // İptal
                    backgroundColor: context.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PharmedButton(
                    label: 'Alım Yapıldı',
                    backgroundColor: Colors.green,
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
