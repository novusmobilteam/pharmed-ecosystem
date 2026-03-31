// [SWREQ-SETUP-UI-012]
// Adım 2 — Kabin temel bilgileri.
// Kabin adı, konum, IP, port, zaman aşımı, SSL.
// Sınıf: Class A

import 'package:flutter/material.dart';
import 'package:pharmed_client/shared/widgets/molecules/med_select_field.dart';
import '../../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../../shared/widgets/atoms/med_text_field.dart';
import '../../../../../../shared/widgets/molecules/med_ip_field.dart';
import '../../../../domain/model/cabin_setup_config.dart';
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
  });

  final WizardBasicInfo? initial;
  final List<String> availablePorts;
  final ValueChanged<WizardBasicInfo> onChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  State<Step2BasicInfo> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends State<Step2BasicInfo> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;

  late String _ipAddress;
  late int _timeoutSeconds;
  late String _port;

  @override
  void initState() {
    super.initState();
    final info = widget.initial;
    _nameCtrl = TextEditingController(text: info?.cabinName ?? '');
    _locationCtrl = TextEditingController(text: info?.location ?? '');

    _port = info?.comPort ?? '';
    _ipAddress = info?.ipAddress ?? '';
    _timeoutSeconds = info?.timeoutSeconds ?? 30;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      WizardBasicInfo(
        comPort: _port,
        cabinName: _nameCtrl.text.trim(),
        ipAddress: _ipAddress,
        location: _locationCtrl.text.trim(),
        timeoutSeconds: _timeoutSeconds,
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
                SectionLabel(label: 'KABİN KİMLİĞİ'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: MedTextField(
                        controller: _nameCtrl,
                        label: 'Kabin Adı',
                        hint: 'örn. CB-304',
                        prefixIcon: Icon(Icons.inventory_2_outlined),
                        onChanged: (_) => _notify(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: MedTextField(
                        controller: _locationCtrl,
                        label: 'Konum',
                        hint: 'örn. Kat 3 Koridor B',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        onChanged: (_) => _notify(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Bağlantı ──
                SectionLabel(label: 'BAĞLANTI AYARLARI'),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
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
                    ),
                    SizedBox(height: 12),
                    MedTextField(label: 'DVR IP'),
                  ],
                ),
                if (widget.availablePorts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Aktif COM Port bulunamadı. Sürücülerin yüklü olduğundan emin olun.',
                      style: TextStyle(color: MedColors.ledRed, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // MARK: Footer
        StepFooter(onBack: widget.onBack, onNext: () => _port.isNotEmpty ? widget.onNext!() : null),
      ],
    );
  }
}
