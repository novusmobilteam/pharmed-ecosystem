import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/core.dart';

class CabinSetupScreen extends StatefulWidget {
  const CabinSetupScreen({super.key});

  @override
  State<CabinSetupScreen> createState() => _CabinSetupScreenState();
}

class _CabinSetupScreenState extends State<CabinSetupScreen> {
  // UI Durum Değişkenleri
  bool _isLoading = false;
  String _statusMessage = "Kuruluma Hazır";
  String _detailMessage = "Lütfen USB bağlantısını kontrol edip başlatın.";
  IconData _statusIcon = PhosphorIcons.desktopTower();
  Color _statusColor = Colors.blueGrey;

  // UseCase'i normalde DI (GetIt vb.) ile almalısın, burada örnek olarak manual alıyoruz.
  // final ScanCabinUseCase _scanUseCase = GetIt.I<ScanCabinUseCase>();

  Future<void> _startSetup(BuildContext context) async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Bağlantı Kuruluyor...";
      _detailMessage = "Portlar taranıyor (Varsayılan: COM3)";
      _statusColor = Colors.blue;
      _statusIcon = PhosphorIcons.plugsConnected();
    });

    try {
      final scanUseCase = context.read<ScanCabinUseCase>();

      final result = await scanUseCase.call(portName: "COM3", cabinType: CabinType.cabinet);

      if (result is Ok) {
        setState(() {
          _statusMessage = "Kurulum Başarılı!";
          _detailMessage = "Kabin tanımlandı. Yönlendiriliyorsunuz...";
          _statusColor = Colors.green;
          _statusIcon = PhosphorIcons.checkCircle(PhosphorIconsStyle.fill);
        });

        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          // Client Dashboard'a yönlendir
          Navigator.pushReplacementNamed(context, '/clientDashboard');
        }
      } else {
        throw (result as Error);
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Kurulum Başarısız";
        _detailMessage = e.toString().replaceAll("CustomException: ", "");
        _statusColor = Colors.red;
        _statusIcon = PhosphorIcons.warningCircle(PhosphorIconsStyle.fill);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Üst İkon (Animasyonlu veya Statik)
              _buildStatusIcon(),

              const SizedBox(height: 32),

              // 2. Başlıklar
              Text(
                _statusMessage,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2D3748)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _detailMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF718096)),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // 3. İlerleme Çubuğu (Loading ise göster)
              if (_isLoading) ...[
                const LinearProgressIndicator(minHeight: 6, borderRadius: BorderRadius.all(Radius.circular(10))),
                const SizedBox(height: 20),
              ],

              // 4. Aksiyon Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _startSetup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3182CE),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLoading ? "İşlem Sürüyor..." : "Kurulumu Başlat",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: _statusColor.withAlpha(25),
        shape: BoxShape.circle,
        border: Border.all(color: _statusColor.withAlpha(35), width: 2),
      ),
      child: Center(
        child: _isLoading
            ? SizedBox(width: 60, height: 60, child: CircularProgressIndicator(color: _statusColor, strokeWidth: 3))
            : Icon(_statusIcon, size: 48, color: _statusColor),
      ),
    );
  }
}
