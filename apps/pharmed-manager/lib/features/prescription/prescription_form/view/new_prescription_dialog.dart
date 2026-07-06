// [SWREQ-MGR-RX-FORM-002] [IEC 62304 §5.5]
// Reçete oluşturma workspace dialog'u — üç-kolon layout.
// Sınıf: Class B (reçete oluşturma akışı)

import 'package:flutter/material.dart';
import 'package:pharmed_manager/core/core.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../../prescription.dart';
import '../notifier/prescription_template_notifier.dart';

part 'prescription_content_view.dart';
part 'prescription_history_view.dart';
part 'prescription_template_view.dart';
part 'prescription_form_view.dart';
part 'prescription_dialog_widgets.dart';

/// Reçete oluşturma dialog'unu açar. Workspace stili — geniş, padding'li,
/// dışa tıklama ile kapanmaz.
Future<void> showPrescriptionFormDialog(BuildContext context, {Hospitalization? hospitalization}) {
  final initial = hospitalization ?? context.read<PrescriptionNotifier>().selectedHospitalization;

  return showMedDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => PrescriptionFormNotifier(
            useCase: ctx.read(),
            hospitalization: initial,
            authNotifier: ctx.read(),
            templateUseCase: ctx.read(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PrescriptionHistoryNotifier(useCase: ctx.read())..setPatient(initial?.patient?.id),
        ),

        ChangeNotifierProvider(
          create: (ctx) =>
              PrescriptionTemplatesNotifier(listUseCase: context.read(), itemsUseCase: context.read())..fetch(),
        ),
      ],
      child: const _NewPrescriptionDialog(),
    ),
  );
}

class _NewPrescriptionDialog extends StatelessWidget {
  const _NewPrescriptionDialog();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = (size.width * 0.85).clamp(1200.0, 1600.0);

    return MedDialog(
      title: 'Yeni Reçete',
      subtitle: 'Reçete oluştur veya geçmiş reçeteden içe aktar',
      icon: PhosphorIcons.notepad(),
      width: width,
      maxHeightFactor: 0.85,
      padded: false,
      child: const Column(
        children: [
          MetadataBar(),
          Divider(height: 1, color: MedColors.border2),
          Expanded(child: _ThreeColumnBody()),
          Divider(height: 1, color: MedColors.border2),
          Footer(),
        ],
      ),
    );
  }
}

class _ThreeColumnBody extends StatelessWidget {
  const _ThreeColumnBody();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 340,
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  indicatorWeight: 1,
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Text('Geçmiş', style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Tab(
                      child: Text('Şablonlar', style: MedTextStyles.bodyMd().copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Expanded(child: TabBarView(children: [PrescriptionHistoryView(), PrescriptionTemplateView()])),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, color: MedColors.border2),
        Expanded(child: PrescriptionContentView()),
        const VerticalDivider(width: 1, color: MedColors.border2),
        SizedBox(width: 440, child: PrescriptionFormView()),
      ],
    );
  }
}
