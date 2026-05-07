part of '../view/step5_view.dart';

class CabinInfoCard extends StatelessWidget {
  const CabinInfoCard({super.key, required this.cabinType, required this.basicInfo});

  final CabinType? cabinType;
  final WizardBasicInfo? basicInfo;

  @override
  Widget build(BuildContext context) {
    final info = basicInfo;
    if (info == null) return const SizedBox.shrink();

    final isMobile = cabinType == CabinType.mobile;

    return SummaryCard(
      title: context.l10n.wizard_summaryCabinInfoTitle,
      children: [
        SummaryRow(
          label: context.l10n.wizard_summaryLabelType,
          value: isMobile ? context.l10n.wizard_summaryTypeMobile : context.l10n.wizard_summaryTypeStandard,
          valueColor: MedColors.blue,
        ),
        _Divider(),
        SummaryRow(label: context.l10n.wizard_summaryLabelName, value: info.cabinName),
        if (!isMobile) ...[
          _Divider(),
          SummaryRow(
            label: context.l10n.wizard_summaryLabelComPort,
            value: info.comPort!.isNotEmpty ? info.comPort! : '—',
          ),
        ],
        if (info.dvrIp?.isNotEmpty ?? false) ...[
          _Divider(),
          SummaryRow(label: context.l10n.wizard_summaryLabelDvrIp, value: info.dvrIp.toString()),
        ],
        if (info.rfidEnable && (info.rfidIpAddress?.isNotEmpty ?? false)) ...[
          _Divider(),
          SummaryRow(label: context.l10n.wizard_summaryLabelRfidAddress, value: info.rfidIpAddress.toString()),
          SummaryRow(label: context.l10n.wizard_summaryLabelRfidPort, value: info.rfidPort.toString()),
        ],
      ],
    );
  }
}

class ServiceScopeCard extends StatelessWidget {
  const ServiceScopeCard({super.key, required this.serviceScope});

  final StationScope? serviceScope;

  @override
  Widget build(BuildContext context) {
    final scope = serviceScope;
    if (scope == null) return const SizedBox.shrink();

    return SummaryCard(
      title: context.l10n.wizard_summaryServiceScopeTitle,
      children: switch (scope) {
        StandartScope(:final station) => [
          SummaryRow(
            label: context.l10n.wizard_summaryLabelStation,
            value: station.name ?? '-',
            valueColor: MedColors.blue,
          ),
        ],
        MobileScope(:final rooms) => [
          SummaryRow(
            label: context.l10n.wizard_summaryLabelRoomCount,
            value: '${rooms.length}',
            valueColor: MedColors.green,
          ),
          _Divider(),
          SummaryRow(label: context.l10n.wizard_summaryLabelRooms, value: rooms.map((r) => r.name).join(', ')),
        ],
      },
    );
  }
}

class DrawerStructureCard extends StatelessWidget {
  const DrawerStructureCard({
    super.key,
    required this.cabinType,
    required this.scannedLayout,
    required this.mobileLayout,
  });

  final CabinType? cabinType;
  final List<DrawerGroup> scannedLayout;
  final WizardMobileLayout mobileLayout;

  @override
  Widget build(BuildContext context) {
    final isMobile = cabinType == CabinType.mobile;

    if (isMobile) {
      return SummaryCard(
        title: context.l10n.wizard_summaryDrawerStructureTitle,
        children: [
          SummaryRow(
            label: context.l10n.wizard_summaryLabelDrawerCount,
            value: '${mobileLayout.drawerCount}',
            valueColor: MedColors.green,
          ),
          _Divider(),
          for (final drawer in mobileLayout.drawers) ...[
            SummaryRow(
              label: context.l10n.wizard_summaryLabelDrawerIndexed(drawer.drawerIndex + 1),
              value: drawer.rowColumns.map((c) => '$c').join(' / '),
            ),
            if (drawer.drawerIndex < mobileLayout.drawers.length - 1) _Divider(),
          ],
        ],
      );
    }

    return SummaryCard(
      title: context.l10n.wizard_summaryDrawerStructureTitle,
      children: [
        SummaryRow(
          label: context.l10n.wizard_summaryLabelTotalDrawers,
          value: '${scannedLayout.length}',
          valueColor: MedColors.green,
        ),
        _Divider(),
        for (int i = 0; i < scannedLayout.length; i++) ...[
          SummaryRow(
            label: context.l10n.wizard_summaryLabelDrawerIndexed(i + 1),
            value: scannedLayout[i].slot.drawerConfig?.drawerType?.name ?? '—',
          ),
          if (i < scannedLayout.length - 1) _Divider(),
        ],
      ],
    );
  }
}

class CabinPreviewCard extends StatelessWidget {
  const CabinPreviewCard({super.key, required this.cabinType, required this.mobileLayout, required this.scannedLayout});

  final CabinType? cabinType;
  final WizardMobileLayout mobileLayout;
  final List<DrawerGroup> scannedLayout;

  @override
  Widget build(BuildContext context) {
    final isMobile = cabinType == CabinType.mobile;

    return SummaryCard(
      title: context.l10n.wizard_summaryCabinPreviewTitle,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: isMobile
                ? _MobileCabinPreview(layout: mobileLayout)
                : _StandardCabinPreview(drawerCount: scannedLayout.length),
          ),
        ),
      ],
    );
  }
}

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
          Container(
            height: 12,
            decoration: BoxDecoration(color: const Color(0xFFC8D4E4), borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 4),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_Wheel(), _Wheel(), _Wheel()]),
        ],
      ),
    );
  }
}

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
          Container(
            height: 10,
            decoration: BoxDecoration(color: const Color(0xFFBCCAD8), borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(height: 4),
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
