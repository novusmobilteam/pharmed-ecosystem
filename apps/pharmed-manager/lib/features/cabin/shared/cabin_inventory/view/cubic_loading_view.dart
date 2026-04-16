import 'package:flutter/material.dart';
import '../../cabin_assignment_picker/view/cabin_assignment_picker_view.dart';
import '../notifier/cabin_inventory_notifier.dart';
import 'package:provider/provider.dart';

import '../../../../../core/core.dart';
import 'cabin_input_quantity_field.dart';
import 'expired_banner_view.dart';
import 'quantity_info_card.dart';

// Kart container için ortak sabitler
const double _kCardPadding = 12.0;
const double _kCardRadius = 8.0;

class CubicLoadingView extends StatefulWidget {
  const CubicLoadingView({
    super.key,
    required this.data,
    required this.onMiadDateChanged,
    required this.onCountQuantityChanged,
    required this.onFillingQuantityChanged,
    required this.countQuantity,
    required this.fillingQuantity,
    required this.quantity,
    required this.type,
    required this.isExpired,
    this.plannedQuantity,
  });

  final MedicineAssignment data;
  final CabinInventoryType type;

  final Function(DateTime date) onMiadDateChanged;
  final Function(double quantity) onCountQuantityChanged;
  final Function(double quantity) onFillingQuantityChanged;

  final double countQuantity;
  final double fillingQuantity;
  final double quantity;
  // Dolum yapılması planlanan miktar. İlaç Dolum Listesi tarafında kullanılıyor
  final double? plannedQuantity;

  /// true ise stok mevcut ve miad geçmiş — miad ve miktar alanları kilitlenir.
  final bool isExpired;

  @override
  State<CubicLoadingView> createState() => _CubicLoadingViewState();
}

class _CubicLoadingViewState extends State<CubicLoadingView> {
  late final TextEditingController _dateController;

  /// Alanların kilitlenip kilitlenmeyeceğini belirler.
  ///
  /// Kilitleme sadece refill ve count tiplerinde geçerlidir.
  /// disposal/unload tiplerinde isExpired=true olsa bile kilitleme uygulanmaz —
  /// bu işlemlerin amacı zaten geçmiş miadlı ürünü sistemden çıkarmaktır.
  bool get _shouldLock => widget.isExpired && widget.type.shouldBlockOnExpiry;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: context.read<CabinInventoryNotifier>().miadDate?.formattedDate);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Geçmiş tarihli initialValue + firstDate=DateTime.now() Flutter exception fırlatır.
    // _shouldLock=false ise (firstDate aktif) sadece gelecek/bugün tarihli miad geçirilir.
    final miadDate = context.read<CabinInventoryNotifier>().miadDate;
    final safeInitialMiad = _shouldLock
        ? miadDate
        : (miadDate != null && !miadDate.isBefore(DateTime.now()))
        ? miadDate
        : null;

    final overrideQuantity = widget.data.toDisplayQuantity(widget.data.totalQuantity);

    return Column(
      spacing: 20,
      children: [
        QuantityInfoCard(
          data: widget.data,
          quantity: widget.quantity,
          type: widget.type,
          plannedQuantity: widget.plannedQuantity,
        ),
        _buildCard(
          padding: const EdgeInsets.all(_kCardPadding),
          child: RatioProgressIndicator(assignment: widget.data, overrideQuantity: overrideQuantity),
        ),

        // Miadı geçmiş stok varsa uyarı göster.
        // Banner tüm tipler için gösterilir; kilitleme sadece refill/count için.
        if (widget.isExpired && widget.type.shouldBlockOnExpiry) ExpiredBannerView(),

        // Miad ve miktar alanları: _shouldLock=true ise görünür ama kilitli.
        // disposal/unload tiplerinde _shouldLock=false — alanlar açık kalır.
        // Opacity görsel ipucu verir; IgnorePointer tüm dokunuşları engeller.
        Opacity(
          opacity: _shouldLock ? 0.4 : 1.0,
          child: IgnorePointer(
            ignoring: _shouldLock,
            child: Column(
              spacing: 20,
              children: [
                // Miad tarihi giriş alanı: refill/count için düzenlenebilir
                if (widget.type.enableMiadDateInput)
                  DateInputField(
                    label: 'Miad Tarihi',
                    // _shouldLock=true: alan kilitli, mevcut miad salt-okunur gösterilir.
                    //   - enabled=false → ek görsel kilit
                    //   - firstDate=null → geçmiş-tarih kısıtı anlamsız, kaldırılır
                    //   - controller=null → kilitli alanda controller bağlantısı gerekmez
                    // _shouldLock=false: normal akış, yalnızca gelecek tarih seçilebilir.
                    enabled: !_shouldLock,
                    //controller: _shouldLock ? null : _dateController,
                    initialValue: safeInitialMiad,
                    firstDate: _shouldLock ? null : DateTime.now(),
                    onDateSelected: (date) {
                      widget.onMiadDateChanged(date);
                      _dateController.text = date.formattedDate;
                    },
                  ),

                // Bilgilendirme amaçlı miad tarihi: disposal/unload için salt-okunur.
                // Bu tipler miad girişi gerektirmez ancak mevcut miad gösterilebilir.
                if (!widget.type.enableMiadDateInput && context.read<CabinInventoryNotifier>().miadDate != null)
                  DateInputField(
                    label: 'Mevcut Miad Tarihi',
                    enabled: false,
                    initialValue: context.read<CabinInventoryNotifier>().miadDate,
                    firstDate: null,
                    onDateSelected: (_) {},
                  ),

                _buildQuantitySection(widget.type),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Tüm kart container'larında ortak görünümü sağlar.
  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding,
      decoration: AppDimensions.cardDecoration(context).copyWith(borderRadius: BorderRadius.circular(_kCardRadius)),
      child: child,
    );
  }

  /// Sayım ve dolum miktar alanlarını içeren bölümü oluşturur.
  Widget _buildQuantitySection(CabinInventoryType type) {
    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          child: CabinInputQuantityField(
            data: widget.data,
            type: widget.type,
            isCountField: true,
            useTotalLabel: true,
            value: widget.countQuantity,
            onChanged: widget.onCountQuantityChanged,
          ),
        ),
        if (widget.type != CabinInventoryType.count)
          Expanded(
            child: CabinInputQuantityField(
              data: widget.data,
              type: widget.type,
              isCountField: false,
              value: widget.fillingQuantity,
              onChanged: widget.onFillingQuantityChanged,
            ),
          ),
      ],
    );
  }
}
