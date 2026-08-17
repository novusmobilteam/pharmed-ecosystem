part of 'drug_assignment_view.dart';

class InitialSection extends StatelessWidget {
  const InitialSection({super.key, required this.assignments, this.onRowTap});

  final List<MedicineAssignment> assignments;
  final void Function(DrawerUnit, int?)? onRowTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kabin Yapılandırma', style: MedTextStyles.monoMd(color: MedColors.blueDark)),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
              child: Text('İlaç Atama', style: MedTextStyles.titleXl().copyWith()),
            ),
            Text(
              'Soldaki kabinden bir göze dokunun;o göze ilaç listesinden seçim yapıp minimum, kritik ve maksimum miktarları girin.\nDolu bir göze dokunarak mevcut atamayı düzenleyebilirsiniz',
              style: MedTextStyles.bodyMd(),
            ),
          ],
        ),
        SizedBox(height: 24.0),
        Divider(color: MedColors.text2, height: 1, thickness: 2),
        SizedBox(height: 12.0),
        // Tablo title
        Text('Mevcut Atamalar', style: MedTextStyles.titleMd()),
        SizedBox(height: 16.0),
        // Tablo başlıkları
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 2, child: Text('Konum', style: MedTextStyles.titleSm())),
            Expanded(flex: 3, child: Text('İlaç', style: MedTextStyles.titleSm())),
            Expanded(child: Text('Min', style: MedTextStyles.titleSm())),
            Expanded(child: Text('Maks', style: MedTextStyles.titleSm())),
            Expanded(child: Text('Kritik', style: MedTextStyles.titleSm())),
            Expanded(child: Opacity(opacity: 0, child: Text('Düzenle'))),
          ],
        ),
        SizedBox(height: 6.0),
        Divider(color: MedColors.text4, height: 1, thickness: 1),
        Expanded(
          child: ListView.builder(
            itemCount: assignments.length,

            itemBuilder: (BuildContext context, int index) {
              final ass = assignments.elementAt(index);
              final konum = ass.isKubikType
                  ? 'Çekmece ${ass.drawerUnit?.drawerSlot?.address} - Satır ${ass.drawerUnit?.compartmentNo} - Sütun ${ass.drawerUnit?.orderNo}'
                  : 'Çekmece ${ass.drawerUnit?.drawerSlot?.address} - Göz ${ass.drawerUnit?.compartmentNo}';
              final unit = ass.operationUnit;
              final min = '${ass.minQuantity} $unit';
              final max = '${ass.maxQuantity} $unit';
              final crit = '${ass.criticalQuantity} $unit';

              return GestureDetector(
                onTap: () => onRowTap!(ass.drawerUnit!, index),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: MedColors.border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text(konum, style: MedTextStyles.bodyMd())),
                      Expanded(
                        flex: 3,
                        child: Text(ass.medicine?.name ?? '-', style: MedTextStyles.bodyLg(weight: FontWeight.bold)),
                      ),
                      Expanded(child: Text(min, style: MedTextStyles.bodyMd())),
                      Expanded(child: Text(max, style: MedTextStyles.bodyMd())),
                      Expanded(child: Text(crit, style: MedTextStyles.bodyMd())),
                      Expanded(
                        child: Text('Düzenle', style: MedTextStyles.monoMd(color: MedColors.blue)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
