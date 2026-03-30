import '../../../../core/core.dart';
import '../../../medicine_refund/data/model/refund_dto.dart';
import '../../../prescription/data/model/prescription_dto.dart';
import '../../../prescription/data/model/prescription_item_dto.dart';
import 'dashboard_datasource.dart';

class _PrescriptionStore extends BaseLocalDataSource<PrescriptionDTO, int> {
  _PrescriptionStore({required super.filePath})
    : super(
        fromJson: (m) => PrescriptionDTO.fromJson(m),
        toJson: (d) => d.toJson(),
        getId: (d) => d.id ?? -1,
        assignId: (d, id) => d.copyWith(id: id),
      );
}

class _PrescriptionItemStore extends BaseLocalDataSource<PrescriptionItemDTO, int> {
  _PrescriptionItemStore({required super.filePath})
    : super(
        fromJson: (m) => PrescriptionItemDTO.fromJson(m),
        toJson: (d) => d.toJson(),
        getId: (d) => d.id ?? -1,
        assignId: (d, id) => d.copyWith(id: id),
      );
}

class _CabinStockStore extends BaseLocalDataSource<CabinStockDTO, int> {
  _CabinStockStore({required super.filePath})
    : super(
        fromJson: (m) => CabinStockDTO.fromJson(m),
        toJson: (d) => d.toJson(),
        getId: (d) => d.id ?? -1,
        assignId: (d, id) => d.copyWith(id: id),
      );
}

class _RefundStore extends BaseLocalDataSource<RefundDTO, int> {
  _RefundStore({required super.filePath})
    : super(
        fromJson: (m) => RefundDTO.fromJson(m),
        toJson: (d) => d.toJson(),
        getId: (d) => d.id ?? -1,
        assignId: (d, id) => d.copyWith(id: id),
      );
}

class DashboardLocalDataSource implements DashboardDataSource {
  final _PrescriptionStore _prescriptionStore;
  final _PrescriptionItemStore _prescriptionItemStore;
  final _CabinStockStore _cabinStockStore;
  final _RefundStore _refundStore;

  DashboardLocalDataSource({
    required String prescriptionPath,
    required String prescriptionItemPath,
    required String cabinStockPath,
    required String refundPath,
  }) : _prescriptionStore = _PrescriptionStore(filePath: prescriptionPath),
       _prescriptionItemStore = _PrescriptionItemStore(filePath: prescriptionItemPath),
       _cabinStockStore = _CabinStockStore(filePath: cabinStockPath),
       _refundStore = _RefundStore(filePath: refundPath);

  @override
  Future<Result<List<CabinStockDTO>>> getCriticalStocks({bool isClient = false}) async {
    final res = await _cabinStockStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinStockDTO>>> getExpiringMaterials() async {
    final res = await _cabinStockStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<CabinStockDTO>>> getGeneralStocks() async {
    final res = await _cabinStockStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<RefundDTO>>> getRefunds() async {
    final res = await _refundStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionDTO>>> getUnappliedPrescriptions() async {
    final res = await _prescriptionStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUnreadQrCodes() async {
    final res = await _prescriptionItemStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }

  @override
  Future<Result<List<PrescriptionItemDTO>>> getUpcomingTreatments() async {
    final res = await _prescriptionItemStore.fetchRequest();
    return res.when(ok: (response) => Result.ok(response.data ?? []), error: (e) => Result.error(e));
  }
}
