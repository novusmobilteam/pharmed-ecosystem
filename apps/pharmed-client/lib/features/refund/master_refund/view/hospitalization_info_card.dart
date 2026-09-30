part of 'master_refund_view.dart';

/// Hasta seçimli kabin ekranlarının (alım, iade, ileride imha) sağ panelinin
/// üstündeki hasta bilgi kartı. Ekrana özgü kontroller (ör. alımdaki
/// "Serbest İlaç" toggle'ı) [trailing] slotuna verilir.
///
/// Alımdaki `_StandartHospitalizationInfo`'dan çıkarıldı. Oradaki açıklama
/// satırı null alanlarda "null - null" basıyordu; burada yalnızca dolu
/// parçalar birleştirilir.
class HospitalizationInfoCard extends StatelessWidget {
  const HospitalizationInfoCard({super.key, required this.hospitalization, this.trailing});

  final Hospitalization hospitalization;
  final Widget? trailing;

  String get _description => [
    hospitalization.inpatientService?.name,
    hospitalization.bed?.room?.name,
    hospitalization.bed?.name,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' - ');

  @override
  Widget build(BuildContext context) {
    final patient = hospitalization.patient;
    final description = _description;

    return Container(
      margin: const EdgeInsets.only(bottom: MedSpacing.lg),
      padding: MedSpacing.insetLg,
      decoration: MedDecoration.panelDecoration,
      child: Row(
        spacing: MedSpacing.lg,
        children: [
          MedAvatar(
            initials: patient?.initials ?? '',
            palette: AvatarPalette.blue,
            size: 48,
            shape: BoxShape.rectangle,
          ),
          Expanded(
            child: Column(
              spacing: MedSpacing.xs,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient?.fullName ?? '', style: MedTextStyles.titleLg(), overflow: TextOverflow.ellipsis),
                if (description.isNotEmpty)
                  Text(description, style: MedTextStyles.monoMd(), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (trailing case final trailing?) trailing,
        ],
      ),
    );
  }
}
