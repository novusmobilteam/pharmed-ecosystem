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
import 'package:pharmed_client/l10n/l10n_ext.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../state/bed_assignment_state.dart';

class BedAssignmentPanel extends StatelessWidget {
  const BedAssignmentPanel({
    super.key,
    required this.state,
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignmentState state;
  final ValueChanged<HospitalService> onServiceSelected;
  final ValueChanged<Room> onRoomSelected;
  final ValueChanged<Bed> onBedSelected;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      BedAssignmentCellSelected s => _CellSelectedContent(
        state: s,
        onServiceSelected: onServiceSelected,
        onRoomSelected: onRoomSelected,
        onBedSelected: onBedSelected,
        onSave: onSave,
        onDelete: onDelete,
      ),
      BedAssignmentSaving _ => const _SavingContent(),
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
            context.l10n.common_selectCellTitle,
            style: TextStyle(
              fontFamily: MedFonts.sans,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: MedColors.text3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.assignment_assignBedPlaceholder,
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
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignmentCellSelected state;
  final ValueChanged<HospitalService> onServiceSelected;
  final ValueChanged<Room> onRoomSelected;
  final ValueChanged<Bed> onBedSelected;
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
          _BedSelector(
            state: state,
            onServiceSelected: onServiceSelected,
            onRoomSelected: onRoomSelected,
            onBedSelected: onBedSelected,
          ),
          if (state.selectedBed != null) ...[const SizedBox(height: 14), _BedCard(state: state)],
          const SizedBox(height: 20),
          _ActionButtons(
            existingAssignment: state.existingAssignment,
            selectedBed: state.selectedBed,
            onSave: onSave,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class _BedSelector extends StatelessWidget {
  const _BedSelector({
    required this.state,
    required this.onServiceSelected,
    required this.onRoomSelected,
    required this.onBedSelected,
  });

  final BedAssignmentCellSelected state;
  final ValueChanged<HospitalService> onServiceSelected;
  final ValueChanged<Room> onRoomSelected;
  final ValueChanged<Bed> onBedSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(context.l10n.assignment_bedSectionLabel),
        const SizedBox(height: 6),

        // Servis dropdown
        MedDropdown<HospitalService>(
          hint: context.l10n.assignment_serviceSelectorHint,
          selected: state.selectedService,
          options: state.services,
          labelBuilder: (s) => s.name ?? '—',
          onSelected: onServiceSelected,
        ),
        const SizedBox(height: 6),

        // Oda dropdown — servis seçilince aktif
        MedDropdown<Room>(
          hint: context.l10n.assignment_roomSelectorHint,
          selected: state.selectedRoom,
          options: state.rooms,
          labelBuilder: (r) => r.name ?? '—',
          enabled: state.selectedService != null && state.rooms.isNotEmpty,
          onSelected: onRoomSelected,
        ),
        const SizedBox(height: 6),

        // Yatak dropdown — oda seçilince aktif
        MedDropdown<Bed>(
          hint: context.l10n.assignment_bedSelectorHint,
          selected: state.selectedBed,
          options: state.beds,
          labelBuilder: (b) => b.name ?? '—',
          enabled: state.selectedRoom != null && state.beds.isNotEmpty,
          onSelected: onBedSelected,
        ),
      ],
    );
  }
}

class _BedCard extends StatelessWidget {
  const _BedCard({required this.state});

  final BedAssignmentCellSelected state;

  @override
  Widget build(BuildContext context) {
    final bed = state.selectedBed!;
    final room = state.selectedRoom;
    final service = state.selectedService;

    // Mevcut atamada yatış bilgisi varsa göster
    final hospitalization = state.existingAssignment?.hospitalization;
    final patientName = hospitalization?.patient?.fullName;

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
          // Yatak başlık satırı
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: MedColors.blue, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: const Icon(Icons.bed_rounded, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bed.name ?? '—',
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: MedColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (room != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        room.name ?? '—',
                        style: TextStyle(
                          fontFamily: MedFonts.mono,
                          fontSize: 10,
                          color: MedColors.text3,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (service != null || patientName != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0x1A1A6FD8)),
            const SizedBox(height: 10),
            if (service != null) _InfoRow(label: context.l10n.assignment_serviceLabel, value: service.name ?? '—'),
            if (patientName != null) ...[
              const SizedBox(height: 4),
              _InfoRow(label: context.l10n.assignment_patientLabel, value: patientName),
            ],
          ],
        ],
      ),
    );
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

// ── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: MedFonts.mono,
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        color: MedColors.text3,
      ),
    );
  }
}

// ── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.existingAssignment,
    required this.selectedBed,
    required this.onSave,
    required this.onDelete,
  });

  final BedAssignment? existingAssignment;
  final Bed? selectedBed;
  final VoidCallback onSave;
  final VoidCallback onDelete;

  bool get _isAssigned => existingAssignment != null;
  bool get _isChanged => _isAssigned && selectedBed != null && selectedBed!.id != existingAssignment!.bedId;
  bool get _canSave => !_isAssigned && selectedBed != null;

  @override
  Widget build(BuildContext context) {
    if (_isAssigned && !_isChanged) {
      return _PanelButton.danger(
        label: context.l10n.assignment_removeAssignmentButton,
        icon: Icons.delete_outline_rounded,
        onTap: onDelete,
      );
    }

    if (_isChanged) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelButton.primary(
            label: context.l10n.assignment_changeAssignmentButton,
            icon: Icons.swap_horiz_rounded,
            color: MedColors.blue,
            onTap: onSave,
          ),
          const SizedBox(height: 8),
          _PanelButton.danger(
            label: context.l10n.assignment_removeAssignmentButton,
            icon: Icons.delete_outline_rounded,
            onTap: onDelete,
          ),
        ],
      );
    }

    return _PanelButton.primary(
      label: context.l10n.assignment_saveAssignmentButton,
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
