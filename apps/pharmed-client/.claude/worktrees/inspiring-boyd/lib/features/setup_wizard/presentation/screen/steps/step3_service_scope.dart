// lib/features/setup_wizard/presentation/screen/steps/step3_service_scope.dart
//
// [SWREQ-SETUP-UI-013]
// Adım 3 — Hizmet kapsamı.
// Standart kabin → servis seçimi. Mobil kabin → oda listesi.
// Sınıf: Class A

import 'package:flutter/material.dart';
import '../../../../../shared/widgets/atoms/med_tokens.dart';
import '../../../../../shared/widgets/molecules/med_select_field.dart';
import '../../../../../shared/widgets/molecules/med_tags_field.dart';
import '../../../domain/model/cabin_setup_config.dart';
import 'step_shared.dart';

// Mocklanmış servis listesi (ileride remote'dan gelir)
const _kServices = [
  'Kardiyoloji',
  'Nöroloji',
  'Dahiliye',
  'Ortopedi',
  'Genel Cerrahi',
  'Acil Servis',
  'Yoğun Bakım',
  'Göğüs Hastalıkları',
  'Enfeksiyon Hastalıkları',
  'Üroloji',
];

class Step3ServiceScope extends StatefulWidget {
  const Step3ServiceScope({
    super.key,
    required this.cabinetType,
    required this.initial,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  final CabinetType cabinetType;
  final ServiceScope? initial;
  final ValueChanged<ServiceScope> onChanged;
  final VoidCallback? onNext;
  final VoidCallback onBack;

  @override
  State<Step3ServiceScope> createState() => _Step3ServiceScopeState();
}

class _Step3ServiceScopeState extends State<Step3ServiceScope> {
  String? _selectedService;
  List<String> _rooms = [];

  @override
  void initState() {
    super.initState();
    final scope = widget.initial;
    if (scope is ServiceBased) {
      _selectedService = scope.serviceName;
    } else if (scope is RoomBased) {
      _rooms = List.from(scope.rooms);
    }
  }

  void _notifyService(String? service) {
    if (service == null) return;
    widget.onChanged(ServiceBased(serviceName: service));
  }

  void _notifyRooms(List<String> rooms) {
    widget.onChanged(RoomBased(rooms: rooms));
  }

  @override
  Widget build(BuildContext context) {
    final isStandard = widget.cabinetType == CabinetType.standard;

    return Column(
      children: [
        StepHeader(
          badge: 'Adım 3 / 5',
          title: 'Hizmet Kapsamı',
          subtitle: isStandard
              ? 'Bu kabinin hizmet vereceği kliniği seçin.'
              : 'Mobil kabinin dolaşacağı odaları tanımlayın.',
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
            child: isStandard
                ? _ServiceBasedForm(
                    selectedService: _selectedService,
                    onServiceChanged: (s) {
                      setState(() => _selectedService = s);
                      _notifyService(s);
                    },
                  )
                : _RoomBasedForm(
                    initialRooms: _rooms,
                    onRoomsChanged: (rooms) {
                      setState(() => _rooms = rooms);
                      _notifyRooms(rooms);
                    },
                  ),
          ),
        ),

        StepFooter(onBack: widget.onBack, onNext: widget.onNext),
      ],
    );
  }
}

// ── Standart: Servis seçim formu ──────────────────────────────────

class _ServiceBasedForm extends StatelessWidget {
  const _ServiceBasedForm({required this.selectedService, required this.onServiceChanged});

  final String? selectedService;
  final ValueChanged<String?> onServiceChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.local_hospital_outlined,
          color: MedColors.blue,
          bgColor: MedColors.blueLight,
          text: 'Seçilen servis, raporlama ve stok takibinde ana filtreleme kriteri olarak kullanılacaktır.',
        ),
        const SizedBox(height: 24),
        const Text(
          'KLİNİK / SERVİS',
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: MedColors.text3,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        MedSelectField<String>(
          label: 'Servis Seçin',
          value: selectedService,
          options: _kServices.map((s) => MedSelectOption(label: s, value: s)).toList(),
          onChanged: onServiceChanged,
        ),
        if (selectedService != null) ...[const SizedBox(height: 16), _SelectedBadge(label: selectedService!)],
      ],
    );
  }
}

// ── Mobil: Oda listesi formu ──────────────────────────────────────

class _RoomBasedForm extends StatelessWidget {
  const _RoomBasedForm({required this.initialRooms, required this.onRoomsChanged});

  final List<String> initialRooms;
  final ValueChanged<List<String>> onRoomsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoBanner(
          icon: Icons.meeting_room_outlined,
          color: const Color(0xFF0D9E6C),
          bgColor: const Color(0xFFE6F7F2),
          text: 'Her oda numarasını yazıp Enter veya virgül ile ekleyin. Örn: 301, 302, 303',
        ),
        const SizedBox(height: 24),
        const Text(
          'ODA LİSTESİ',
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: MedColors.text3,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        MedTagsField(
          label: 'Oda Numarası Ekle',
          helperText: 'örn. 301',
          initialTags: initialRooms,
          onChanged: onRoomsChanged,
        ),
        if (initialRooms.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            '${initialRooms.length} oda tanımlandı',
            style: const TextStyle(fontFamily: MedFonts.mono, fontSize: 11, color: MedColors.text3),
          ),
        ],
      ],
    );
  }
}

// ── Paylaşılan küçük bileşenler ──────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.color, required this.bgColor, required this.text});

  final IconData icon;
  final Color color;
  final Color bgColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 12, color: color, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MedColors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 16, color: MedColors.blue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MedColors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
