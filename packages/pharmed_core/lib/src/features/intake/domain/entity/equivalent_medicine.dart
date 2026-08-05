import 'package:equatable/equatable.dart';
import 'package:pharmed_core/pharmed_core.dart';
import 'package:collection/collection.dart';

class EquivalentMedicine extends Equatable {
  const EquivalentMedicine({
    this.materialId,
    this.materialName,
    this.stockQuantity,
    this.purchaseQuantity,
    this.stocks = const [],
    this.witnessContext = const WitnessContext(),
  });

  final int? materialId;
  final String? materialName;
  final double? stockQuantity;
  final double? purchaseQuantity;
  final List<CabinStock> stocks;
  final WitnessContext witnessContext;

  Medicine? get medicine => stocks.firstWhereOrNull((s) => s.medicine != null)?.medicine;

  EquivalentMedicine copyWith({WitnessContext? witnessContext}) => EquivalentMedicine(
    materialId: materialId,
    materialName: materialName,
    stockQuantity: stockQuantity,
    purchaseQuantity: purchaseQuantity,
    stocks: stocks,
    witnessContext: witnessContext ?? this.witnessContext,
  );

  @override
  List<Object?> get props => [materialId, materialName, stockQuantity, purchaseQuantity, stocks];
}
