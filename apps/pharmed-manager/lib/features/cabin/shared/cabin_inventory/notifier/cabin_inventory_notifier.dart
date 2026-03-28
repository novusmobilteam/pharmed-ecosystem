import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../../../../core/core.dart';

import '../../../../cabin_assignment/domain/entity/cabin_assignment.dart';
import '../../../../medicine/domain/entity/medicine.dart';
import '../../../domain/entity/cabin_input_data.dart';

typedef CabinOperationCallback = Future<Result> Function(List<CabinInputData> inputs);

class CabinInventoryNotifier extends ChangeNotifier with ApiRequestMixin {
  final CabinAssignment initial;
  final CabinOperationCallback onSave;
  final CabinInventoryType inventoryType;
  final bool isPerCellMiadEnabled;

  CabinInventoryNotifier({
    required this.initial,
    required this.onSave,
    required this.inventoryType,
    required this.isPerCellMiadEnabled,
  }) {
    // Kademe sayısına göre ekranda çizilecek olan [Sayım Miktarı] ve [Dolum Miktarı]
    // input alanları değişiyor. Çekmece kaç kademeyse o kadar sayım ve dolum miktarı
    // olması gerekiyor.
    _drawerCountQuantities = List.generate(numberOfSteps, (_) => 0);
    _drawerFillingQuantities = List.generate(numberOfSteps, (_) => 0);

    // ⚠ Skill §4: Stok yoksa miad tarihi önceden default atanmaz — null bırakılır.
    // Tarih yalnızca mevcut stoktan yüklenir.
    _drawerMiadDates = List.generate(numberOfSteps, (_) => null);
    _miadDate = null;

    // Mevcut stok kayıtlarından miktarları ve miad tarihlerini yükle
    _initFromStocks();
  }

  // ── Operation State ───────────────────────────────────────────────────────

  OperationKey submitOp = OperationKey.custom('submit');

  /// Submit işleminin devam edip etmediğini döner.
  bool get isSubmitting => isLoading(submitOp);

  // ── Miad Tarihi ───────────────────────────────────────────────────────────

  /// Kübik çekmece ve isPerCellMiad=false durumunda kullanılan tekil miad tarihi.
  /// isPerCellMiad=false iken en eski stok miadı buraya atanır.
  DateTime? _miadDate;
  DateTime? get miadDate => _miadDate;

  /// Her gözün ayrı miad tarihini tutar (isPerCellMiadEnabled=true iken aktif).
  List<DateTime?> _drawerMiadDates = [];
  List<DateTime?> get drawerMiadDates => _drawerMiadDates;

  // ── Kübik Çekmece Miktarları ──────────────────────────────────────────────

  /// Kübik çekmecede yer alan malzemenin sayım miktarı.
  double? _cubicCountQuantity;
  double get cubicCountQuantity => _cubicCountQuantity ?? 0;

  /// Kübik çekmecede yer alan malzemenin dolum miktarı.
  double? _cubicFillingQuantity;
  double get cubicFillingQuantity => _cubicFillingQuantity ?? 0;

  // ── Standart Çekmece Miktarları ───────────────────────────────────────────

  /// Standart çekmecede yer alan malzemelerin göz bazlı sayım miktarları.
  List<double> _drawerCountQuantities = [];
  List<double> get drawerCountQuantities => _drawerCountQuantities;

  /// Standart çekmecede yer alan malzemelerin göz bazlı dolum miktarları.
  List<double> _drawerFillingQuantities = [];
  List<double> get drawerFillingQuantities => _drawerFillingQuantities;

  static final _emptyMiadFallback = DateTime(2099, 12, 31);

  // ── Hesaplanan Getter'lar ─────────────────────────────────────────────────

  /// Çekmece kübik mi değil mi?
  bool get isKubik => initial.drawerUnit?.drawerSlot?.drawerConfig?.drawerType?.isKubik ?? false;

  /// Standart çekmece kademe sayısı. Kübik çekmece 16 ya da 20 gözlü olabiliyor fakat
  /// kübik çekmecenin kademe sayısıyla bu ekranda işimiz yok.
  int get numberOfSteps => initial.drawerUnit?.drawerSlot?.drawerConfig?.numberOfSteps ?? 0;

  /// Toplu dolum ekranında ilk gözdeki mevcut sayım miktarı.
  /// Liste boşsa 0 döner — numberOfSteps==0 olan yapılandırılmamış çekmecelere karşı guard.
  double get averageCountQuantity => _drawerCountQuantities.isEmpty ? 0 : _drawerCountQuantities.first;

  /// Toplu dolum ekranında ilk gözdeki mevcut dolum miktarı.
  /// Liste boşsa 0 döner — numberOfSteps==0 olan yapılandırılmamış çekmecelere karşı guard.
  double get averageFillingQuantity => _drawerFillingQuantities.isEmpty ? 0 : _drawerFillingQuantities.first;

  /// Kübik çekmece dolum ekranında yer alan butonun aktiflik durumu.
  /// Miad tarihi seçilmiş ve dolum miktarı > 0 olduğunda aktif olur.
  bool get isKubikButtonActive => isKubik && _miadDate != null && (_cubicFillingQuantity ?? 0) > 0;

  /// Belirtilen index'teki gözde **stoklu** ve miadı geçmiş kayıt var mı?
  ///
  /// Stok miktarı 0 olan gözün miadı geçmiş olsa bile false döner.
  /// ⚠ Skill §4: Sadece stoklu gözler kontrol edilir — stok=0 göz bloklanmaz.
  bool isCellExpired(int index) {
    final detail = initial.cabinDrawerDetail?[index];
    if (detail == null) return false;

    return initial.stocks?.any((stock) {
          final isThisCell = stock.cabinDrawerDetailId == detail.id;
          final hasStock = (stock.quantity ?? 0) > 0;
          final isExpired = stock.miadDate?.isBefore(DateTime.now()) ?? false;
          return isThisCell && hasStock && isExpired;
        }) ??
        false;
  }

  /// Kübik çekmecede stoklu + miadı geçmiş kayıt var mı?
  ///
  /// ⚠ Skill §4: true ise refill/count için tüm kübik alan kilitlenir.
  bool get isCubicExpired {
    if (!isKubik) return false;
    final stock = initial.stocks?.firstOrNull;
    final hasStock = (stock?.quantity ?? 0) > 0;
    final isExpired = stock?.miadDate?.isBefore(DateTime.now()) ?? false;
    return hasStock && isExpired;
  }

  /// Miadı geçmiş stoklu göz index'lerini döner — satır bazında kilitleme için.
  ///
  /// Boş liste dönerse hiçbir göz kilitli değildir.
  List<int> get expiredCellIndexes {
    return List.generate(numberOfSteps, (i) => i).where((i) => isCellExpired(i)).toList();
  }

  // ── Değiştirici Metodlar ──────────────────────────────────────────────────

  /// Tekil miad tarihini günceller (kübik veya isPerCellMiad=false durumunda).
  void changeMiadDate(DateTime date) {
    _miadDate = date;
    notifyListeners();
  }

  void changeCubicCountQuantity(double value) {
    _cubicCountQuantity = value;
    notifyListeners();
  }

  void changeCubicFillingQuantity(double value) {
    _cubicFillingQuantity = value;
    notifyListeners();
  }

  void changeDrawerCountQuantity({required int index, required double value}) {
    _drawerCountQuantities[index] = value;
    notifyListeners();
  }

  void changeDrawerFillingQuantity({required int index, required double value}) {
    _drawerFillingQuantities[index] = value;
    notifyListeners();
  }

  /// [index] numaralı gözün miad tarihini günceller (isPerCellMiadEnabled=true).
  /// [date] null verilebilir — geçmiş miadın temizlenmesi gerektiğinde null gönderilir.
  void changeDrawerMiadDate({required int index, DateTime? date}) {
    _drawerMiadDates[index] = date;
    notifyListeners();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  /// Formu submit eder. Validasyon başarılıysa [onSave] callback'i çağrılır.
  ///
  /// [onSuccess]: İşlem başarılı olduğunda çağrılır (snackbar + ekran kapanır).
  /// [onFailed]: Validasyon veya API hatası durumunda çağrılır (ekran açık kalır).
  Future<void> submit({Function(String? message)? onSuccess, Function(String? message)? onFailed}) async {
    if (!_validateQuantities(onFailed)) return;
    if (!_validateMiadDates(onFailed)) return;

    await executeVoid(
      submitOp,
      operation: () async {
        final List<CabinInputData> inputs = [];

        final int matId = initial.medicine?.id ?? 0;
        final int compartmentNo = initial.drawerUnit?.compartmentNo ?? 0;
        final int? stockId = initial.stocks == null || initial.stocks!.isEmpty ? null : initial.stocks!.first.id;
        final bool requiresMiad = inventoryType.enableMiadDateInput;

        // Dolumda kullanıcı adet girer backende adetxdoz gönderilir.
        // Diğer durumlarda kullanıcı ne girerse o gider.
        final medicine = initial.medicine;
        final bool isMeasureUnitInput =
            (inventoryType == CabinInventoryType.refill) && medicine is Drug && medicine.isMeasureUnit;

        if (isKubik) {
          final int detailId = initial.cabinDrawerDetail?.firstOrNull?.id ?? 0;
          final cabinDrawerId = initial.cabinDrawerId;

          final rawFill = _cubicFillingQuantity ?? 0;
          final quantity = isMeasureUnitInput ? medicine.toFillingBackendValue(rawFill) : rawFill;

          inputs.add(
            CabinInputData(
              materialId: matId,
              cabinDrawerDetailId: detailId,
              quantity: quantity,
              censusQuantity: _cubicCountQuantity ?? 0,
              // count için validasyon miad null olmayacağını garantiler;
              // discharge/destruction için null gönderilebilir
              miadDate: _miadDate,
              shelfNo: initial.drawerUnit?.orderNo ?? 1,
              compartmentNo: compartmentNo,
              stockId: stockId,
              cabinDrawerId: cabinDrawerId,
              assignment: initial,
            ),
          );
        } else {
          for (int i = 0; i < numberOfSteps; i++) {
            final fillingQuantity = _drawerFillingQuantities[i];
            final countQuantity = _drawerCountQuantities[i];

            final int detailId = initial.cabinDrawerDetail?[i].id ?? 0;
            final cabinDrawerId = initial.cabinDrawerId;

            // firstWhereOrNull: eşleşme yoksa CabinStock() yerine null döner, id null olur
            final matchingStock = initial.stocks?.firstWhereOrNull((s) => s.cabinDrawerDetailId == detailId);

            final quantity = isMeasureUnitInput
                ? initial.medicine!.toFillingBackendValue(fillingQuantity) // ölçü birimi → adet
                : fillingQuantity;

            // fillingQuantity==0 && countQuantity==0 olan boş gözlere
            // varsayılan miad tarihi atanmaz — null gönderilir
            final DateTime? miadDate;
            if (fillingQuantity == 0 && countQuantity == 0) {
              miadDate = _emptyMiadFallback;
            } else if (!requiresMiad) {
              miadDate = matchingStock?.miadDate;
            } else if (isPerCellMiadEnabled) {
              // Validasyon refill/count için null olmayacağını garantiler
              miadDate = _drawerMiadDates[i];
            } else {
              // Validasyon count için null olmayacağını garantiler;
              // discharge/destruction için null gönderilebilir
              miadDate = _miadDate;
            }

            inputs.add(
              CabinInputData(
                materialId: matId,
                cabinDrawerDetailId: detailId,
                quantity: quantity,
                censusQuantity: countQuantity,
                miadDate: miadDate,
                compartmentNo: initial.cabinDrawerDetail?.elementAt(i).stepNo,
                shelfNo: initial.drawerUnit?.compartmentNo,
                stockId: matchingStock?.id,
                cabinDrawerId: cabinDrawerId,
                assignment: initial,
              ),
            );
          }
        }

        if (inputs.isNotEmpty) {
          await onSave(inputs);
        }

        return Result.ok(null);
      },
      onSuccess: () => onSuccess?.call('İşlem başarıyla sonuçlandı.'),
      onFailed: (error) => onFailed?.call(error.message),
    );
  }

  // ── Private Helpers ───────────────────────────────────────────────────────

  /// Mevcut stok kayıtlarından sayım miktarlarını ve miad tarihlerini yükler.
  ///
  /// Kübik çekmece için tek stok kaydı işlenir; standart çekmece için
  /// her stok [corpartmentNo] ile ilgili gözüne eşleştirilir.
  ///
  /// ⚠ Skill §4: Stok yoksa metod erken çıkar, hiçbir değer atanmaz (null kalır).
  void _initFromStocks() {
    if (initial.stocks == null || initial.stocks!.isEmpty) return;

    if (isKubik) {
      _initKubikStock();
    } else {
      _initDrawerStocks();
    }
  }

  /// Kübik çekmece için ilk stok kaydından sayım miktarı ve miad tarihi yüklenir.
  ///
  /// Refill tipinde, backend'den gelen backend değeri kullanıcıya gösterilecek
  /// adete dönüştürülür ([fromFillingBackendValue]). Diğer tiplerde ham değer
  /// doğrudan kullanılır.
  ///
  /// Dolum işleminde [_cubicFillingQuantity] her zaman 0'dan başlar —
  /// kullanıcı mevcut stok üzerine ek dolum miktarı girer.
  ///
  /// ⚠ Skill §5: refill tipinde sayım miktarı fromFillingBackendValue ile çevrilir.
  void _initKubikStock() {
    final stock = initial.stocks != null && (initial.stocks?.isNotEmpty ?? false) ? initial.stocks?.first : null;

    if (inventoryType == CabinInventoryType.refill) {
      // Backend'den gelen değer (örn: 5 × 100ml = 500) adete çevrilir (→ 5 adet)
      final rawQuantity = (initial.totalQuantity).toDouble();

      _cubicCountQuantity = initial.medicine!.fromFillingBackendValue(rawQuantity);
    } else {
      // Sayım, boşaltma ve imha tiplerinde backend değeri doğrudan kullanılır
      _cubicCountQuantity = (initial.totalQuantity).toDouble();
    }

    // Mevcut stoktan miad tarihini yükle; stok kaydında miad yoksa veya stok sıfırsa null kalır.
    // ⚠ Stok sıfırlanmış kayıtlar eski miad tarihini taşıyabilir — artık hiçbir veriye ait değildir.
    _miadDate = (initial.totalQuantity) > 0 ? stock?.miadDate : null;

    // Dolum miktarı kullanıcı girişiyle doldurulacağı için sıfırdan başlatılır
    _cubicFillingQuantity = 0;
  }

  /// Standart çekmece için her stok kaydını [corpartmentNo] bazında
  /// ilgili göze eşleştirerek sayım miktarlarını ve miad tarihlerini yükler.
  ///
  /// isPerCellMiadEnabled=true → Her göze kendi miad tarihi ayrı ayrı atanır.
  /// isPerCellMiadEnabled=false → Stoklu gözler arasından en eski miad
  /// tarihi [_miadDate]'e atanır (tüm gözlere tek miad uygulanır).
  ///
  /// ⚠ Skill §4: Stok miktarı 0 olan gözün miadı genel miad hesabına dahil edilmez.
  /// ⚠ Skill §5: refill tipinde sayım miktarı fromFillingBackendValue ile çevrilir.
  void _initDrawerStocks() {
    for (final stock in initial.stocks!) {
      // corpartmentNo 1-tabanlı, index 0-tabanlıdır; sınır dışı gözler atlanır
      final int index = (stock.corpartmentNo ?? 0) - 1;
      if (index < 0 || index >= numberOfSteps) continue;

      if (inventoryType == CabinInventoryType.refill || inventoryType == CabinInventoryType.refillList) {
        // Backend'den gelen değer (örn: 3 × 100ml = 300) adete çevrilir (→ 3 adet)
        final rawQuantity = (stock.quantity ?? 0).toDouble();
        _drawerCountQuantities[index] = initial.medicine != null
            ? initial.medicine!.fromFillingBackendValue(rawQuantity)
            : rawQuantity;
      } else {
        // Sayım, boşaltma ve imha tiplerinde backend değeri doğrudan kullanılır
        _drawerCountQuantities[index] = (stock.quantity ?? 0).toDouble();
      }

      if (isPerCellMiadEnabled) {
        // Göz bazlı mod: her göz kendi miadıyla ayrı ayrı yüklenir.
        // ⚠ Stok sıfırsa miad null kalır — sıfır stoklu kayıtlar eski miad taşıyabilir.
        _drawerMiadDates[index] = (stock.quantity ?? 0) > 0 ? stock.miadDate : null;
      } else {
        // Genel miad modu: stoklu gözler arasından en eski miad tarihi seçilir.
        // ⚠ Skill §4: Stok = 0 olan gözün miadı hesaba katılmaz — sadece stoklu gözler
        if (stock.miadDate != null && stock.quantity != 0) {
          if (_miadDate == null || stock.miadDate!.isBefore(_miadDate!)) {
            _miadDate = stock.miadDate;
          }
        }
      }
    }
  }

  /// Miktar validasyonunu çalıştırır.
  ///
  /// Herhangi bir işlem miktarı girilmemişse [onFailed] çağrılır.
  /// Kübik: tip bazında ilgili alan kontrol edilir.
  /// Birim Doz: hiçbir gözde ilgili miktar > 0 yoksa hata verilir.
  bool _validateQuantities(Function(String? message)? onFailed) {
    if (isKubik) {
      switch (inventoryType) {
        case CabinInventoryType.refill:
        case CabinInventoryType.refillList:
          if ((_cubicFillingQuantity ?? 0) == 0) {
            onFailed?.call('Dolum miktarı girilmelidir.');
            return false;
          }
        case CabinInventoryType.count:
          if ((_cubicCountQuantity ?? 0) == 0) {
            onFailed?.call('Sayım miktarı girilmelidir.');
            return false;
          }
        case CabinInventoryType.unload:
        case CabinInventoryType.disposal:
          if ((_cubicFillingQuantity ?? 0) == 0) {
            onFailed?.call('İşlem miktarı girilmelidir.');
            return false;
          }
      }
    } else {
      if (inventoryType == CabinInventoryType.count) {
        if (!_drawerCountQuantities.any((q) => q > 0)) {
          onFailed?.call('En az bir göz için sayım miktarı girilmelidir.');
          return false;
        }
      } else {
        if (!_drawerFillingQuantities.any((q) => q > 0)) {
          onFailed?.call('En az bir göz için işlem miktarı girilmelidir.');
          return false;
        }
      }
    }
    return true;
  }

  /// Miad tarihi validasyonunu çalıştırır.
  ///
  /// Validasyon sırası (Skill §4):
  /// 1. count tipinde tekil miad null ise → onFailed çağrılır + erken çıkış
  /// 2. discharge/destruction dışında tekil miad geçmişse → onFailed
  /// 3. isPerCellMiad=true ise her göz kontrol edilir:
  ///    - refill/count: miktar > 0 ama miad null → onFailed
  ///    - herhangi bir gözün miadı geçmişse → onFailed
  ///
  /// [true] dönerse validasyon geçti, [false] dönerse [onFailed] çağrıldı.
  bool _validateMiadDates(Function(String? message)? onFailed) {
    // refill ve count için miad tarihi zorunludur (unload/disposal hariç).
    // isPerCellMiad=true olan birim doz gözleri per-cell döngüsünde kontrol edilir;
    // kübik ve isPerCellMiad=false için tekil _miadDate burada kontrol edilir.
    final bool requiresMiad = inventoryType == CabinInventoryType.refill || inventoryType == CabinInventoryType.count;
    if (requiresMiad && (isKubik || !isPerCellMiadEnabled) && _miadDate == null) {
      onFailed?.call('Miad tarihi girilmelidir.');
      return false;
    }

    // discharge ve destruction için miad geçmiş olsa bile bloklama YAPILMAZ
    final bool shouldCheckExpiry =
        inventoryType != CabinInventoryType.disposal && inventoryType != CabinInventoryType.unload;

    if (shouldCheckExpiry && _miadDate != null && _miadDate!.isBefore(DateTime.now())) {
      onFailed?.call('Miad tarihi geçmiş bir ilaç işlem yapılamaz!');
      return false;
    }

    // isPerCellMiad=true iken refill ve count için göz bazlı kontrol yapılır.
    // discharge ve destruction tipleri için miad validasyonu uygulanmaz.
    if (isPerCellMiadEnabled &&
        !isKubik &&
        (inventoryType == CabinInventoryType.refill || inventoryType == CabinInventoryType.count)) {
      for (int i = 0; i < numberOfSteps; i++) {
        // count tipinde sayım miktarı, diğer tiplerde dolum miktarı referans alınır
        final relevantQuantity = inventoryType == CabinInventoryType.count
            ? _drawerCountQuantities[i]
            : _drawerFillingQuantities[i];

        // Miktar girilmiş ama miad seçilmemişse hata
        if (relevantQuantity > 0 && _drawerMiadDates[i] == null) {
          onFailed?.call('${i + 1}. göz için miad tarihi seçilmelidir!');
          return false;
        }

        // Seçili miad tarihi geçmişse hata
        if (_drawerMiadDates[i] != null && _drawerMiadDates[i]!.isBefore(DateTime.now())) {
          onFailed?.call('${i + 1}. gözün miad tarihi geçmiş, işlem yapılamaz!');
          return false;
        }
      }
    }

    return true;
  }
}
