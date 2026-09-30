import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/mixins/mixins.dart';
import '../../../core/providers/providers.dart';
import 'stock_movement_summary.dart';

final stockMovementNotifierProvider = ChangeNotifierProvider.autoDispose<StockMovementNotifier>(
  (ref) => StockMovementNotifier(getStationTransactionsUseCase: ref.read(getStationTransactionsUseCaseProvider)),
);

enum StockMovementRangePreset { today, last7Days, last30Days, custom }

/// Stok Hareket ekranı — istasyon hareketlerinin grafiksel sunumu.
///
/// Veri kaynağı manager'daki İstasyon Hareketleri ekranıyla aynı
/// [GetStationTransactionsUseCase]'dir. Tarih aralığı değişince sunucudan
/// yeniden çekilir; hareket tipi / kabin filtreleri istemcide uygulanır
/// (dokunmatik ekranda her dokunuşta istek atılmaz).
///
/// SWREQ-XXX (atanacak)
class StockMovementNotifier extends ChangeNotifier with ApiRequestMixin {
  StockMovementNotifier({
    required GetStationTransactionsUseCase getStationTransactionsUseCase,
    this.aggregator = const StockMovementAggregator(),
  }) : _getStationTransactionsUseCase = getStationTransactionsUseCase {
    _applyPreset(preset);
  }

  final GetStationTransactionsUseCase _getStationTransactionsUseCase;
  final StockMovementAggregator aggregator;

  /// Sayfa başına çekilecek kayıt ve toplam güvenlik sınırı.
  /// Sınır aşılırsa [isTruncated] true olur ve UI kullanıcıyı uyarır.
  static const int _pageSize = 500;
  static const int _maxRows = 10000;

  final OperationKey fetchOp = OperationKey.fetch();

  int? _stationId;

  StockMovementRangePreset _preset = StockMovementRangePreset.last7Days;
  StockMovementRangePreset get preset => _preset;

  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  DateTime get rangeStart => _rangeStart;
  DateTime get rangeEnd => _rangeEnd;

  List<StationTransaction> _items = [];

  Set<StationTransactionType> _selectedTypes = {};
  Set<StationTransactionType> get selectedTypes => Set.unmodifiable(_selectedTypes);

  Set<int?> _selectedCabinIds = {};
  Set<int?> get selectedCabinIds => Set.unmodifiable(_selectedCabinIds);

  StockMovementSummary _summary = StockMovementSummary.empty;
  StockMovementSummary get summary => _summary;

  List<StockMovementCabinTotal> _availableCabins = [];

  /// Filtre chip'leri için: yüklenen aralıkta hareketi olan tüm kabinler
  /// (tip/kabin filtresinden bağımsız).
  List<StockMovementCabinTotal> get availableCabins => _availableCabins;

  bool _isTruncated = false;
  bool get isTruncated => _isTruncated;

  bool get isFetching => isLoading(fetchOp);
  bool get isFetchFailed => isFailed(fetchOp);
  String? get statusMessage => message(fetchOp);

  /// Gelen yanıtın hâlâ güncel istek için olup olmadığını ayırt eder.
  int _requestSeq = 0;

  Future<void> initialize({required int stationId}) async {
    _stationId = stationId;
    _applyPreset(_preset);
    await fetch();
  }

  Future<void> selectPreset(StockMovementRangePreset preset) async {
    if (preset == StockMovementRangePreset.custom || preset == _preset) return;
    _applyPreset(preset);
    notifyListeners();
    await fetch();
  }

  /// Hazır aralıklarda bitişi "şimdi"ye çekerek yeniden sorgular.
  Future<void> refresh() async {
    if (_preset != StockMovementRangePreset.custom) _applyPreset(_preset);
    await fetch();
  }

  Future<void> setCustomRange(DateTime start, DateTime end) async {
    _preset = StockMovementRangePreset.custom;
    _rangeStart = DateTime(start.year, start.month, start.day);
    _rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);
    notifyListeners();
    await fetch();
  }

  void toggleType(StationTransactionType type) {
    _selectedTypes = _toggled(_selectedTypes, type);
    _recompute();
  }

  void toggleCabin(int? cabinId) {
    _selectedCabinIds = _toggled(_selectedCabinIds, cabinId);
    _recompute();
  }

  void clearFilters() {
    _selectedTypes = {};
    _selectedCabinIds = {};
    _recompute();
  }

  Future<void> fetch() async {
    final stationId = _stationId;
    if (stationId == null) return;
    final seq = ++_requestSeq;

    await execute(
      fetchOp,
      operation: () => _fetchAll(stationId),
      onData: (items) {
        if (seq != _requestSeq) return; // eski aralığın geç gelen yanıtı
        _items = items;
        _availableCabins = aggregator.aggregate(items, rangeStart: _rangeStart, rangeEnd: _rangeEnd).byCabin;
        _isTruncated = items.length >= _maxRows;
        _recompute();
      },
    );
  }

  Future<Result<List<StationTransaction>>> _fetchAll(int stationId) async {
    final collected = <StationTransaction>[];
    var skip = 0;

    while (true) {
      final result = await _getStationTransactionsUseCase.call(
        PagedQueryParams(
          skip: skip,
          take: _pageSize,
          startDate: _rangeStart,
          endDate: _rangeEnd,
          filters: [
            Filter.inList('stationId', [stationId]),
          ],
        ),
      );

      Result<List<StationTransaction>>? failure;
      var pageLength = 0;
      var total = 0;
      result.when(
        ok: (response) {
          final data = response?.data ?? const <StationTransaction>[];
          collected.addAll(data);
          pageLength = data.length;
          total = response?.totalCount ?? 0; // TODO: yanıt tipindeki toplam alanının adıyla eşle
        },
        error: (e) => failure = Result.error(e),
      );
      if (failure != null) return failure!;

      skip += pageLength;
      final done = pageLength < _pageSize || (total > 0 && skip >= total) || collected.length >= _maxRows;
      if (done) break;
    }

    return Result.ok(collected);
  }

  void _recompute() {
    final filtered = _items.where((t) {
      final typeOk = _selectedTypes.isEmpty || _selectedTypes.contains(t.transactionType);
      final cabinOk = _selectedCabinIds.isEmpty || _selectedCabinIds.contains(t.cabinId);
      return typeOk && cabinOk;
    }).toList();

    _summary = aggregator.aggregate(filtered, rangeStart: _rangeStart, rangeEnd: _rangeEnd);
    notifyListeners();
  }

  void _applyPreset(StockMovementRangePreset preset) {
    _preset = preset;
    final now = DateTime.now();
    _rangeEnd = now;
    _rangeStart = switch (preset) {
      StockMovementRangePreset.today => DateTime(now.year, now.month, now.day),
      StockMovementRangePreset.last7Days => DateTime(now.year, now.month, now.day - 6),
      StockMovementRangePreset.last30Days => DateTime(now.year, now.month, now.day - 29),
      StockMovementRangePreset.custom => _rangeStart,
    };
  }

  static Set<T> _toggled<T>(Set<T> source, T value) {
    final next = {...source};
    if (!next.remove(value)) next.add(value);
    return next;
  }
}
