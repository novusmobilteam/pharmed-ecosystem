// import 'package:flutter/material.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// import '../../../../core/core.dart';
// import '../../../../data/repository/repository_barrel.dart';
// import '../../../../domain/entity/entity_barrel.dart';

// enum MovementType {
//   material(icon: PhosphorIconsRegular.tray, label: 'Çekmece Hareketi'),
//   drawer(icon: PhosphorIconsRegular.pill, label: 'Malzeme Hareketi');

//   final IconData icon;
//   final String label;

//   const MovementType({required this.icon, required this.label});
// }

// class InconsistencyDetailViewModel extends ChangeNotifier {
//   final InconsistencyRepository _repository;

//   // Callback'ler
//   VoidCallback? onLoading;
//   Function(String?)? onError;
//   Function(String?)? onSuccess;

//   InconsistencyDetail? _detail;
//   APIRequestStatus _status = APIRequestStatus.initial;
//   MovementType _movementType = MovementType.material;
//   String? _statusMessage;
//   String _searchQuery = '';
//   String deleteDescription = '';

//   InconsistencyDetail? get detail => _detail;
//   APIRequestStatus get status => _status;
//   String? get statusMessage => _statusMessage;
//   MovementType get movementType => _movementType;

//   InconsistencyDetailViewModel({required InconsistencyRepository repository}) : _repository = repository;

//   Future<void> getInconsistencyDetail(int inconsistencyId) async {
//     _status = APIRequestStatus.loading;
//     _detail = null;
//     notifyListeners();

//     final result = await _repository.getInconsistencyDetail(id: inconsistencyId);

//     result.when(
//       ok: (detail) {
//         _detail = detail;
//         _status = APIRequestStatus.success;
//       },
//       error: (error) {
//         _status = APIRequestStatus.failed;
//         _statusMessage = error.message;
//       },
//     );

//     notifyListeners();
//   }

//   void clearDetail() {
//     _detail = null;
//     _status = APIRequestStatus.initial;
//     _statusMessage = null;
//     notifyListeners();
//   }

//   // Hareketleri tarihe göre sıralı getirme
//   List<StockMovement> get sortedMovements {
//     final movements = _detail?.movements;
//     if (movements == null) return [];

//     return List.from(movements)..sort((a, b) => (b.date ?? DateTime.now()).compareTo(a.date ?? DateTime.now()));
//   }

//   // Toplam hareket miktarı
//   double get totalMovementQuantity {
//     return sortedMovements.fold(0.0, (sum, movement) => sum + (movement.quantity ?? 0));
//   }

//   // İlk stok miktarı (en eski hareketin önceki miktarı)
//   double? get initialStockQuantity {
//     if (sortedMovements.isEmpty) return null;
//     final oldestMovement = sortedMovements.last;
//     return (oldestMovement.previousQuantity ?? 0) + (oldestMovement.quantity ?? 0);
//   }

//   /// Arama metodu
//   void search(String query) {
//     _searchQuery = query;
//     notifyListeners();
//   }

//   /// Filtrelenmiş ve sıralanmış hareketler
//   List<StockMovement> get filteredMovements {
//     final movements = sortedMovements;

//     // Arama sorgusu yoksa sıralanmış listeyi döndür
//     if (_searchQuery.isEmpty) {
//       return movements;
//     }

//     final query = _searchQuery.toLowerCase();

//     return movements.where((movement) {
//       // Hareket tipinde arama
//       final typeMatch = movement.type?.toLowerCase().contains(query) ?? false;

//       // Hasta adında arama
//       final patientMatch = movement.patient?.toLowerCase().contains(query) ?? false;

//       // Kullanıcı adında arama
//       final userMatch = movement.user?.fullName.toLowerCase().contains(query) ?? false;

//       // Açıklamada arama
//       final descriptionMatch = movement.description?.toLowerCase().contains(query) ?? false;

//       return typeMatch || patientMatch || userMatch || descriptionMatch;
//     }).toList();
//   }

//   Future<bool> solveInconsistency() async {
//     onLoading?.call();
//     notifyListeners();

//     await Future.delayed(const Duration(milliseconds: 400));
//     onSuccess?.call('Tutarsızlık çözme işlemi başarılı.');
//     notifyListeners();

//     return true;
//   }

//   Future<void> toggleMovements() async {
//     onLoading?.call();
//     notifyListeners();

//     await Future.delayed(const Duration(milliseconds: 500));
//     _movementType = _movementType == MovementType.drawer ? MovementType.material : MovementType.drawer;

//     onSuccess?.call(null);
//     notifyListeners();
//   }
// }
