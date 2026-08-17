// import 'dart:async';

// import 'package:collection/collection.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pharmed_core/pharmed_core.dart';
// import 'package:pharmed_ui/pharmed_ui.dart';

// import '../../../../core/hardware/hardware.dart';
// import '../../../../core/providers/providers.dart';
// import '../../refill.dart';

// // Kabinde olan ilaçlar => Snapshottan gelir => baselineEpcs
// // Dolum yapılacak ilaçlar => Kullanıcının seçiminde gelir => expectedEpcs
// // Kabinden alınmaması gereken bir ilaç alındı =>

// // [SWREQ-CLI-REFILL-004] [IEC 62304 §5.5]
// // Mobil kabin ilaç dolum ekranı state yönetimi.
// //
// // Sorumluluk:
// //   - CabinVisualizerData'dan slot + atama verilerini alır
// //   - Göz seçimi → hasta bilgisini çözer → reçeteleri çeker
// //   - Dolum başlatma → çekmece açar → baseline RFID snapshot alır
// //   - Baseline sonrası reconciliation kümelerini kurar (rfid-stock-notifications §3)
// //   - Canlı RFID read/lost event'leriyle kümeleri güncel tutar (bidirectional)
// //   - Dolum tamamlama → KAYIT ÖNCE, ardından fire-and-forget bildirim akışı (§7)
// //
// // İlişkili dosyalar:
// //   - mobile_refill_state.dart   → state hiyerarşisi
// //   - mobile_refill_panel.dart   → sağ panel (action bar, prescription listesi)
// //   - mobile_refill_view.dart    → root view (scaffold + snackbar handling)
// //
// // Skill referansları:
// //   - rfid-stock-notifications   → bildirim akışı, reconciliation matematiği
// //   - pharmed-rfid-entegrasyonu  → orchestrator + RfidScanSession API'leri
// //
// // Sınıf: Class B

// final mobileRefillNotifierProvider = NotifierProvider<MobileRefillNotifier, MobileRefillState>(
//   MobileRefillNotifier.new,
// );

// class MobileRefillNotifier extends Notifier<MobileRefillState> {
//   late final MobileDrawerOrchestrator _drawer;
//   MobileDrawerStage get _drawerStage => ref.read(mobileDrawerSessionProvider).stage;

//   GetBedAssignmentsUseCase get _getAssignments => ref.read(getBedAssignmentsUseCaseProvider);
//   GetPatientPrescriptionHistoryUseCase get _getPrescriptionHistory =>
//       ref.read(getPatientPrescriptionHistoryUseCaseProvider);

//   RefillMobileCabinUseCase get _refillMobileCabin => ref.read(refillMobileCabinUseCaseProvider);
//   GetCabinExpectedEpcsUseCase get _getCabinExpectedEpcs => ref.read(getCabinExpectedEpcsUseCaseProvider);

//   /// Eksik Stok Bildirimi — UNPLANNED EPC'leri için backend'e bildirir.
//   /// Dolum'da `CabinInventoryType.refill` ile çağrılır.
//   ReportMissingStockUseCase get _reportMissingStock => ref.read(reportMissingStockUseCaseProvider);

//   // ── EXPECTED_MAP (§3) ───────────────────────────────────────────────────
//   // Baseline scan'in yan ürünü; reconciliation kümeleri kurulurken ve
//   // bildirim üretirken (EPC → itemId/materialId çözümü) kullanılır.
//   // State class'larında tutulmaz çünkü boyutu büyüyebilir ve reactive UI'a
//   // ihtiyaç duyulmaz. cancel/error/success akışlarında temizlenir.
//   Map<String, CabinExpectedEpc> _expectedMap = const <String, CabinExpectedEpc>{};

//   /// Saving sırasında çekmece kapandıysa true. Kayıt sonucu gelince
//   /// (_completeRefill) değerlendirilir: OK → doğrudan Success, hata → Error.
//   bool _closedDuringSaving = false;

//   @override
//   MobileRefillState build() {
//     // Drawer + RFID composition. Callback'ler operasyon semantiğine göre
//     // küme geçişlerini yönetir.
//     _drawer = MobileDrawerOrchestrator(ref: ref)
//       ..init(onStageChange: _onDrawerStageChange, onEpcRead: _onEpcRead, onEpcLost: _onEpcLost);
//     ref.onDispose(() => _drawer.dispose());

//     return const MobileRefillUninitialized();
//   }

//   /// Ekran açıldıktan sonra view tarafından bir kez çağrılır.
//   /// Cabin verisinden slot/mobileSlot listesini çıkarır ve atamaları yükler.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> init(CabinVisualizerData data) async {
//     final slots = data.slots.whereType<MobileSlotVisual>().toList();
//     final mobileSlots = data.mobileSlots;

//     state = MobileRefillLoading(slots: slots, cabinId: data.cabinId);

//     final assignmentResult = await _getAssignments.call(data.cabinId);

//     state = assignmentResult.when(
//       ok: (assignments) =>
//           MobileRefillIdle(slots: slots, mobileSlots: mobileSlots, assignments: assignments, cabinId: data.cabinId),
//       error: (e) => MobileRefillError(
//         message: e.message,
//         previousState: MobileRefillIdle(
//           slots: slots,
//           mobileSlots: mobileSlots,
//           assignments: const [],
//           cabinId: data.cabinId,
//         ),
//       ),
//     );
//   }

//   /// Sol panel'deki hasta listesinden bir hasta seçildiğinde çağrılır.
//   /// İlgili göze otomatik gider — mevcut [onCellTap] akışını kullanır.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> selectAssignment(BedAssignment assignment) async {
//     if (assignment.cellId == null) return;

//     final coord = state.assignmentByCoord.entries
//         .where((e) => e.value.id == assignment.id)
//         .map((e) => e.key)
//         .firstOrNull;
//     if (coord == null) return;

//     final slot = state.slots.where((s) => s.slotId == coord.$1).firstOrNull;
//     if (slot == null) return;
//     if (state.selectedSlotId != slot.slotId) {
//       onSlotTap(slot);
//     }

//     await onCellTap(coord);
//   }

//   /// Slot tıklandığında çağrılır. Aynı slot ikinci kez tıklanırsa seçim
//   /// iptal edilir (toggle).
//   ///
//   /// SWREQ-CLI-REFILL-001
//   void onSlotTap(MobileSlotVisual slot) {
//     final current = state;
//     final slots = current.slots;
//     final ms = current.mobileSlots;
//     final assignments = current.assignments;
//     final cabinId = current.cabinId;

//     if (current.selectedSlotId == slot.slotId) {
//       state = MobileRefillIdle(slots: slots, mobileSlots: ms, assignments: assignments, cabinId: cabinId);
//       return;
//     }

//     state = MobileRefillSlotSelected(
//       slots: slots,
//       mobileSlots: ms,
//       selectedSlot: slot,
//       assignments: assignments,
//       cabinId: cabinId,
//     );
//   }

//   /// Göz tıklandığında çağrılır. Hasta varsa reçeteleri yükler, yoksa
//   /// NoPatient'a geçer. Aynı göz ikinci kez tıklanırsa seçim iptal edilir.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> onCellTap(MobileCellCoord coord) async {
//     final current = state;
//     final selectedSlot = current.selectedSlot;
//     if (selectedSlot == null) return;

//     final slots = current.slots;
//     final ms = current.mobileSlots;
//     final assignments = current.assignments;
//     final cabinId = current.cabinId;

//     if (current.selectedCell == coord) {
//       state = MobileRefillSlotSelected(
//         slots: slots,
//         mobileSlots: ms,
//         selectedSlot: selectedSlot,
//         assignments: assignments,
//         cabinId: cabinId,
//       );
//       return;
//     }

//     final assignment = current.assignmentByCoord[coord];

//     if (assignment?.hospitalization?.patient == null) {
//       state = MobileRefillNoPatient(
//         slots: slots,
//         mobileSlots: ms,
//         selectedSlot: selectedSlot,
//         selectedCell: coord,
//         assignments: assignments,
//         cabinId: cabinId,
//       );
//       return;
//     }

//     await _loadPrescriptions(
//       slots: slots,
//       mobileSlots: ms,
//       selectedSlot: selectedSlot,
//       selectedCell: coord,
//       assignments: assignments,
//       cabinId: cabinId,
//       assignment: assignment!,
//     );
//   }

//   /// Ready/NoPatient state'inden hasta listesine geri döner.
//   /// Slot seçimi korunur (kullanıcı aynı çekmecedeyse devam edebilir).
//   ///
//   /// SWREQ-CLI-REFILL-001
//   void clearPatientSelection() {
//     final current = state;
//     final selectedSlot = current.selectedSlot;
//     if (selectedSlot == null) return;

//     state = MobileRefillSlotSelected(
//       slots: current.slots,
//       mobileSlots: current.mobileSlots,
//       selectedSlot: selectedSlot,
//       assignments: current.assignments,
//       cabinId: current.cabinId,
//     );
//   }

//   /// SWREQ-CLI-REFILL-001
//   void onDatePresetChanged(DateRangePreset preset) {
//     final current = state;
//     if (current is! MobileRefillReady) return;
//     state = current.copyWith(datePreset: preset);
//     _reloadPrescriptions();
//   }

//   /// SWREQ-CLI-REFILL-001
//   void onStatusFilterChanged(PrescriptionMovementType? type) {
//     final current = state;
//     if (current is! MobileRefillReady) return;
//     state = current.copyWith(statusFilter: type, clearStatusFilter: type == null);
//     _reloadPrescriptions();
//   }

//   /// İlaç işaretle/işareti kaldır.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   void toggleItemSelection(int itemId) {
//     final current = state;
//     if (current is! MobileRefillReady) return;

//     final item = current.prescriptionItems.firstWhereOrNull((i) => i.id == itemId);
//     if (item == null || !(item.status?.canFill ?? false)) return;

//     final next = {...current.selectedItemIds};
//     if (!next.add(itemId)) next.remove(itemId);
//     state = current.copyWith(selectedItemIds: next);
//   }

//   /// Filtre değişikliklerinde reçete listesini yeniden çeker.
//   /// Seçimi sıfırlar — eski seçim yeni listede olmayabilir.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> _reloadPrescriptions() async {
//     final current = state;
//     if (current is! MobileRefillReady) return;

//     final result = await _getPrescriptionHistory.call(
//       current.patient.id!,
//       params: PagedQueryParamsBuilder.fromPreset(
//         preset: current.datePreset,
//         filters: [if (current.statusFilter != null) Filter.eq('lastMovement.detailStatusId', current.statusFilter!.id)],
//       ),
//     );

//     result.when(
//       ok: (items) => state = current.copyWith(prescriptionItems: items, selectedItemIds: {}),
//       error: (e) => state = MobileRefillError(message: e.message, previousState: current),
//     );
//   }

//   /// Yeni bir göz seçildiğinde o hastanın reçetelerini yükler.
//   /// Loading sırasında sol/orta panel kaybolmasın diye [MobileRefillLoading]'e
//   /// slot/mobileSlots/assignments dolu olarak geçilir.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> _loadPrescriptions({
//     required List<MobileSlotVisual> slots,
//     required List<MobileDrawerSlot> mobileSlots,
//     required MobileSlotVisual selectedSlot,
//     required MobileCellCoord selectedCell,
//     required List<BedAssignment> assignments,
//     required int cabinId,
//     required BedAssignment assignment,
//   }) async {
//     final patient = assignment.hospitalization?.patient;
//     if (patient?.id == null) return;

//     state = MobileRefillLoading(
//       slots: slots,
//       cabinId: cabinId,
//       selectedSlot: selectedSlot,
//       mobileSlots: mobileSlots,
//       assignments: assignments,
//     );

//     final result = await _getPrescriptionHistory.call(
//       patient!.id!,
//       params: PagedQueryParamsBuilder.fromPreset(
//         preset: DateRangePreset.today,
//         filters: [
//           Filter.eq('lastMovement.detailStatusId', PrescriptionMovementType.filledWaiting.id),
//           Filter.eq('lastMovement.detailStatusId', PrescriptionMovementType.filledWaiting.id),
//         ],
//       ),
//     );

//     result.when(
//       ok: (items) {
//         state = MobileRefillReady(
//           slots: slots,
//           mobileSlots: mobileSlots,
//           selectedSlot: selectedSlot,
//           selectedCell: selectedCell,
//           assignments: assignments,
//           cabinId: cabinId,
//           patient: patient,
//           bed: assignment.bed,
//           room: assignment.bed?.room,
//           prescriptionItems: items,
//           selectedItemIds: const {},
//         );
//       },
//       error: (e) {
//         state = MobileRefillError(
//           message: e.message,
//           previousState: MobileRefillNoPatient(
//             slots: slots,
//             mobileSlots: mobileSlots,
//             selectedSlot: selectedSlot,
//             selectedCell: selectedCell,
//             assignments: assignments,
//             cabinId: cabinId,
//           ),
//         );
//       },
//     );
//   }

//   /// Doluma başla → orchestrator'a çekmece açma komutu gönderir.
//   ///
//   /// Akış:
//   ///   1. state = DrawerStarting (ready ile sarmalanır)
//   ///   2. _drawer.open() çağrılır
//   ///   3. Stage Opening → Opened geçişinde [_onDrawerStageChange] ready'e döner
//   ///   4. Opened anında [_scanCabin] tetiklenir
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> startRefill() async {
//     final current = state;
//     if (current is! MobileRefillReady) return;
//     if (current.selectedItemIds.isEmpty) return;

//     state = MobileRefillDrawerOpening(ready: current);

//     await _drawer.open(slots: current.slots, slot: current.selectedSlot);
//   }

//   /// Çekmece açıldıktan sonra baseline snapshot alır ve reconciliation yapar.
//   ///
//   /// Akış (rfid-stock-notifications §3 + §5.1 Dolum):
//   ///   1. GetCabinExpectedEpcsUseCase → EXPECTED listesi + EXPECTED_MAP
//   ///   2. _drawer.snapshot(1.5s) → OBSERVED (anlık kabin tag'leri)
//   ///   3. Reconciliation:
//   ///        passive    = OBSERVED ∩ EXPECTED   (kabin stoğu, dolum hedefi değil)
//   ///        unexpected = OBSERVED ∖ EXPECTED   (kabine ait olmayan tag → blokaj)
//   ///      Dolum'da MATCHED/NOT_FOUND kümeleri YOKTUR çünkü dolum hedefi
//   ///      ilaçların EPC'si henüz kabine yerleştirilmedi (yeni yerleştirme).
//   ///      Baseline sonrası yerleştirilen yeni tag'ler [_onEpcRead] tarafından
//   ///      rfidReadEpcs'e eklenecek.
//   ///   4. baselineCompleted = true ile state güncellenir
//   ///
//   /// Race condition: snapshot async (1.5s); tamamlandığında state hâlâ Ready
//   /// (veya sarmalayıcısı) olup olmadığı kontrol edilir — değilse atlanır.
//   ///
//   /// SWREQ-CLI-REFILL-006
//   Future<void> _scanCabin() async {
//     final current = state;
//     if (current is MobileRefillError) return;

//     final ready = current.readyContext;
//     if (ready == null) return;

//     // Beklenen kabin tag'lerini çek (EPC → prescriptionItemId lookup)
//     final expectedResult = await _getCabinExpectedEpcs.call(ready.cabinId);
//     String? errorMessage;
//     expectedResult.when(
//       ok: (value) => _expectedMap = {for (final e in value) (e.rfidTag ?? ''): e},
//       error: (e) => errorMessage = e.message,
//     );

//     if (errorMessage != null) {
//       state = MobileRefillError(message: errorMessage!, previousState: ready);
//       return;
//     }

//     // İlk snapshot → baseline (bir kez, sabit)
//     final observed = await _drawer.snapshot();
//     final after = state;
//     final afterReady = current.readyContext;
//     if (afterReady == null) return;

//     state = _withReady(after, afterReady.copyWith(baselineCompleted: true, baselineEpcs: observed));
//   }

//   /// ClosedEarly / Error → "İptal". Kayıt YOK. İşlemi bitirir, dialog kapanır.
//   /// Not: çekmece fiziksel olarak açık kalmış olabilir — UI kullanıcıya
//   /// "çekmeceyi kapatın" bilgisini gösterebilir.
//   /// SWREQ-CLI-REFILL-001
//   Future<void> cancelEarlyClose() async {
//     final current = state;
//     final ready = current.readyContext;

//     await _drawer.stop();
//     _resetExpectedMap();
//     _closedDuringSaving = false;

//     if (ready == null) {
//       // sahne yoksa gerçekten boşa dön
//       state = const MobileRefillIdle(slots: [], mobileSlots: [], assignments: [], cabinId: 0);
//       return;
//     }

//     // Sahneyi KORU (slots/mobileSlots/assignments/cabinId), sadece işlemi sıfırla
//     state = MobileRefillIdle(
//       slots: ready.slots,
//       mobileSlots: ready.mobileSlots,
//       assignments: ready.assignments,
//       cabinId: ready.cabinId,
//     );
//   }

//   /// ClosedEarly / Error → "Tekrar Dene". Çekmece yeniden açılır.
//   /// Baseline KORUNUR (reopen), _expectedMap KORUNUR — _scanCabin reopen dalına girer.
//   /// Runtime kümeleri (placedEpcs / baselineLostEpcs) de KORUNUR.
//   /// SWREQ-CLI-REFILL-012
//   Future<void> retryEarlyClose() async {
//     final current = state;
//     final ready = current.readyContext;
//     if (ready == null) return;

//     _closedDuringSaving = false;

//     // ready olduğu gibi taşınır (baseline + placedEpcs + baselineLostEpcs dahil).
//     // Sadece baselineCompleted false → UI "Tarama yapılıyor" gösterir,
//     // complete butonu reopen tamamlanana kadar disabled.
//     final reopening = ready.copyWith(baselineCompleted: false);
//     state = MobileRefillDrawerOpening(ready: reopening);

//     await ref.read(mobileDrawerSessionProvider.notifier).reopen();
//   }

//   /// Dolumu tamamla — drawer Closed durumunda çağrılır.
//   ///
//   /// Sıralama (rfid-stock-notifications §7 — KAYIT ÖNCE, BİLDİRİM SONRA):
//   ///
//   ///   1. state = Saving
//   ///   2. refillMobileCabin API → kayıt çağrısı
//   ///   3a. Kayıt FAIL → Error state, RFID state KORUNUR (retry için),
//   ///                    drawer state değiştirilmez
//   ///   3b. Kayıt OK → drawer.stop() + state = Success
//   ///   4. Arka planda fire-and-forget bildirim akışı (sıralı):
//   ///        - UNPLANNED EPC'leri → Eksik Stok Bildirimi (her biri tek tek)
//   ///        - RFID'siz manuel bildirimler
//   ///      UNEXPECTED_LOST için bildirim üretilmez (§5.1 Dolum matris)
//   ///   5. Bildirim hatası kullanıcıyı durdurmaz, log + snackbar
//   ///
//   /// canComplete (state'te tanımlı) zaten UI'da butonu disabled tutar:
//   ///   - baselineCompleted true
//   ///   - unexpectedEpcs.isEmpty (Dolum blokajı)
//   ///   - allSelectedRfidRead
//   ///
//   /// SWREQ-CLI-REFILL-010
//   Future<void> completeRefill() async {
//     final current = state;
//     if (current is! MobileRefillReady) return;
//     if (current.selectedItemIds.isEmpty) return;
//     if (!current.canComplete) return;

//     // YENİ akış: çekmece AÇIKKEN tamamlanır (kapalı değil)
//     if (_drawerStage is! MobileDrawerOpened) return;

//     state = MobileRefillSaving(ready: current);

//     final params = current.prescriptionItems
//         .where((i) => i.id != null && current.selectedItemIds.contains(i.id))
//         .map((i) => RefillMobileCabinParams(prescriptionDetailId: i.id!, epc: i.rfidTag))
//         .toList();

//     final result = await _refillMobileCabin(params);

//     result.when(
//       ok: (_) {
//         // Kayıt başarılı. Çekmece HÂLÂ AÇIK — kullanıcının kapatması beklenir.
//         // _expectedMap ve runtime kümeleri KORUNUR (kapanışta rapor için lazım).
//         if (_closedDuringSaving) {
//           // Kayıt uçarken kullanıcı çekmeceyi çoktan kapatmış → doğrudan kapanış akışı
//           _closedDuringSaving = false;
//           unawaited(_reportUnplannedMovements(current));
//           state = MobileRefillSuccess(ready: current);
//         } else {
//           // Normal: kapanışı bekle. RFID canlı dinlenmeye devam eder.
//           state = MobileRefillWaitingClose(ready: current);
//         }
//       },
//       error: (e) {
//         // Kayıt başarısız → Error (kurtarılabilir, "Tekrar Dene").
//         // RFID state + baseline KORUNUR; drawer'a dokunma (çekmece hâlâ açık).
//         _closedDuringSaving = false;
//         state = MobileRefillError(message: e.message, previousState: current);
//       },
//     );
//   }

//   /// Error state'inden completeRefill'i yeniden çağırır.
//   ///
//   /// Dialog'daki "Tekrar Dene" butonuna bağlanır. Önce dismissError ile state
//   /// Ready'e döndürülür, ardından completeRefill başlatılır. Drawer hâlâ Closed
//   /// olduğu için sıradan completeRefill akışı aynen tekrar çalışır.
//   ///
//   /// SWREQ-CLI-REFILL-010
//   Future<void> retryComplete() async {
//     final current = state;
//     if (current is! MobileRefillError) return;

//     final ready = current.previousState.readyContext;
//     if (ready == null) return;

//     state = ready; // Error → Ready
//     await completeRefill(); // guard'lar geçer, tekrar Saving
//   }

//   /// Hiçbir bildirim hatası kullanıcıyı durdurmaz; sadece log atılır.
//   ///
//   /// Bildirim türleri (rfid-stock-notifications §6 — Dolum matris):
//   ///   - UNPLANNED       → ReportMissingStockUseCase (Eksik Stok bildirimi)
//   ///   - UNEXPECTED_LOST → bildirim YOK (düzeltici hareket)
//   ///   - NOT_FOUND       → N/A (Dolum'da SELECTED EPC'leri yok)
//   ///   - Manuel buton    → Yok (Dolum'da kullanıcı dolduran taraf, bildirmesine gerek yok)
//   ///
//   /// UNPLANNED EPC'lerini prescriptionItemId'ye çevirmek için
//   /// [expectedSnapshot] parametresi kullanılır. Notifier-level `_expectedMap`
//   /// complete sırasında reset edildiği için snapshot parametre olarak alınır
//   /// (race condition guard).
//   ///
//   /// SWREQ-CLI-REFILL-011
//   Future<void> _reportUnplannedMovements(MobileRefillReady ready) async {
//     final missing = ready.missingEpcs;
//     if (missing.isEmpty) return;

//     for (final epc in missing) {
//       final prescriptionItemId = _expectedMap[epc]?.prescriptionItemId;
//       if (prescriptionItemId == null) {
//         continue;
//       }

//       await _reportMissingStock.call(prescriptionItemId: prescriptionItemId, type: CabinInventoryType.refill);
//     }
//   }

//   /// EPC okundu — çekmecede bir tag göründü.
//   ///
//   /// Davranış (rfid-stock-notifications §3 bidirectional geçişler):
//   ///
//   ///   1. Baseline öncesi → ignore (snapshot zaten çalışıyor)
//   ///   2. Hata kümesinden geri dönüş varsa → orijinal kategorisini restore et:
//   ///        UNPLANNED      → PASSIVE        (kullanıcı geri koydu)
//   ///        UNEXPECTED_LOST→ UNEXPECTED     (kullanıcı tekrar koydu → tekrar blokaj)
//   ///   3. Hiç bilinmiyorsa (ilk kez):
//   ///        EXPECTED'da var → PASSIVE       (geç gelen kabin stoğu)
//   ///        EXPECTED'da yok → rfidReadEpcs  (yerleştirilen yeni dolum tag'i)
//   ///   4. Zaten bilinen bir kümede → dedup, hiçbir şey yapma
//   ///
//   /// SWREQ-CLI-REFILL-007
//   void _onEpcRead(String epc) {
//     final current = state;
//     final ready = current.readyContext;
//     if (ready == null) return;

//     // KORUMA: baseline bitmediyse okunan her etiket kabinin kendi malı;
//     // unexpected/placed sayılamaz.
//     if (!ready.baselineCompleted) return;

//     // Baseline'daki bir tag geri okundu → lost'tan çıkar (kullanıcı geri koydu)
//     if (ready.baselineEpcs.contains(epc)) {
//       if (ready.baselineLostEpcs.contains(epc)) {
//         state = _withReady(
//           current,
//           ready.copyWith(baselineLostEpcs: Set<String>.from(ready.baselineLostEpcs)..remove(epc)),
//         );
//       }
//       return; // baseline'da ve hâlâ duruyor → değişiklik yok (dedup)
//     }

//     // Baseline'da olmayan yeni tag → yerleştirme (dedup: set zaten idempotent)
//     if (ready.placedEpcs.contains(epc)) return;
//     state = _withReady(current, ready.copyWith(placedEpcs: {...ready.placedEpcs, epc}));
//   }

//   /// EPC kayboldu — çekmeceden tag çıktı (presence timeout).
//   ///
//   /// Davranış (rfid-stock-notifications §5.1 Dolum):
//   ///
//   ///   - rfidReadEpcs'te → sessiz çıkar (kullanıcı yerleştirdiğini geri aldı)
//   ///   - passiveEpcs'te  → UNPLANNED'a yaz (izinsiz çıkış → bildirim)
//   ///   - unexpectedEpcs'te → UNEXPECTED_LOST'a yaz (düzeltici → bildirim YOK)
//   ///   - Bilinmiyor → ignore
//   ///
//   /// SWREQ-CLI-REFILL-008
//   void _onEpcLost(String epc) {
//     final current = state;
//     final ready = current.readyContext;
//     if (ready == null) return;
//     if (!ready.baselineCompleted) return;

//     // Yerleştirilen dolum tag'i geri alındı → placed'den çıkar (sessiz)
//     if (ready.placedEpcs.contains(epc)) {
//       state = _withReady(current, ready.copyWith(placedEpcs: Set<String>.from(ready.placedEpcs)..remove(epc)));
//       return;
//     }

//     // Baseline'daki bir tag çıktı → izinsiz çıkış (baselineLostEpcs'e ekle)
//     if (ready.baselineEpcs.contains(epc)) {
//       if (ready.baselineLostEpcs.contains(epc)) return; // zaten lost, dedup
//       state = _withReady(current, ready.copyWith(baselineLostEpcs: {...ready.baselineLostEpcs, epc}));
//       return;
//     }

//     // Ne placed ne baseline — bilinmiyor, ignore
//   }

//   /// Orchestrator'ın drawer stage callback'i.
//   ///
//   /// Olaylar (rfid-stock-notifications §4):
//   ///   - Opened ilk geçiş      → DrawerStarting ise Ready'e dön + baseline başlat
//   ///   - Closed/Failed         → orchestrator zaten RFID'yi durdurur
//   ///   - Failed                → tüm RFID + seçim state'i sıfırla, Error state
//   ///
//   /// SWREQ-CLI-REFILL-001
//   void _onDrawerStageChange(MobileDrawerStage? prev, MobileDrawerStage next) {
//     // ── Çekmece açıldı → sahneye geç, baseline tara ──────────────────────
//     if (next is MobileDrawerOpened) {
//       final current = state;
//       if (current is MobileRefillDrawerOpening) {
//         state = current.ready;
//         unawaited(_scanCabin());
//       }
//     }

//     // ── Çekmece kapandı ──────────────────────────────────────────────────
//     if (next is MobileDrawerClosed) {
//       final current = state;
//       switch (current) {
//         // Normal akış: kayıt gitti, kapanış bekleniyordu → bildir + Success
//         case MobileRefillWaitingClose(:final ready):
//           unawaited(_reportUnplannedMovements(ready));
//           state = MobileRefillSuccess(ready: ready);

//         // Kayıt uçuşta kapandı → hemen işleme, flag'le; Saving çözülünce bak
//         case MobileRefillSaving():
//           _closedDuringSaving = true;

//         // Tamamla denmeden kapandı → kullanıcıya karar sor
//         case MobileRefillReady r:
//           state = MobileRefillClosedEarly(ready: r);

//         default:
//           break;
//       }
//     }

//     // ── Çekmece donanım hatası → kurtarılamaz, FatalError ────────────────
//     if (next is MobileDrawerFailed) {
//       _resetExpectedMap();
//       final current = state;
//       final cleaned = switch (current) {
//         MobileRefillReady r => r.clearedRfidState.copyWith(selectedItemIds: const {}),
//         MobileRefillDrawerOpening(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
//         MobileRefillWaitingClose(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
//         MobileRefillSaving(:final ready) => ready.clearedRfidState.copyWith(selectedItemIds: const {}),
//         _ => current,
//       };
//       state = MobileRefillFatalError(
//         failure: CabinDrawerFailure(failure: next.failure, detail: next.detail),
//         previousState: cleaned,
//       );
//     }
//   }

//   /// Error snackbar kapatıldığında previousState'e geri döner.
//   /// Complete fail durumunda previousState RFID state'li Ready'dir → kullanıcı
//   /// retry edebilir.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   void dismissError() {
//     final current = state;
//     final previous = switch (current) {
//       MobileRefillError(:final previousState) => previousState,
//       MobileRefillFatalError(:final previousState) => previousState,
//       _ => null,
//     };
//     if (previous == null) return;

//     unawaited(_drawer.stop());
//     _resetExpectedMap();

//     // previousState'ten gerçek Ready'yi çıkar — wrapper/NoPatient olabilir.
//     final ready = current.readyContext;
//     state = ready ?? previous;
//   }

//   /// Success snackbar kapatıldığında işlem sonlanır: drawer kapatılır ve
//   /// slot seçim ekranına (Idle) dönülür. Kullanıcı yeni hasta/slot seçer.
//   ///
//   /// SWREQ-CLI-REFILL-001
//   Future<void> dismissSuccess() async {
//     final current = state;
//     if (current is! MobileRefillSuccess) return;

//     await _drawer.stop(); // stage → Idle, ActionBar "Başlat" gösterir

//     state = MobileRefillIdle(
//       slots: current.slots,
//       mobileSlots: current.mobileSlots,
//       assignments: current.assignments,
//       cabinId: current.cabinId,
//     );
//   }

//   /// Sarmalayıcı state'in [ready] alanını günceller; sarmalanmamış Ready'i
//   /// doğrudan döner. Tanımsız state'ler değişmeden döner.
//   MobileRefillState _withReady(MobileRefillState s, MobileRefillReady ready) => switch (s) {
//     MobileRefillReady _ => ready,
//     MobileRefillDrawerOpening _ => MobileRefillDrawerOpening(ready: ready),
//     MobileRefillSaving _ => MobileRefillSaving(ready: ready),
//     MobileRefillWaitingClose _ => MobileRefillWaitingClose(ready: ready),
//     MobileRefillClosedEarly _ => MobileRefillClosedEarly(ready: ready),
//     _ => s,
//   };

//   /// Baseline'ın yan ürünü olan EXPECTED_MAP'i boşaltır.
//   /// Cancel, success, reopen, drawer failed akışlarında çağrılır.
//   void _resetExpectedMap() {
//     _expectedMap = const <String, CabinExpectedEpc>{};
//   }
// }
