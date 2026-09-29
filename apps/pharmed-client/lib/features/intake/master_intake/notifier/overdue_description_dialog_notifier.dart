// [SWREQ-CLI-INTAKE-OVERDUE-002]
// Uygulama saati geçmiş ilaç alımı öncesi açıklama dialogunun state'i.
// Açıklamalar ya tüm kalemler için ortak ("same") ya da kalem bazında
// ("each") girilir; sonuç itemId → açıklama map'i olarak döner.
// Sınıf: Class B

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/core/mixins/api_request_mixin.dart';
import 'package:pharmed_client/core/providers/providers.dart';
import 'package:pharmed_core/pharmed_core.dart';

final overdueDescriptionDialogNotifierProvider = ChangeNotifierProvider.autoDispose<OverdueDescriptionDialogNotifier>((
  ref,
) {
  return OverdueDescriptionDialogNotifier(
    getDescriptionsUseCase: ref.read(getOverdueDescriptionsUseCaseProvider),
    createDescriptionUseCase: ref.read(createOverdueDescriptionUseCaseProvider),
  );
});

enum OverdueDescriptionMode { same, each }

/// Editördeki ipucu satırının durumu — metin view'da l10n ile çözülür.
enum OverdueDescriptionHint { idle, presetSelected, tooShort, alreadyPreset, canSaveAsPreset }

/// Bir kalemin (ya da ortak modun) açıklama girdisi. Ön tanımlı seçiliyse
/// [presetId] dolu ve [text] boştur; serbest metin yazıldığında [presetId] null'a çekilir.
@immutable
class OverdueDescriptionEntry {
  const OverdueDescriptionEntry({this.presetId, this.text = ''});

  static const empty = OverdueDescriptionEntry();

  final int? presetId;
  final String text;

  bool get isEmpty => presetId == null && text.trim().isEmpty;
}

class OverdueDescriptionDialogNotifier extends ChangeNotifier with ApiRequestMixin {
  OverdueDescriptionDialogNotifier({
    required GetOverdueDescriptionsUseCase getDescriptionsUseCase,
    required CreateOverdueDescriptionUseCase createDescriptionUseCase,
  }) : _getDescriptionsUseCase = getDescriptionsUseCase,
       _createDescriptionUseCase = createDescriptionUseCase;

  final GetOverdueDescriptionsUseCase _getDescriptionsUseCase;
  final CreateOverdueDescriptionUseCase _createDescriptionUseCase;

  static const int minLength = 10;
  static const int maxLength = 250;

  final OperationKey fetchPresetsOp = OperationKey.fetch();
  final OperationKey addPresetOp = OperationKey.custom('add-overdue-description');

  // ── State ─────────────────────────────────────────────────────────────

  List<IntakeItem> _items = const [];
  List<OverdueDescription> _presets = const [];

  /// Bu dialog oturumunda "Ön tanımlılara ekle" ile eklenenler — "YENİ" rozeti için.
  final Set<int> _addedPresetIds = {};

  OverdueDescriptionMode _mode = OverdueDescriptionMode.same;
  OverdueDescriptionEntry _shared = OverdueDescriptionEntry.empty;
  final Map<int, OverdueDescriptionEntry> _perItem = {};
  int _activeIndex = 0;

  /// Editör içeriği DIŞARIDAN değiştiğinde (mod/kalem geçişi, preset seçimi,
  /// "kalanlara uygula") artar. View, TextEditingController'ı yalnızca bu
  /// değiştiğinde senkronlar — kullanıcı yazarken imleç/odak kaybolmaz.
  int _editorRevision = 0;

  // ── Getterlar ─────────────────────────────────────────────────────────

  List<IntakeItem> get items => _items;
  List<OverdueDescription> get presets => _presets;
  OverdueDescriptionMode get mode => _mode;
  bool get isSame => _mode == OverdueDescriptionMode.same;
  int get activeIndex => _activeIndex;
  int get editorRevision => _editorRevision;

  IntakeItem? get activeItem => _items.elementAtOrNull(_activeIndex);

  bool isNewPreset(int? id) => id != null && _addedPresetIds.contains(id);

  OverdueDescriptionEntry entryFor(IntakeItem item) =>
      isSame ? _shared : (_perItem[item.id] ?? OverdueDescriptionEntry.empty);

  OverdueDescriptionEntry get activeEntry {
    if (isSame) return _shared;
    final item = activeItem;
    return item == null ? OverdueDescriptionEntry.empty : entryFor(item);
  }

  /// Bir girdinin kaydedilecek son metni — geçersizse null.
  String? valueOf(OverdueDescriptionEntry entry) {
    if (entry.presetId != null) {
      return _presets.firstWhereOrNull((p) => p.id == entry.presetId)?.description;
    }
    final trimmed = entry.text.trim();
    return trimmed.length >= minLength ? trimmed : null;
  }

  bool isValid(OverdueDescriptionEntry entry) => valueOf(entry) != null;

  int get validCount => _items.where((it) => isValid(entryFor(it))).length;
  bool get isComplete => _items.isNotEmpty && validCount == _items.length;

  bool get canGoPrev => !isSame && _activeIndex > 0;
  bool get canGoNext => !isSame && _activeIndex < _items.length - 1;
  bool get canApplyToRemaining => !isSame && _items.length > 1 && isValid(activeEntry);

  bool _isAlreadyPreset(String text) {
    final t = text.trim().toLowerCase();
    return _presets.any((p) => p.description?.trim().toLowerCase() == t);
  }

  bool get canAddPreset {
    final entry = activeEntry;
    final trimmed = entry.text.trim();
    return entry.presetId == null &&
        trimmed.length >= minLength &&
        !_isAlreadyPreset(trimmed) &&
        !isLoading(addPresetOp);
  }

  OverdueDescriptionHint get hint {
    final entry = activeEntry;
    final trimmed = entry.text.trim();
    if (entry.presetId != null) return OverdueDescriptionHint.presetSelected;
    if (trimmed.isEmpty) return OverdueDescriptionHint.idle;
    if (trimmed.length < minLength) return OverdueDescriptionHint.tooShort;
    if (_isAlreadyPreset(trimmed)) return OverdueDescriptionHint.alreadyPreset;
    return OverdueDescriptionHint.canSaveAsPreset;
  }

  // ── Başlatma ──────────────────────────────────────────────────────────

  /// Dialog açılırken bir kez çağrılır (post-frame).
  void init(List<IntakeItem> items) {
    _items = List.unmodifiable(items);
    _perItem
      ..clear()
      ..addEntries(items.map((it) => MapEntry(it.id, OverdueDescriptionEntry.empty)));
    _activeIndex = 0;
    _bumpEditor();
    fetchPresets();
  }

  Future<void> fetchPresets() async {
    await execute(
      fetchPresetsOp,
      operation: () => _getDescriptionsUseCase.call(),
      onData: (list) {
        _presets = list;
        notifyListeners();
      },
    );
  }

  // ── Mod / gezinme ─────────────────────────────────────────────────────

  /// "same" → "each" geçişinde, ortak açıklama geçerliyse henüz boş olan
  /// kalemlere kopyalanır — kullanıcı sadece farklı olanları düzenler.
  void setMode(OverdueDescriptionMode mode, {int? activeIndex}) {
    if (mode == OverdueDescriptionMode.each && isSame && isValid(_shared)) {
      for (final item in _items) {
        if (_perItem[item.id]?.isEmpty ?? true) _perItem[item.id] = _shared;
      }
    }
    _mode = mode;
    if (activeIndex != null) _activeIndex = activeIndex.clamp(0, _items.length - 1);
    _bumpEditor();
    notifyListeners();
  }

  /// Soldaki listeden bir kaleme dokunulduğunda — her zaman "each" moduna geçer.
  void focusItem(int index) => setMode(OverdueDescriptionMode.each, activeIndex: index);

  void goPrev() {
    if (!canGoPrev) return;
    _activeIndex--;
    _bumpEditor();
    notifyListeners();
  }

  void goNext() {
    if (!canGoNext) return;
    _activeIndex++;
    _bumpEditor();
    notifyListeners();
  }

  // ── Düzenleme ─────────────────────────────────────────────────────────

  /// Ön tanımlı açıklama seçer; aynı chip'e tekrar dokunulursa seçim kalkar.
  void togglePreset(int presetId) {
    final isOn = activeEntry.presetId == presetId;
    _patchActive(OverdueDescriptionEntry(presetId: isOn ? null : presetId));
    _bumpEditor();
    notifyListeners();
  }

  /// Serbest metin — preset seçimi kaldırılır. Editor revision ARTMAZ.
  void onTextChanged(String value) {
    final text = value.length > maxLength ? value.substring(0, maxLength) : value;
    _patchActive(OverdueDescriptionEntry(text: text));
    notifyListeners();
  }

  void applyToRemaining() {
    if (!canApplyToRemaining) return;
    final source = activeEntry;
    for (final item in _items) {
      _perItem[item.id] = source;
    }
    _bumpEditor();
    notifyListeners();
  }

  /// Yazılan metni ön tanımlılara ekler ve aktif girdide onu seçili yapar.
  Future<void> addActiveTextAsPreset({void Function(String message)? onFailed}) async {
    if (!canAddPreset) return;
    final text = activeEntry.text.trim();

    await execute(
      addPresetOp,
      operation: () => _createDescriptionUseCase.call(OverdueDescription(description: text)),
      onData: (created) {
        if (created?.id == null) return;
        _presets = [..._presets, created!];
        _addedPresetIds.add(created.id!);
        _patchActive(OverdueDescriptionEntry(presetId: created.id));
        _bumpEditor();
        notifyListeners();
      },
    );

    if (isFailed(addPresetOp)) onFailed?.call(message(addPresetOp) ?? '');
  }

  /// Onay sonrası dönen sonuç — yalnızca [isComplete] iken anlamlı.
  Map<int, String> buildResult() => {
    for (final item in _items)
      if (valueOf(entryFor(item)) case final value?) item.id: value,
  };

  // ── Yardımcılar ───────────────────────────────────────────────────────

  void _patchActive(OverdueDescriptionEntry entry) {
    if (isSame) {
      _shared = entry;
      return;
    }
    final item = activeItem;
    if (item != null) _perItem[item.id] = entry;
  }

  void _bumpEditor() => _editorRevision++;
}
