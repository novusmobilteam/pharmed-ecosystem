// lib/features/assignment/presentation/view/patient_assignment_panel.dart
//
// [SWREQ-UI-CAB-006]
// Hasta bazlı atama sağ panel içeriği.
//
// Göz seçilmeden → placeholder
// Göz seçildi, atanmamış → yatış seçici butonu + Kaydet
// Göz seçildi, atanmış → hasta kimlik kartı + Değiştir / Atamayı Kaldır
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../state/patient_assignment_state.dart';

class PatientAssignmentPanel extends StatelessWidget {
  const PatientAssignmentPanel({
    super.key,
    required this.state,
    required this.onSelectHospitalization,
    required this.onSave,
    required this.onDelete,
  });

  final PatientAssignmentState state;

  /// Yatış seç butonuna basılınca çağrılır.
  /// Dialog açma sorumluluğu view'dadır.
  final VoidCallback onSelectHospitalization;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      PatientAssignmentCellSelected s => _CellSelectedContent(
        state: s,
        onSelectHospitalization: onSelectHospitalization,
        onSave: onSave,
        onDelete: onDelete,
      ),
      PatientAssignmentSaving _ => const _SavingContent(),
      _ => const _PlaceholderContent(),
    };
  }
}

class _PlaceholderContent extends StatelessWidget {
  const _PlaceholderContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MedColors.surface3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MedColors.border, width: 1.5),
            ),
            child: Icon(Icons.person_outline_rounded, size: 22, color: MedColors.text4),
          ),
          const SizedBox(height: 12),
          Text(
            'Bir göz seçin',
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MedColors.text3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hasta atamak için orta\npanelden bir göz seçin.',
            style: MedTextStyles.bodySm(color: MedColors.text4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SavingContent extends StatelessWidget {
  const _SavingContent();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _CellSelectedContent extends StatelessWidget {
  const _CellSelectedContent({
    required this.state,
    required this.onSelectHospitalization,
    required this.onSave,
    required this.onDelete,
  });

  final PatientAssignmentCellSelected state;
  final VoidCallback onSelectHospitalization;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Yatış seçici
          _HospitalizationSelector(selected: state.selectedHospitalization, onTap: onSelectHospitalization),

          // Atanmışsa hasta kimlik kartı
          if (state.selectedHospitalization != null) ...[
            const SizedBox(height: 14),
            _PatientCard(hospitalization: state.selectedHospitalization!),
          ],

          const SizedBox(height: 20),

          // Butonlar
          _ActionButtons(
            existingAssignment: state.existingAssignment,
            selectedHospitalization: state.selectedHospitalization,
            onSave: onSave,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class _HospitalizationSelector extends StatelessWidget {
  const _HospitalizationSelector({required this.selected, required this.onTap});

  final Hospitalization? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasSelection = selected != null;
    final patientName = selected?.patient?.fullName ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HASTA / YATIŞ',
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: hasSelection ? MedColors.blueLight : MedColors.surface2,
              border: Border.all(color: hasSelection ? MedColors.blue : MedColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasSelection ? patientName : 'Yatış seçin...',
                    style: TextStyle(
                      fontFamily: MedFonts.sans,
                      fontSize: 13,
                      fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w400,
                      color: hasSelection ? MedColors.blue : MedColors.text3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.search_rounded, size: 16, color: hasSelection ? MedColors.blue : MedColors.text3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.hospitalization});

  final Hospitalization hospitalization;

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    final name = patient?.fullName ?? '—';
    final initials = _initials(name);
    final room = hospitalization.room?.name ?? '—';
    final bed = hospitalization.bed?.name ?? '—';
    final service = hospitalization.physicalService?.name ?? '—';
    final code = hospitalization.code ?? '—';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.blueLight,
        border: Border.all(color: MedColors.blue.withOpacity(0.25), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır — avatar + isim
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: MedColors.blue, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontFamily: MedFonts.sans,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MedColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      code.toString(),
                      style: TextStyle(
                        fontFamily: MedFonts.mono,
                        fontSize: 10,
                        color: MedColors.text3,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x1A1A6FD8)),
          const SizedBox(height: 10),
          // Detay satırları
          _InfoRow(label: 'Oda / Yatak', value: '$room / $bed'),
          const SizedBox(height: 4),
          _InfoRow(label: 'Servis', value: service),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3, letterSpacing: 0.4),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MedColors.text,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.existingAssignment,
    required this.selectedHospitalization,
    required this.onSave,
    required this.onDelete,
  });

  final PatientAssignment? existingAssignment;
  final Hospitalization? selectedHospitalization;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  bool get _isAssigned => existingAssignment != null;
  bool get _isChanged =>
      _isAssigned &&
      selectedHospitalization != null &&
      selectedHospitalization!.id != existingAssignment!.hospitalization?.id;
  bool get _canSave => !_isAssigned && selectedHospitalization != null;

  @override
  Widget build(BuildContext context) {
    if (_isAssigned && !_isChanged) {
      // Mevcut atama var, değişiklik yok → sadece Kaldır
      return _PanelButton.danger(label: 'Atamayı Kaldır', icon: Icons.delete_outline_rounded, onTap: onDelete);
    }

    if (_isChanged) {
      // Farklı hasta seçildi → Değiştir + Kaldır
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelButton.primary(
            label: 'Atamayı Değiştir',
            icon: Icons.swap_horiz_rounded,
            color: MedColors.blue,
            onTap: onSave,
          ),
          const SizedBox(height: 8),
          _PanelButton.danger(label: 'Atamayı Kaldır', icon: Icons.delete_outline_rounded, onTap: onDelete),
        ],
      );
    }

    // Atama yok → Kaydet
    return _PanelButton.primary(
      label: 'Atamayı Kaydet',
      icon: Icons.check_rounded,
      color: MedColors.green,
      enabled: _canSave,
      onTap: _canSave ? onSave : null,
    );
  }
}

class _PanelButton extends StatelessWidget {
  const _PanelButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isDanger,
    this.enabled = true,
    this.onTap,
    this.color,
  });

  factory _PanelButton.primary({
    required String label,
    required IconData icon,
    Color? color,
    bool enabled = true,
    VoidCallback? onTap,
  }) => _PanelButton(
    label: label,
    icon: icon,
    isPrimary: true,
    isDanger: false,
    color: color,
    enabled: enabled,
    onTap: onTap,
  );

  factory _PanelButton.danger({required String label, required IconData icon, VoidCallback? onTap}) =>
      _PanelButton(label: label, icon: icon, isPrimary: false, isDanger: true, onTap: onTap);

  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDanger;
  final bool enabled;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    final Color fg;

    if (!enabled) {
      bg = MedColors.surface3;
      border = MedColors.border;
      fg = MedColors.text4;
    } else if (isDanger) {
      bg = MedColors.redLight;
      border = MedColors.red;
      fg = MedColors.red;
    } else {
      final c = color ?? MedColors.blue;
      bg = c;
      border = c;
      fg = Colors.white;
    }
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled && isPrimary
              ? [BoxShadow(color: MedColors.blue.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, fontWeight: FontWeight.w600, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
