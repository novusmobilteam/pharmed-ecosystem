part of 'step5_summary.dart';

class CabinInfoCard extends StatelessWidget {
  const CabinInfoCard({super.key, required this.draft});
  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final info = draft.basicInfo!;
    final isMobile = draft.cabinType == CabinType.mobile;

    return SummaryCard(
      title: 'KABİN BİLGİLERİ',
      children: [
        SummaryRow(label: 'Tip', value: isMobile ? 'Mobil Kabin' : 'Standart Kabin', valueColor: MedColors.blue),
        _Divider(),
        SummaryRow(label: 'İsim', value: info.cabinName),

        if (!isMobile) ...[_Divider(), SummaryRow(label: 'COM Port', value: info.comPort ?? '—')],
        if (info.dvrIp != null && info.dvrIp!.isNotEmpty) ...[
          _Divider(),
          SummaryRow(label: 'DVR IP', value: info.dvrIp!),
        ],

        if (info.rfidIpAddress != null && info.rfidPort!.isNotEmpty) ...[
          _Divider(),
          SummaryRow(label: 'RFID Adresi', value: info.rfidIpAddress!),
          SummaryRow(label: 'RFID Portu', value: info.rfidPort!),
        ],
      ],
    );
  }
}

class ServiceScopeCard extends StatelessWidget {
  const ServiceScopeCard({super.key, required this.draft});
  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final scope = draft.serviceScope!;

    return SummaryCard(
      title: 'HİZMET KAPSAMI',
      children: switch (scope) {
        StandartScope(:final station) => [
          SummaryRow(label: 'İstasyon', value: station.name ?? '-', valueColor: MedColors.blue),
        ],
        MobileScope(:final rooms) => [
          SummaryRow(label: 'Oda sayısı', value: '${rooms.length}', valueColor: MedColors.green),
          _Divider(),
          SummaryRow(label: 'Odalar', value: rooms.map((r) => r.name).join(', ')),
          _Divider(),
          SummaryRow(label: 'Yataklar', value: rooms.map((r) => r.beds.map((b) => b.name)).join(', ')),
        ],
      },
    );
  }
}

class DrawerStructureCard extends StatelessWidget {
  const DrawerStructureCard({super.key, required this.draft});

  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final isMobile = draft.cabinType == CabinType.mobile;

    if (isMobile) {
      final layout = draft.mobileLayout!;
      return SummaryCard(
        title: 'ÇEKMECE YAPISI',
        children: [
          SummaryRow(label: 'Çekmece sayısı', value: '${layout.drawerCount}', valueColor: MedColors.green),
          _Divider(),
          for (final drawer in layout.drawers) ...[
            SummaryRow(
              label: '${drawer.drawerIndex + 1}. Çekmece',
              value: drawer.rowColumns.map((c) => '$c').join(' / '),
            ),
            if (drawer.drawerIndex < layout.drawers.length - 1) _Divider(),
          ],
        ],
      );
    }

    final layout = draft.scannedLayout!;
    return SummaryCard(
      title: 'ÇEKMECE YAPISI',
      children: [
        SummaryRow(label: 'Toplam çekmece', value: '${layout.length}', valueColor: MedColors.green),
        _Divider(),
        for (int i = 0; i < layout.length; i++) ...[
          SummaryRow(label: '${i + 1}. Çekmece', value: layout[i].slot.drawerConfig?.drawerType?.name ?? '—'),
          if (i < layout.length - 1) _Divider(),
        ],
      ],
    );
  }
}

class CabinPreviewCard extends StatelessWidget {
  const CabinPreviewCard({super.key, required this.draft});

  final WizardDraft draft;

  @override
  Widget build(BuildContext context) {
    final isMobile = draft.cabinType == CabinType.mobile;

    return SummaryCard(
      title: 'KABİN ÖNİZLEMESİ',
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: isMobile
                ? _MobileCabinPreview(layout: draft.mobileLayout!)
                : _StandardCabinPreview(drawerCount: draft.scannedLayout?.length ?? 0),
          ),
        ),
      ],
    );
  }
}

/// Standart kabin — çekmece sayısına göre basit SVG benzeri önizleme
class _StandardCabinPreview extends StatelessWidget {
  const _StandardCabinPreview({required this.drawerCount});
  final int drawerCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE2ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB8C6D6)),
      ),
      child: Column(
        children: [
          // Üst panel
          Container(
            height: 12,
            decoration: BoxDecoration(color: const Color(0xFFC8D4E4), borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 4),
          // Çekmeceler
          for (int i = 0; i < drawerCount.clamp(0, 5); i++) ...[
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEDF1F8),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: const Color(0xFFC8D2E0)),
              ),
              child: Center(
                child: Container(
                  width: 20,
                  height: 3,
                  decoration: BoxDecoration(color: const Color(0xFF9AADC0), borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),
            if (i < drawerCount - 1) const SizedBox(height: 3),
          ],
          const SizedBox(height: 4),
          // Tekerlekler
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_Wheel(), _Wheel(), _Wheel()]),
        ],
      ),
    );
  }
}

/// Mobil kabin — çekmece grid önizlemesi
class _MobileCabinPreview extends StatelessWidget {
  const _MobileCabinPreview({required this.layout});
  final WizardMobileLayout layout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFD4DCEA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB8C6D6)),
      ),
      child: Column(
        children: [
          // Üst panel
          Container(
            height: 10,
            decoration: BoxDecoration(color: const Color(0xFFBCCAD8), borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 4),
          // Çekmece satırları (maks 4 göster)
          for (int i = 0; i < layout.drawerCount.clamp(0, 4); i++) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F8),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: const Color(0xFFC8D2E0)),
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F8),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: const Color(0xFFC8D2E0)),
                    ),
                  ),
                ),
              ],
            ),
            if (i < layout.drawerCount - 1) const SizedBox(height: 3),
          ],
          const SizedBox(height: 6),
          // Tekerlekler
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Wheel(), _Wheel()]),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 6,
      decoration: BoxDecoration(color: const Color(0xFF8090A8), borderRadius: BorderRadius.circular(3)),
    );
  }
}
