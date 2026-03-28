import '../../../../core/core.dart';
import '../../../cabin_stock/domain/entity/cabin_stock.dart';
import '../../../medicine_refund/domain/entity/refund.dart';
import '../../../prescription/domain/entity/prescription.dart';
import '../../../prescription/domain/entity/prescription_item.dart';
import '../../domain/repository/i_dashboard_repository.dart';
import '../datasource/dashboard_datasource.dart';

class DashboardRepository implements IDashboardRepository {
  final DashboardDataSource _ds;

  DashboardRepository(this._ds);

  @override
  Future<Result<List<CabinStock>>> getCriticalStocks({bool isClient = false}) async {
    final r = await _ds.getCriticalStocks(isClient: isClient);
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinStock>>> getExpiringMaterials() async {
    final r = await _ds.getExpiringMaterials();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<CabinStock>>> getGeneralStocks() async {
    final r = await _ds.getGeneralStocks();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<Refund>>> getRefunds() async {
    final r = await _ds.getRefunds();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<Prescription>>> getUnappliedPrescriptions() async {
    final r = await _ds.getUnappliedPrescriptions();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUnreadQrCodes() async {
    final r = await _ds.getUnreadQrCodes();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }

  @override
  Future<Result<List<PrescriptionItem>>> getUpcomingTreatments() async {
    final r = await _ds.getUpcomingTreatments();
    return r.when(
      ok: (list) {
        final entities = (list).map((dto) => dto.toEntity()).toList();
        return Result.ok(entities);
      },
      error: (e) => Result.error(e),
    );
  }
}
