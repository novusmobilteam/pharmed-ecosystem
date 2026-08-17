part of 'dashboard_screen.dart';

class KpiView extends StatelessWidget {
  const KpiView({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
          4,
          (index) => Expanded(
            child: _KpiCard(title: 'Toplam Stok', value: '1248', index: index),
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({super.key, required this.title, required this.value, this.color, required this.index});

  final String title;
  final String value;
  final Color? color;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(left: 12.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: index != 3 ? Border(right: BorderSide(color: MedColors.border)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: MedTextStyles.monoMd()),
          Text(value, style: MedTextStyles.titleXl(color: color)),
        ],
      ),
    );
  }
}
