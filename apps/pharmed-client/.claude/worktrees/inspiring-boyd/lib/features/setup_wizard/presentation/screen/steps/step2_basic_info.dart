// lib/features/setup_wizard/presentation/screen/steps/step2_basic_info.dart
//
// [SWREQ-SETUP-UI-012]
// Adım 2 — Kabin temel bilgileri.
// Kabin adı, konum, IP, port, zaman aşımı, SSL.
// Sınıf: Class A

import 'package:flutter/material.dart';
import '../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../shared/widgets/atoms/med_text_field.dart';
import '../../../../../shared/widgets/atoms/med_toggle.dart';
import '../../../../../shared/widgets/molecules/med_ip_field.dart';
import '../../../../../shared/widgets/molecules/med_numeric_stepper.dart';
import '../../../domain/model/cabin_setup_config.dart';
import 'step_shared.dart';

class Step2BasicInfo extends StatefulWidget {
  const Step2BasicInfo({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final WizardBasicInfo? initial;
  final ValueChanged<WizardBasicInfo> onChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  State<Step2BasicInfo> createState() => _Step2BasicInfoState();
}

class _Step2BasicInfoState extends State<Step2BasicInfo> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _portCtrl;

  late String _ipAddress;
  late int _timeoutSeconds;
  late bool _sslEnabled;

  @override
  void initState() {
    super.initState();
    final info = widget.initial;
    _nameCtrl = TextEditingController(text: info?.cabinName ?? '');
    _locationCtrl = TextEditingController(text: info?.location ?? '');
    _portCtrl = TextEditingController(text: (info?.port ?? 8080).toString());
    _ipAddress = info?.ipAddress ?? '';
    _timeoutSeconds = info?.timeoutSeconds ?? 30;
    _sslEnabled = info?.sslEnabled ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _portCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      WizardBasicInfo(
        cabinName: _nameCtrl.text.trim(),
        ipAddress: _ipAddress,
        location: _locationCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 8080,
        timeoutSeconds: _timeoutSeconds,
        sslEnabled: _sslEnabled,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepHeader(
          badge: 'Adım 2 / 5',
          title: 'Temel Bilgiler',
          subtitle: 'Kabin adı, konum ve cihaz bağlantı ayarlarını girin.',
        ),

        // ── İçerik ──
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Kimlik ──
                _SectionLabel(label: 'KABİN KİMLİĞİ'),
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
                _SectionLabel(label: 'BAĞLANTI AYARLARI'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // IP
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: 'IP Adresi'),
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
                      child: MedTextField(
                        controller: _portCtrl,
                        label: 'Port',
                        hint: '8080',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _notify(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Gelişmiş ──
                _SectionLabel(label: 'GELİŞMİŞ AYARLAR'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Timeout stepper
                    Expanded(
                      child: _LabeledWidget(
                        label: 'Zaman Aşımı (sn)',
                        child: MedNumericStepper(
                          value: _timeoutSeconds,
                          min: 5,
                          max: 120,
                          step: 5,
                          onChanged: (v) {
                            setState(() => _timeoutSeconds = v);
                            _notify();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    // SSL toggle
                    _LabeledWidget(
                      label: 'SSL / TLS',
                      child: Row(
                        children: [
                          MedToggle(
                            value: _sslEnabled,
                            onChanged: (v) {
                              setState(() => _sslEnabled = v);
                              _notify();
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _sslEnabled ? 'Etkin' : 'Devre Dışı',
                            style: TextStyle(
                              fontFamily: MedFonts.sans,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _sslEnabled ? MedColors.green : MedColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        StepFooter(onBack: widget.onBack, onNext: widget.onNext),
      ],
    );
  }
}

// ── Yardımcı bileşenler ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: MedColors.text3,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 1, color: MedColors.border2)),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: MedFonts.sans,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: MedColors.text2,
      ),
    );
  }
}

class _LabeledWidget extends StatelessWidget {
  const _LabeledWidget({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: label),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
