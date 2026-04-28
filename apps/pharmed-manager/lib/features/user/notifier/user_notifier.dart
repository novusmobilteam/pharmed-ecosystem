import 'package:flutter/material.dart';

import '../../../core/core.dart';

import '../../../core/widgets/unified_table/unified_table_models.dart';

class UserNotifier extends ChangeNotifier with ApiRequestMixin, PaginationMixin<User>, SidePanelMixin<User, Never> {
  final GetUsersUseCase _getUsersUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final BulkUpdateValidDateUseCase _bulkUpdateValidDateUseCase;

  UserNotifier({
    required GetUsersUseCase getUsersUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    required BulkUpdateValidDateUseCase bulkUpdateValidDateUseCase,
  }) : _getUsersUseCase = getUsersUseCase,
       _deleteUserUseCase = deleteUserUseCase,
       _bulkUpdateValidDateUseCase = bulkUpdateValidDateUseCase;

  final OperationKey deleteOp = OperationKey.delete();
  final OperationKey updateValidDateOp = OperationKey.custom('update_valid_date');

  final Map<UserType, List<User>> _usersByType = {UserType.normal: [], UserType.timeBased: [], UserType.temporary: []};

  final Map<UserType, int> _totalCountByType = {UserType.normal: 0, UserType.timeBased: 0, UserType.temporary: 0};

  UserType _selectedCategory = UserType.normal;
  UserType get selectedCategory => _selectedCategory;

  List<User> _selectedUsers = [];
  String _searchQuery = '';
  DateTime validDate = DateTime.now();

  bool get isFetching => isTableLoading;
  bool get showValidDateIcon => _selectedCategory == UserType.timeBased && _selectedUsers.isNotEmpty;

  List<User> get users => _usersByType[_selectedCategory] ?? [];

  /// Pagination footer için: seçili tipin toplam kayıt sayısı
  int get currentTypeTotal => _totalCountByType[_selectedCategory] ?? 0;

  List<TableSideCategory> get tableCategories => [
    TableSideCategory(id: UserType.normal.name, label: 'Normal', count: _totalCountByType[UserType.normal] ?? 0),
    TableSideCategory(id: UserType.timeBased.name, label: 'Süreli', count: _totalCountByType[UserType.timeBased] ?? 0),
    TableSideCategory(id: UserType.temporary.name, label: 'Geçici', count: _totalCountByType[UserType.temporary] ?? 0),
  ];

  Future<void> init() => _fetchAllTypes();

  Future<void> _fetchAllTypes() async {
    try {
      final results = await Future.wait([
        _getUsersUseCase.call(GetUsersParams(type: UserType.normal, skip: 0, take: pageSize)),
        _getUsersUseCase.call(GetUsersParams(type: UserType.timeBased, skip: 0, take: pageSize)),
        _getUsersUseCase.call(GetUsersParams(type: UserType.temporary, skip: 0, take: pageSize)),
      ]);

      _usersByType[UserType.normal] = results[0].data?.data ?? [];
      _usersByType[UserType.timeBased] = results[1].data?.data ?? [];
      _usersByType[UserType.temporary] = results[2].data?.data ?? [];

      _totalCountByType[UserType.normal] = results[0].data?.totalCount ?? 0;
      _totalCountByType[UserType.timeBased] = results[1].data?.totalCount ?? 0;
      _totalCountByType[UserType.temporary] = results[2].data?.totalCount ?? 0;

      notifyListeners();
    } catch (_) {}
  }

  Future<void> getUsers() async {
    await fetchPagedData(
      fetchMethod: (skip, take) =>
          _getUsersUseCase.call(GetUsersParams(type: _selectedCategory, skip: skip, take: take, search: _searchQuery)),
    );

    _usersByType[_selectedCategory] = items;
    _totalCountByType[_selectedCategory] = totalCount;
    notifyListeners();
  }

  void selectCategory(UserType type) {
    if (_selectedCategory == type) return;
    _selectedCategory = type;
    _selectedUsers.clear();
    _searchQuery = '';
    setPage(1);
    notifyListeners();
  }

  void search(String query) {
    debouncedSearch(query, () {
      _searchQuery = query;
      setPage(1);
      getUsers();
    });
  }

  void selectUsers(Set<User> selected) {
    _selectedUsers = selected.toList();
    notifyListeners();
  }

  Future<void> deleteUser(User user) async {
    await executeVoid(
      deleteOp,
      operation: () => _deleteUserUseCase.call(user.id ?? 0),
      onSuccess: () => _fetchAllTypes(), // tüm count + listeleri tazele
      successMessage: 'Kullanıcı başarıyla silindi',
    );
  }

  Future<void> updateValidDate() async {
    final ids = _selectedUsers.map((u) => u.id ?? 0).toList();
    await executeVoid(
      updateValidDateOp,
      operation: () => _bulkUpdateValidDateUseCase.call(BulkUpdateValidDateParams(date: validDate, ids: ids)),
      onSuccess: () {
        _selectedUsers.clear();
        getUsers(); // sadece seçili tipi (süreli) tazele
      },
      successMessage: 'Son geçerlilik tarihi güncellendi',
    );
  }
}
