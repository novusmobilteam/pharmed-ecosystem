// lib/features/cabin/presentation/widgets/fault_panel.dart
//
// [SWREQ-UI-CAB-006]
// Arıza bildirimi sağ panel içeriği.
//
// [OperationPanelBase] iskeletine yerleştirilir.
// Göz seçilmeden önce placeholder gösterir.
// Göz seçilince:
//   - Aktif arıza yoksa → yeni kayıt modu
//       Segmented button (Arıza / Bakım)
//       Açıklama alanı
//       "Arıza Bildir" butonu
//   - Aktif arıza varsa → sonlandır modu
//       Aktif kayıt bilgisi (amber banner)
//       Açıklama alanı (opsiyonel not)
//       "Kaydı Sonlandır" butonu
//   - Her iki modda da arıza geçmişi listelenir
//
// Sınıf: Class B

part of 'fault_view.dart';

class FaultPanel extends StatelessWidget {
  const FaultPanel({
    super.key,
    required this.isSaving,
    required this.descriptionController,
    required this.onStatusChanged,
    required this.onSubmit,
    this.panelState,
  });

  final bool isSaving;
  final FaultPanelState? panelState;
  final TextEditingController descriptionController;
  final ValueChanged<int> onStatusChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (isSaving) return const _SavingContent();
    final s = panelState;
    if (s == null) return const _PlaceholderContent();
    return _CellSelectedContent(
      state: s,
      descriptionController: descriptionController,
      onStatusChanged: onStatusChanged,
      onSubmit: onSubmit,
    );
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
            child: Icon(Icons.touch_app_rounded, size: 22, color: MedColors.text4),
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
            'Arıza bildirmek için orta\npanelden bir göz seçin.',
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
    required this.descriptionController,
    required this.onStatusChanged,
    required this.onSubmit,
  });

  final FaultPanelState state;
  final TextEditingController descriptionController;
  final ValueChanged<int> onStatusChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Aktif arıza varsa → amber banner
          if (!state.isNewRecord) ...[_ActiveFaultBanner(fault: state.activeFault!), const SizedBox(height: 14)],

          // Yeni kayıt modunda → segmented button
          if (state.isNewRecord) ...[
            _StatusSegmentedButton(selectedStatus: state.selectedStatus, onChanged: onStatusChanged),
            const SizedBox(height: 14),
          ],

          // Açıklama
          _DescriptionField(controller: descriptionController),
          const SizedBox(height: 14),

          // Geçmiş
          if (state.faultHistory.isNotEmpty) ...[
            _FaultHistory(history: state.faultHistory),
            const SizedBox(height: 14),
          ],

          // Submit butonu
          _SubmitButton(isNewRecord: state.isNewRecord, canSubmit: state.canSubmit, onTap: onSubmit),
        ],
      ),
    );
  }
}

class _ActiveFaultBanner extends StatelessWidget {
  const _ActiveFaultBanner({required this.fault});

  final IFaultRecord fault;

  @override
  Widget build(BuildContext context) {
    final label = fault.workingStatus == CabinWorkingStatus.maintenance ? 'bakım' : 'arıza';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MedColors.amberLight,
        border: Border.all(color: MedColors.amber, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: MedColors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu gözdde aktif bir $label kaydı bulunmaktadır. '
              'Onayladığınızda bu kayıt sonlandırılacaktır.',
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF92520A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSegmentedButton extends StatelessWidget {
  const _StatusSegmentedButton({required this.selectedStatus, required this.onChanged});

  final CabinWorkingStatus selectedStatus;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final isFaulty = selectedStatus == CabinWorkingStatus.faulty;

    return Container(
      decoration: BoxDecoration(
        color: MedColors.surface2,
        border: Border.all(color: MedColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'ARIZA',
              isSelected: isFaulty,
              selectedColor: MedColors.red,
              selectedBg: MedColors.redLight,
              isLeft: true,
              onTap: () => onChanged(0),
            ),
          ),
          Container(width: 1.5, height: 36, color: MedColors.border),
          Expanded(
            child: _SegmentButton(
              label: 'BAKIM',
              isSelected: !isFaulty,
              selectedColor: MedColors.amber,
              selectedBg: MedColors.amberLight,
              isLeft: false,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedBg,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedBg;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? const Radius.circular(6) : Radius.zero,
            bottomLeft: isLeft ? const Radius.circular(6) : Radius.zero,
            topRight: !isLeft ? const Radius.circular(6) : Radius.zero,
            bottomRight: !isLeft ? const Radius.circular(6) : Radius.zero,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isSelected ? selectedColor : MedColors.text3,
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AÇIKLAMA',
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 3,
          style: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text),
          decoration: InputDecoration(
            hintText: 'Arıza detayını yazın...',
            hintStyle: TextStyle(fontFamily: MedFonts.sans, fontSize: 13, color: MedColors.text4),
            filled: true,
            fillColor: MedColors.surface2,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: MedColors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaultHistory extends StatelessWidget {
  const _FaultHistory({required this.history});

  final List<IFaultRecord> history;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GEÇMİŞ',
          style: TextStyle(
            fontFamily: MedFonts.mono,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 1,
            color: MedColors.text3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(maxHeight: 160),
          decoration: BoxDecoration(
            border: Border.all(color: MedColors.border, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: history.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: MedColors.border2),
              itemBuilder: (context, i) => _FaultHistoryItem(fault: history[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaultHistoryItem extends StatelessWidget {
  const _FaultHistoryItem({required this.fault});

  final IFaultRecord fault;

  @override
  Widget build(BuildContext context) {
    final isResolved = fault.endDate != null;
    final isActive = !isResolved;
    final isMaintenance = fault.workingStatus == CabinWorkingStatus.maintenance;

    final Color accentColor;
    final String statusLabel;

    if (isResolved) {
      accentColor = MedColors.green;
      statusLabel = 'Tamamlandı';
    } else if (isMaintenance) {
      accentColor = MedColors.amber;
      statusLabel = 'Bakım';
    } else {
      accentColor = MedColors.red;
      statusLabel = 'Arıza';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: isActive ? accentColor.withOpacity(0.04) : Colors.transparent,
      child: Row(
        children: [
          // Sol şerit
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontFamily: MedFonts.sans,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accentColor,
                      ),
                    ),
                    const Spacer(),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Aktif',
                          style: TextStyle(
                            fontFamily: MedFonts.mono,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: accentColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(fault.startDate),
                  style: TextStyle(fontFamily: MedFonts.mono, fontSize: 9, color: MedColors.text3),
                ),
                if (fault.description != null && fault.description!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fault.description!,
                    style: MedTextStyles.bodySm(color: MedColors.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isNewRecord, required this.canSubmit, required this.onTap});

  final bool isNewRecord;
  final bool canSubmit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = isNewRecord ? 'Arıza Bildir' : 'Kaydı Sonlandır';
    final icon = isNewRecord ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded;
    final color = isNewRecord ? MedColors.red : MedColors.green;
    final bg = isNewRecord ? MedColors.red : MedColors.green;

    return GestureDetector(
      onTap: canSubmit ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        decoration: BoxDecoration(
          color: canSubmit ? bg : MedColors.surface3,
          border: Border.all(color: canSubmit ? color : MedColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: canSubmit
              ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: canSubmit ? Colors.white : MedColors.text4),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: MedFonts.sans,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: canSubmit ? Colors.white : MedColors.text4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
