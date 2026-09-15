import 'package:flutter/widgets.dart';
import 'package:pharmed_ui/pharmed_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

// TODO : Localization + Generic

class NoSelectedHospitalizationView extends StatelessWidget {
  const NoSelectedHospitalizationView({super.key, this.description});

  final String? description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            spacing: 12.0,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                spacing: 4.0,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 15,
                        decoration: BoxDecoration(color: MedColors.border, borderRadius: MedRadius.midAll),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 15,
                        decoration: BoxDecoration(color: MedColors.border2, borderRadius: MedRadius.midAll),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 15,
                        decoration: BoxDecoration(color: MedColors.border, borderRadius: MedRadius.midAll),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(PhosphorIcons.arrowRight(), color: MedColors.blueLight2),
              Container(
                width: 70,
                height: 85,
                decoration: BoxDecoration(color: MedColors.blueLight, borderRadius: MedRadius.mdAll),
                child: Icon(PhosphorIcons.userPlus(), color: MedColors.blue),
              ),
            ],
          ),
          SizedBox(height: 12.0),
          Text(context.l10n.emptyState_noPatientSelectedTitle, style: MedTextStyles.titleMd()),
          SizedBox(height: 6.0),
          Text(
            description ??
                'İade işlemi hasta bazında yürütülür. Soldaki listeden bir hasta\nseçtiğinizde, o hastaya uygulanmış ve iade edilebilir ilaçlar burada listelenir.',
            textAlign: TextAlign.center,
            style: MedTextStyles.bodySm(),
          ),
        ],
      ),
    );
  }
}
