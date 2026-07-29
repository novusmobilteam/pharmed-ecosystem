// Master kabin dolum/sayım execution ekranlarının ortak form gövdesi.
// MasterRefillExecutionPanel._FillForm + MasterCensusExecutionPanel._CensusForm
// birleştirildi. İki bağımsız eksen parametreleştirildi:
//   - Çekmece tipi (kübik = tek giriş, birim doz = N giriş) → isKubik
//   - Operasyon tipi (dolum vs sayım) → showFilling (dolum alanının olup
//     olmadığı, kart seviyesinde uygulanır)
//
// Kartların kendisini de burada çiziyoruz (CabinCellInputCard) — çağıran
// panel yalnızca CabinCellEntry listesi + index bazlı callback'ler verir,
// widget ağacıyla hiç uğraşmaz. Tek-SKT (isPerCellMiadEnabled=false) header'ı
// da burada kurulur — çağıran yalnızca singleMiadDate + onSingleMiadChanged verir.
//
// Sınıf: Class B

import 'package:flutter/material.dart';
import 'package:pharmed_ui/pharmed_ui.dart';

import '../cabin_shell_widgets.dart';

// execution/cabin_operation_cell_template.dart
// Kübik/birimdoz form GÖVDESİ — artık hücre İÇERİĞİNİ bilmiyor. Sadece:
//   - kübik mi (tek kart, ortalı, scrollable) / birimdoz mu (grid) ayrımı
//   - opsiyonel "header" slotu (grid'in üstünde, gridden bağımsız — dolumun
//     tek-SKT fallback'i gibi ekrana özel şeyler için)
//   - isLocked opacity/ignore-pointer + confirm butonu
// Hücrenin İÇİNİ (hangi MedValueCard'lar, kaçı, SKT var mı) artık ekran
// çiziyor — bu widget tek bir MedValueCard mı 3 tane mi geldiğini hiç bilmez.
//
// Sınıf: Class B

class CabinExecutionGrid extends StatelessWidget {
  const CabinExecutionGrid({
    super.key,
    required this.maxWidth,
    required this.isLocked,
    required this.isKubik,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.targetItemWidth = 300,
    required this.canConfirm,
    required this.isSaving,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final double maxWidth;
  final bool isLocked;

  /// true → tek kart (itemCount genelde 1, `itemBuilder(context, 0)`),
  /// scrollable Column içinde ortalanır. false → grid.
  final bool isKubik;

  final int itemCount;

  /// Bir hücrenin TÜM içeriğini üretir — assignment başlığı, sayım/dolum/
  /// SKT alanları dahil. Ekran kendi MedValueCard kompozisyonunu burada
  /// kurar; template bunun içine hiç karışmaz.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Grid'in ÜSTÜNDE, gridden bağımsız opsiyonel slot (ör. dolumun tek-SKT
  /// header'ı). Yalnızca isKubik:false iken render edilir — kübikte zaten
  /// tek kart var, ayrı header'a gerek yok. null → hiç render edilmez.
  final WidgetBuilder? header;

  final double targetItemWidth;
  final bool canConfirm;
  final bool isSaving;
  final String confirmLabel;
  final Future<void> Function() onConfirm;

  Widget _buildContent(BuildContext context) {
    if (isKubik) {
      if (itemCount == 0) return const SizedBox.shrink();
      return SingleChildScrollView(child: itemBuilder(context, 0));
    }

    Widget grid() => CabinOperationGrid(
      itemCount: itemCount,
      targetItemWidth: targetItemWidth,
      itemBuilder: itemBuilder,
      // header varsa dış Column zaten Expanded ile scroll'u yönetiyor —
      // grid'in kendi içinde ikinci bir scroll açmasın.
      shrinkWrap: header != null,
      physics: header != null ? const NeverScrollableScrollPhysics() : null,
    );

    if (header == null) return grid();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        header!(context),
        Expanded(child: grid()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Opacity(
                opacity: isLocked ? 0.55 : 1.0,
                child: IgnorePointer(ignoring: isLocked, child: _buildContent(context)),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: MedButton(
                label: confirmLabel,
                size: MedButtonSize.lg,
                isLoading: isSaving,
                onPressed: canConfirm ? () => onConfirm() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
