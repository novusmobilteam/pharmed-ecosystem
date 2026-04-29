// import '../../core/core.dart';
// import 'inconsistency.dart';
// import 'user.dart';

// class InconsistencyDetail {
//   final int? id;
//   final InconsistencySummary? summary;
//   final List<StockMovement>? movements;
//   final DateTime? createdAt;
//   final User? createdBy;
//   final String? notes;

//   const InconsistencyDetail({
//     this.id,
//     this.summary,
//     this.movements,
//     this.createdAt,
//     this.createdBy,
//     this.notes,
//   });

//   InconsistencyDetail copyWith({
//     int? id,
//     InconsistencySummary? summary,
//     List<StockMovement>? movements,
//     DateTime? createdAt,
//     User? createdBy,
//     String? notes,
//   }) {
//     return InconsistencyDetail(
//       id: id ?? this.id,
//       summary: summary ?? this.summary,
//       movements: movements ?? this.movements,
//       createdAt: createdAt ?? this.createdAt,
//       createdBy: createdBy ?? this.createdBy,
//       notes: notes ?? this.notes,
//     );
//   }
// }

// class StockMovement implements TableData {
//   final int? id;
//   final String? type; // "Malzeme Alım", "Stok Fazlası", "Stok Eksikliği", vb.
//   final String? patient;
//   final User? user;
//   final DateTime? date;
//   final double? previousQuantity;
//   final double? quantity;
//   final String? description;
//   final String? material;

//   const StockMovement({
//     this.id,
//     this.type,
//     this.patient,
//     this.user,
//     this.date,
//     this.previousQuantity,
//     this.quantity,
//     this.description,
//     this.material,
//   });

//   StockMovement copyWith({
//     int? id,
//     String? type,
//     String? patient,
//     User? user,
//     DateTime? date,
//     double? previousQuantity,
//     double? quantity,
//     String? description,
//     String? material,
//   }) {
//     return StockMovement(
//       id: id ?? this.id,
//       type: type ?? this.type,
//       patient: patient ?? this.patient,
//       user: user ?? this.user,
//       date: date ?? this.date,
//       previousQuantity: previousQuantity ?? this.previousQuantity,
//       quantity: quantity ?? this.quantity,
//       description: description ?? this.description,
//       material: material ?? this.material,
//     );
//   }

//   @override
//   List<String?> get content => [
//         material,
//         type,
//         patient ?? '-',
//         user?.fullName,
//         date?.formattedDate,
//         previousQuantity?.toStringAsFixed(2),
//         quantity?.toStringAsFixed(2),
//         description,
//       ];

//   @override
//   List<String?> get titles => [
//         'Malzeme',
//         'Çekmece Hareketi',
//         'Hasta',
//         'Kullanıcı',
//         'Tarih',
//         'Önceki Miktar',
//         'Miktar',
//         'Açıklama',
//       ];

//   @override
//   List get rawContent => [
//         material,
//         type,
//         patient,
//         user?.fullName,
//         date,
//         previousQuantity,
//         quantity,
//         description,
//       ];
// }
