part of 'step2_basic_info.dart';

class _CabinCardTestButton extends StatelessWidget {
  const _CabinCardTestButton({
    required this.port,
    required this.testState,
    required this.onTestCabinCard,
    this.cabinCardTestError,
  });

  final String port;
  final CabinCardTestState testState;
  final VoidCallback? onTestCabinCard;
  final String? cabinCardTestError;

  bool get _canTest => port.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return switch (testState) {
      // Test edilmedi veya hata — butonu göster
      CabinCardTestState.idle => MedButton(
        label: 'Kabin Bağlantısını Test Et',
        size: MedButtonSize.sm,
        onPressed: _canTest ? onTestCabinCard : null,
      ),

      // Test devam ediyor — loading göster
      CabinCardTestState.testing => const SizedBox(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: MedColors.blue)),
            SizedBox(width: 10),
            Text(
              'Test ediliyor…',
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text3),
            ),
          ],
        ),
      ),

      // Başarılı — bilgi satırı göster
      CabinCardTestState.success => Row(
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: MedColors.green),
          const SizedBox(width: 8),
          Text(
            'Bağlantı başarılı',
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MedColors.green,
            ),
          ),
          const SizedBox(width: 8),
          // Yeniden test etmek isterse
          GestureDetector(
            onTap: onTestCabinCard,
            child: const Text(
              'Tekrar test et',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 12,
                color: MedColors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),

      CabinCardTestState.failure => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedButton(label: 'Bağlantıyı Test Et', size: MedButtonSize.sm, onPressed: _canTest ? onTestCabinCard : null),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 13, color: MedColors.red),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  cabinCardTestError ?? 'Bağlantı kurulamadı. Port bilgisini kontrol edin.',
                  style: const TextStyle(fontFamily: MedFonts.sans, fontSize: 11, color: MedColors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    };
  }
}
