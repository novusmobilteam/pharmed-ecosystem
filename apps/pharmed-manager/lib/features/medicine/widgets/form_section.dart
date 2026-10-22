part of '../view/drug_form_panel.dart';

/// İlaç formunda mantıksal alan grubu: başlık + ince ayraç + satırlar.
/// Kart/çerçeve yerine ayraç kullanılır; panel içinde iç içe kutu oluşmaz.
class _FormSection extends StatelessWidget {
  const _FormSection({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: MedSpacing.md,
          children: [
            Text(title, style: MedTextStyles.titleSm(color: MedColors.text)),
            const Expanded(child: Divider(height: 1, thickness: 1, color: MedColors.border2)),
          ],
        ),
        const SizedBox(height: MedSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppDimensions.registrationDialogSpacing,
          children: rows,
        ),
      ],
    );
  }
}

/// Alanları yan yana dizer. [flexes] verilmezse her alan eşit genişlik alır;
/// formun ızgarası 4 sütundur (ör. `[1, 3]` → 1 sütun anahtar + 3 sütun alan).
class _FormRow extends StatelessWidget {
  const _FormRow({required this.children, this.flexes}) : assert(flexes == null || flexes.length == children.length);

  final List<Widget> children;
  final List<int>? flexes;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppDimensions.registrationDialogSpacing,
      children: [
        for (var i = 0; i < children.length; i++) Expanded(flex: flexes?[i] ?? 1, child: children[i]),
      ],
    );
  }
}

/// Bir checkbox'ı satırdaki giriş alanlarıyla aynı geometriye oturtur:
/// görünmez bir etiket satırı + giriş kutusu yüksekliğinde dikey ortalama.
/// Böylece checkbox, yanındaki alanların etiketine değil kutusuna hizalanır;
/// uzun etiketler sütuna sığmazsa küçültülür (taşma olmaz).
class _InlineToggle extends StatelessWidget {
  const _InlineToggle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Text(' ', style: MedTextStyles.bodySm(color: MedColors.text2, weight: FontWeight.w600)),
        ),
        const SizedBox(height: MedSpacing.xs),
        SizedBox(
          height: InputFieldTheme.of(context).minHeight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: child),
          ),
        ),
      ],
    );
  }
}
