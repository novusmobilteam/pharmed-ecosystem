// [SWREQ-SETUP-UI-012]
// Adım 2 — Kabin temel bilgileri.
// Kabin adı, konum, IP, port, zaman aşımı, SSL.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../../../../../core/hardware/service/rfid/model/rfid_reader_info.dart';
import '../../../../domain/model/cabin_setup_config.dart';
import '../../../state/setup_wizard_ui_state.dart';
import '../../widgets/step_shared_widgets.dart';

part 'field_label.dart';

class Step2BasicInfo extends StatefulWidget {
  const Step2BasicInfo({
    super.key,
    required this.availablePorts,
    required this.initial,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
    required this.onTestRfid,
    required this.rfidTestState,
    this.rfidReaderInfo,
    this.rfidTestError,
  });

  final WizardBasicInfo? initial;
  final List<String> availablePorts;
  final ValueChanged<WizardBasicInfo> onChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;
  final VoidCallback onTestRfid;
  final RfidTestState rfidTestState;
  final RfidReaderInfo? rfidReaderInfo;
  final String? rfidTestError;

  @override
  State<Step2BasicInfo> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends State<Step2BasicInfo> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _rfidPortController;

  late String _ipAddress;
  late String _port;
  late String _dvrIp;
  late bool _rfidEnable;
  late String _rfidIpAddress;

  @override
  void initState() {
    super.initState();
    final info = widget.initial;
    _nameCtrl = TextEditingController(text: info?.cabinName ?? '');
    _rfidPortController = TextEditingController(text: info?.rfidPort ?? '6000');
    _port = info?.comPort ?? '';
    _dvrIp = info?.dvrIp ?? '';
    _ipAddress = info?.ipAddress ?? '';
    _rfidEnable = info?.rfidEnable ?? false;
    _rfidIpAddress = info?.rfidIpAddress ?? '192.168.1.190';
    WidgetsBinding.instance.addPostFrameCallback((_) => _notify());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rfidPortController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      WizardBasicInfo(
        comPort: _port,
        dvrIp: _dvrIp,
        cabinName: _nameCtrl.text.trim(),
        ipAddress: _ipAddress,
        rfidPort: _rfidPortController.text.trim(),
        rfidEnable: _rfidEnable,
        rfidIpAddress: _rfidIpAddress,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // MARK: Header
        StepHeader(
          badge: 'Adım 2 / 5',
          title: 'Temel Bilgiler',
          subtitle: 'Kabin adı, konum ve cihaz bağlantı ayarlarını girin.',
        ),

        // MARK: Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Kimlik ──
                MedTextField(
                  controller: _nameCtrl,
                  label: 'Kabin Adı',
                  hint: 'örn. CB-304',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  onChanged: (_) => _notify(),
                ),
                const SizedBox(height: 24),

                // ── Bağlantı ──
                SectionLabel(label: 'BAĞLANTI AYARLARI'),
                const SizedBox(height: 12),
                Column(children: [_ipAddressField(), SizedBox(height: 12), _dvrIpField()]),
                if (widget.availablePorts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Aktif COM Port bulunamadı. Sürücülerin yüklü olduğundan emin olun.',
                      style: TextStyle(color: MedColors.ledRed, fontSize: 11),
                    ),
                  ),

                // ── Anten ──
                const SizedBox(height: 24),
                SectionLabel(label: 'ANTEN AYARLARI'),
                _antennaField(),
              ],
            ),
          ),
        ),

        // MARK: Footer
        StepFooter(onBack: widget.onBack, onNext: () => _port.isNotEmpty ? widget.onNext!() : null),
      ],
    );
  }

  Row _ipAddressField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IP
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FieldLabel(text: 'IP Adresi'),
              const SizedBox(height: 6),
              MedIpField(
                initialValue: _ipAddress,
                onChanged: (ip) {
                  _ipAddress = ip;
                  _notify();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Port
        SizedBox(
          width: 120,
          child: MedSelectField<String>(
            label: 'Port',
            value: _port,
            enabled: widget.availablePorts.isNotEmpty,
            onChanged: (val) {
              setState(() => _port = val);
              _notify();
            },
            options: widget.availablePorts.map((p) => MedSelectOption(label: p, value: p)).toList(),
          ),
        ),
      ],
    );
  }

  Column _dvrIpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(text: 'DVR IP'),
        const SizedBox(height: 6),
        MedIpField(
          initialValue: _dvrIp,
          onChanged: (ip) {
            _dvrIp = ip;
            _notify();
          },
        ),
      ],
    );
  }

  Column _antennaField() {
    return Column(
      children: [
        ToggleField(
          value: _rfidEnable,
          onChanged: (value) {
            _rfidEnable = value;
            _notify();
          },
          label: 'RFID okuyucu var',
        ),
        if (_rfidEnable)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel(text: 'RFID IP Adresi'),
                        const SizedBox(height: 6),
                        MedIpField(
                          initialValue: _rfidIpAddress,
                          onChanged: (ip) {
                            _rfidIpAddress = ip;
                            _notify();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Port
                  SizedBox(
                    width: 120,
                    child: MedTextField(
                      label: 'RFID Port',
                      controller: _rfidPortController,
                      enabled: widget.availablePorts.isNotEmpty,
                      onChanged: (_) => _notify(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RfidTestButton(
                ipAddress: _rfidIpAddress,
                port: _rfidPortController.text,
                testState: widget.rfidTestState,
                readerInfo: widget.rfidReaderInfo,
                rfidTestError: widget.rfidTestError,
                onTestRfid: () => widget.onTestRfid(),
              ),
            ],
          ),
      ],
    );
  }
}

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
