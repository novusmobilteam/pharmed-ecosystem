// lib/data/datasource/base_local_data_source.dart
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../core.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);
typedef ToJson<T> = Map<String, dynamic> Function(T value);
typedef GetId<T, ID> = ID Function(T value);
typedef AssignId<T, ID> = T Function(T value, ID id);

abstract class BaseLocalDataSource<T, ID> with Logging {
  final String filePath;
  final FromJson<T> fromJson;
  final ToJson<T> toJson;
  final GetId<T, ID> getId;
  final AssignId<T, ID> assignId;

  final List<T> _items = [];
  bool _initialized = false;

  BaseLocalDataSource({
    required this.filePath,
    required this.fromJson,
    required this.toJson,
    required this.getId,
    required this.assignId,
  });

  @override
  String get loggerName => runtimeType.toString();

  Future<void> _init() async {
    if (_initialized) return;
    final raw = await rootBundle.loadString(filePath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    final apiResp = ApiResponse<List<T>>.fromJson(
      json,
      (obj) {
        final list = (obj as List<dynamic>? ?? const []);
        return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
      },
    );

    _items.addAll(apiResp.data ?? []);
    _initialized = true;
  }

  // ----------------- CRUD-like Methods -----------------
  Future<Result<ApiResponse<List<T>>>> fetchRequest({
    int? skip,
    int? take,
    String? searchText,
    String? searchField, // Örn: 'name'
  }) async {
    const operation = 'fetchRequest';
    try {
      await _init();

      // 1. Arama Filtreleme (Client-side filtering simulation)
      List<T> filteredList = List.from(_items);

      if (searchText != null && searchText.isNotEmpty && searchField != null) {
        filteredList = filteredList.where((item) {
          // Generic T tipini Map'e çevirip field adına erişiyoruz
          final map = toJson(item);
          final value = map[searchField];

          if (value == null) return false;
          return value.toString().toLowerCase().contains(searchText.toLowerCase());
        }).toList();
      }

      // 2. Toplam Kayıt Sayısı (Pagination öncesi)
      final totalCount = filteredList.length;

      // 3. Sayfalama (Pagination Logic)
      List<T> pagedList = filteredList;

      if (skip != null && take != null) {
        final start = skip;
        final end = (skip + take);

        if (start >= totalCount) {
          pagedList = [];
        } else {
          // Listeyi kes (sublist), fakat index out of range hatası almamak için clamp kullan
          pagedList = filteredList.sublist(start, end > totalCount ? totalCount : end);
        }
      }

      logOp(operation: operation, status: LogStatus.success, count: pagedList.length);

      // 4. ApiResponse Paketleme
      return Result.ok(ApiResponse<List<T>>(
        data: pagedList,
        totalCount: totalCount,
        isSuccess: true,
        statusCode: 200,
      ));
    } catch (e) {
      logOp(operation: operation, status: LogStatus.failure, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }

  Future<Result<List<T>>> fetchAll({bool Function(T item)? filter}) async {
    final res = await fetchRequest();
    return res.when(
      ok: (apiResp) => Result.ok(apiResp.data ?? []),
      error: (err) => Result.error(err),
    );
  }

  Future<Result<T?>> fetchSingleRequest({ID? id}) async {
    const operation = 'fetchSingleRequest';
    try {
      await _init();

      T? foundItem;

      if (id != null) {
        foundItem = _items.firstWhere(
          (item) => getId(item) == id,
          orElse: () => throw StateError('Item not found with id: $id'),
        );
      } else {
        throw ArgumentError('Either id or filter must be provided');
      }

      logOp(operation: operation, status: LogStatus.success);
      return Result.ok(foundItem);
    } on StateError catch (e) {
      logOp(operation: operation, status: LogStatus.failure, message: e.toString());
      return Result.error(CustomException(message: 'Kayıt bulunamadı: ${e.message}'));
    } catch (e) {
      logOp(operation: operation, status: LogStatus.exception, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }

  Future<Result<T>> createRequest(T dto) async {
    const operation = 'createRequest';
    try {
      await _init();
      final id = int.tryParse(const Uuid().v4().substring(0, 4)) ?? DateTime.now().millisecondsSinceEpoch;
      final newEntity = assignId(dto, id as ID);
      _items.add(newEntity);
      logOp(operation: operation, status: LogStatus.success);
      return Result.ok(newEntity);
    } catch (e) {
      logOp(operation: operation, status: LogStatus.failure, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }

  Future<Result<T>> updateRequest(T dto) async {
    const operation = 'updateRequest';
    try {
      await _init();
      final id = getId(dto);
      final idx = _items.indexWhere((e) => getId(e) == id);
      if (idx == -1) {
        const msg = 'Dto not found';
        logOp(operation: operation, status: LogStatus.failure, message: msg);
        return Result.error(CustomException(message: msg));
      }
      _items[idx] = dto;
      logOp(operation: operation, status: LogStatus.success);
      return Result.ok(dto);
    } catch (e) {
      logOp(operation: operation, status: LogStatus.exception, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }

  Future<Result<void>> deleteRequest(ID id) async {
    const operation = 'deleteRequest';
    try {
      await _init();
      _items.removeWhere((e) => getId(e) == id);
      logOp(operation: operation, status: LogStatus.success);
      return Result.ok(null);
    } catch (e) {
      logOp(operation: operation, status: LogStatus.exception, message: e.toString());
      return Result.error(CustomException(message: e.toString()));
    }
  }
}
