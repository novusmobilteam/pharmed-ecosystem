part of 'step2_basic_info.dart';

class _RfidTestButton extends StatelessWidget {
  const _RfidTestButton({
    required this.ipAddress,
    required this.port,
    required this.testState,
    required this.readerInfo,
    required this.onTestRfid,
    this.rfidTestError,
  });

  final String ipAddress;
  final String port;
  final RfidTestState testState;
  final RfidReaderInfo? readerInfo;
  final VoidCallback? onTestRfid;
  final String? rfidTestError;

  bool get _canTest => ipAddress.isNotEmpty && port.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return switch (testState) {
      // Test edilmedi veya hata — butonu göster
      RfidTestState.idle => MedButton(
        label: 'Anten Bağlantısını Test Et',
        size: MedButtonSize.sm,
        onPressed: _canTest ? onTestRfid : null,
      ),

      // Test devam ediyor — loading göster
      RfidTestState.testing => const SizedBox(
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
      RfidTestState.success => Row(
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
          if (readerInfo != null) ...[
            const SizedBox(width: 8),
            Text(
              '· FW ${readerInfo!.firmwareVersion}  ${readerInfo!.currentPower} dBm',
              style: const TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
            ),
          ],
          const SizedBox(width: 12),
          // Yeniden test etmek isterse
          GestureDetector(
            onTap: onTestRfid,
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

      RfidTestState.failure => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedButton(label: 'Bağlantıyı Test Et', size: MedButtonSize.sm, onPressed: _canTest ? onTestRfid : null),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 13, color: MedColors.red),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  rfidTestError ?? 'Bağlantı kurulamadı. IP ve port bilgilerini kontrol edin.',
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
