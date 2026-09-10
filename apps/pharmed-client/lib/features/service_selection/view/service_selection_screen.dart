import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../notifier/active_service_notifier.dart';

/// İstasyon birden fazla servise hizmet
/// verdiğinde (login sonrası ya da dashboard'dan "servis değiştir"
/// tetiklendiğinde) zorunlu servis seçim ekranı. `ActiveServiceGate`
/// `requiresSelection == true` olduğu her an bu ekranı gösterir; hem
/// ilk giriş hem de oturum içi servis değişimi aynı ekranı kullanır.

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  const ServiceSelectionScreen({super.key});

  @override
  ConsumerState<ServiceSelectionScreen> createState() => _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState extends ConsumerState<ServiceSelectionScreen> {
  HospitalService? _pendingSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeService = ref.watch(activeServiceNotifierProvider);
    final station = activeService.station;
    final canConfirm = _pendingSelection != null;

    return Scaffold(
      backgroundColor: MedColors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: MedSpacing.insetXl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  Text(l10n.serviceSelection_screenTitle, style: MedTextStyles.titleXl()),
                  SizedBox(height: MedSpacing.xs),
                  if (station != null)
                    Text(l10n.serviceSelection_subtitle(station.name ?? ''), style: MedTextStyles.bodyMd()),
                  SizedBox(height: MedSpacing.xl3),
                  if (activeService.isLoadingServices)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (activeService.availableServices.isEmpty)
                    Text(l10n.serviceSelection_loadErrorMessage, style: MedTextStyles.bodyMd())
                  else
                    _ServiceGrid(
                      services: activeService.availableServices,
                      selected: _pendingSelection,
                      onSelect: (service) => setState(() => _pendingSelection = service),
                    ),
                  Spacer(),
                  if (!activeService.isLoadingServices && activeService.availableServices.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: MedButton(
                        onPressed: canConfirm
                            ? () => ref.read(activeServiceNotifierProvider).selectService(_pendingSelection!)
                            : null,
                        label: l10n.serviceSelection_confirmButton,
                      ),
                    ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.services, required this.selected, required this.onSelect});

  final List<HospitalService> services;
  final HospitalService? selected;
  final ValueChanged<HospitalService> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: MedSpacing.lg,
        crossAxisSpacing: MedSpacing.lg,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return _ServiceCard(service: service, isSelected: selected?.id == service.id, onTap: () => onSelect(service));
      },
    );
  }
}

/// Wizard'ın "Kabin Seçim Adımı" kart deseniyle tutarlı: seçili kart mavi
/// border + hafif mavi zemin + checkmark rozeti, seçilmemiş kart nötr border.
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.isSelected, required this.onTap});

  final HospitalService service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? MedColors.blue.withOpacity(0.08) : MedColors.surface,
      borderRadius: MedRadius.lgAll,
      child: InkWell(
        borderRadius: MedRadius.lgAll,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: MedSpacing.touchTarget * 1.8),
          padding: MedSpacing.insetLg,
          decoration: BoxDecoration(
            border: Border.all(color: isSelected ? MedColors.blue : MedColors.border, width: isSelected ? 2 : 1.5),
            borderRadius: MedRadius.lgAll,
          ),
          child: Stack(
            children: [
              Center(
                child: Text(service.name ?? '', style: MedTextStyles.titleMd(), textAlign: TextAlign.center),
              ),
              if (isSelected)
                const Positioned(top: 0, right: 0, child: Icon(Icons.check_circle, color: MedColors.blue, size: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
