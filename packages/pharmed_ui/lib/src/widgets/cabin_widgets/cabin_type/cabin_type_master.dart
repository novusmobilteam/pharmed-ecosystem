part of 'cabin_type_reference_view.dart';

class CabinTypeMaster extends StatelessWidget {
  const CabinTypeMaster({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MedSpacing.insetMd,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MedColors.border2,
        borderRadius: MedRadius.smAll,
        border: Border.all(color: MedColors.text3),
      ),
      child: Column(
        spacing: 4.0,
        children: [
          // Ekran
          Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: MedColors.text,
              borderRadius: MedRadius.smAll,
              border: Border.all(color: MedColors.border),
            ),
            child: Container(
              width: 65,
              height: 4,
              color: MedColors.blue,
              padding: MedSpacing.insetXl,
              alignment: Alignment.center,
            ),
          ),
          // Body
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 20,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: 4.0),
                  decoration: BoxDecoration(
                    color: MedColors.surface,
                    borderRadius: MedRadius.smAll,
                    border: Border.all(color: MedColors.border),
                  ),
                  child: Container(
                    width: 25,
                    height: 3,
                    color: MedColors.border,
                    padding: MedSpacing.insetXl,
                    alignment: Alignment.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
