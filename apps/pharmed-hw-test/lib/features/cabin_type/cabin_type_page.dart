import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../../core/cabin_type.dart';
import '../../core/providers.dart';
import '../../core/report.dart';

/// Giriş sonrası teknisyen test edeceği kabin tipini seçer. Seçim menüde hangi
/// testlerin görüneceğini belirler; üst çubuktan sonradan değiştirilebilir.
class CabinTypePage extends ConsumerWidget {
  const CabinTypePage({super.key});

  void _select(WidgetRef ref, HwCabinType type) {
    ref.read(testReportProvider).add('Kabin tipi: ${type.label}', StepResult.info);
    ref.read(sessionProvider.notifier).setCabinType(type);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider.select((s) => s.user));
    return Scaffold(
      backgroundColor: MedColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(MedSpacing.xl3, MedSpacing.xl, MedSpacing.xl, 0),
              child: Row(
                children: [
                  Text('PharMed Donanım Testi', style: MedTextStyles.titleSm(color: MedColors.text2)),
                  const Spacer(),
                  Icon(Icons.person_outline, size: 18, color: MedColors.text3),
                  const SizedBox(width: MedSpacing.xs),
                  Text(user?.fullName ?? '-', style: MedTextStyles.bodyMd(color: MedColors.text2)),
                  const SizedBox(width: MedSpacing.md),
                  TextButton.icon(
                    onPressed: () => signOut(ref),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Çıkış'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MedSpacing.xl3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Hangi kabini test edeceksiniz?', style: MedTextStyles.titleXl(color: MedColors.text)),
                      const SizedBox(height: MedSpacing.md),
                      Text(
                        'Seçiminize göre yalnızca o kabinle ilgili testler gösterilir. '
                        'Daha sonra üst çubuktan değiştirebilirsiniz.',
                        style: MedTextStyles.bodyLg(color: MedColors.text2),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: MedSpacing.xl4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CabinTypeCard(
                            type: HwCabinType.medicineBased,
                            icon: Icons.medication_outlined,
                            onTap: () => _select(ref, HwCabinType.medicineBased),
                          ),
                          const SizedBox(width: MedSpacing.xl3),
                          _CabinTypeCard(
                            type: HwCabinType.patientBased,
                            icon: Icons.airport_shuttle_outlined,
                            onTap: () => _select(ref, HwCabinType.patientBased),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinTypeCard extends StatefulWidget {
  const _CabinTypeCard({required this.type, required this.icon, required this.onTap});

  final HwCabinType type;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CabinTypeCard> createState() => _CabinTypeCardState();
}

class _CabinTypeCardState extends State<_CabinTypeCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 360,
          padding: const EdgeInsets.all(MedSpacing.xl3),
          decoration: BoxDecoration(
            color: MedColors.surface,
            borderRadius: MedRadius.lgAll,
            border: Border.all(color: _hover ? MedColors.blue : MedColors.border, width: _hover ? 2 : 1),
            boxShadow: _hover ? MedShadows.md : MedShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.midAll),
                child: Icon(widget.icon, size: 28, color: MedColors.blue),
              ),
              const SizedBox(height: MedSpacing.xl),
              Text(type.label, style: MedTextStyles.titleLg(color: MedColors.text)),
              const SizedBox(height: MedSpacing.xs),
              Text(type.summary, style: MedTextStyles.bodyMd(color: MedColors.text2)),
              const SizedBox(height: MedSpacing.xl),
              for (final item in type.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: MedSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.check_circle_outline, size: 16, color: MedColors.green),
                      ),
                      const SizedBox(width: MedSpacing.md),
                      Expanded(child: Text(item, style: MedTextStyles.bodyMd(color: MedColors.text2))),
                    ],
                  ),
                ),
              const SizedBox(height: MedSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: widget.onTap,
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text('Bu kabinle başla')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
