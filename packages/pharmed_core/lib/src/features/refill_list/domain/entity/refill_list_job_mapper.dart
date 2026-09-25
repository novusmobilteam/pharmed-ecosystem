import 'package:pharmed_core/pharmed_core.dart';

abstract final class RefillListJobMapper {
  static ({List<CabinOperationDrawerJob> jobs, List<RefillListDetail> skipped}) build({
    required List<RefillListDetail> rows,
    List<int> cabinOrder = const [],
  }) => CabinOperationQueueBuilder.build(
    items: rows,
    assignmentOf: (row) => row.toCompatibleQuantity(),
    targetOf: (row, assignment) => _withDefaultFilling(
      CabinOperationTarget.fromAssignment(
        assignment,
        CabinOperationMode.refill,
        plannedQuantity: row.quantity?.toDouble(),
        sourceId: row.id,
      ),
      row,
    ),
    cabinOrder: cabinOrder,
  );

  /// Dolum alanlarına varsayılan olarak KALAN planlanan miktarı yazar —
  /// kullanıcı ekranda değiştirebilir. Kübik: tamamı tek göze. Birim doz:
  /// gözlere eşit, artanlar en arka gözden öne doğru.
  static CabinOperationTarget _withDefaultFilling(CabinOperationTarget target, RefillListDetail row) {
    // Backend biriminde; kısmi dolumda daha önce doldurulan düşülür.
    final remaining = ((row.quantity ?? 0) - (row.fillingQuantity ?? 0)).toDouble();
    if (remaining <= 0) return target;

    if (target.isKubik) return target.withCubicSecondary(remaining);

    final stepCount = target.steps.length;
    if (stepCount == 0) return target;

    final whole = remaining.floor();
    final fraction = remaining - whole;
    final perCell = distributeFromBack(whole, stepCount);

    var result = target;
    for (var i = 0; i < stepCount; i++) {
      // Tam sayıya bölünemeyen kesir (nadir) en arka göze eklenir.
      final value = perCell[i] + (i == stepCount - 1 ? fraction : 0.0);
      if (value > 0) result = result.withStepSecondary(i, value);
    }
    return result;
  }

  /// [total] adedi [cellCount] göze eşit dağıtır. Bölümden artan adetler en
  /// arka gözden (en yüksek indeks) başlayarak birer birer eklenir.
  /// Örn. 10 adet / 12 göz → [0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  static List<int> distributeFromBack(int total, int cellCount) {
    if (cellCount <= 0) return const [];
    if (total <= 0) return List.filled(cellCount, 0);
    final base = total ~/ cellCount;
    final remainder = total % cellCount;
    return List.generate(cellCount, (i) => base + (i >= cellCount - remainder ? 1 : 0));
  }
}
