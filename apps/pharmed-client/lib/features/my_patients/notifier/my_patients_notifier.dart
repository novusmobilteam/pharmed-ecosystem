// [SWREQ-UI-MYPATIENTS-NOTIFIER-001]
// Sınıf : Class A

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';
import '../../auth/presentation/notifier/auth_notifier.dart';
import 'my_patients_state.dart';

final myPatientsNotifierProvider = NotifierProvider<MyPatientsNotifier, MyPatientsState>(MyPatientsNotifier.new);

class MyPatientsNotifier extends Notifier<MyPatientsState> {
  GetBedAssignmentsUseCase get _getBedAssignments => ref.read(getBedAssignmentsUseCaseProvider);
  GetMyPatientsUseCase get _getMyPatients => ref.read(getMyPatientsUseCaseProvider);
  AddPatientUseCase get _addPatient => ref.read(addPatientUseCaseProvider);
  RemovePatientsUseCase get _removePatients => ref.read(removePatientsUseCaseProvider);

  /// Oturum açmış kullanıcının ID'si.
  int get _currentUserId => ref.read(authNotifierProvider.notifier).currentUser?.id ?? 0;

  @override
  MyPatientsState build() => const MyPatientsUninitialized();

  Future<void> init(int cabinId) async {
    if (state.cabinId == cabinId && state is! MyPatientsUninitialized) return;

    state = MyPatientsLoading(cabinId: cabinId);

    // Her iki listeyi paralel çek.
    final results = await Future.wait([_getBedAssignments.call(cabinId), _getMyPatients.call()]);

    final bedResult = results[0] as Result<List<BedAssignment>>;
    final myResult = results[1] as Result<List<MyPatient>>;

    if (bedResult is Error) {
      state = MyPatientsError(
        message: (bedResult as Error).error.message,
        previousState: MyPatientsIdle(cabinId: cabinId, allPatients: const [], myPatients: const []),
      );
      return;
    }
    if (myResult is Error) {
      state = MyPatientsError(
        message: (myResult as Error).error.message,
        previousState: MyPatientsIdle(cabinId: cabinId, allPatients: const [], myPatients: const []),
      );
      return;
    }

    final assignments = (bedResult as Ok<List<BedAssignment>>).data;
    final myPatients = (myResult as Ok<List<MyPatient>>).data;

    state = MyPatientsIdle(
      cabinId: cabinId,
      allPatients: _toHospitalizations(assignments ?? []),
      myPatients: myPatients ?? [],
    );
  }

  Future<void> addPatient(Hospitalization hospitalization) async {
    final hospId = hospitalization.id;
    if (hospId == null) return;

    final current = state;
    if (current is! MyPatientsIdle) return;

    // Zaten bende varsa işlem yapma.
    if (current.myPatientHospitalizationIds.contains(hospId)) return;

    // Butonu spinner'a çevir.
    state = current.copyWith(pendingIds: {...current.pendingIds, hospId});

    final result = await _addPatient.call(AddPatientParams(userId: _currentUserId, hospitalizationId: hospId));

    final afterPending = state;
    if (afterPending is! MyPatientsIdle) return;

    final updatedPending = {...afterPending.pendingIds}..remove(hospId);

    result.when(
      ok: (_) async {
        final refreshResult = await _getMyPatients.call();
        refreshResult.when(
          ok: (myPatients) {
            state = afterPending.copyWith(myPatients: myPatients, pendingIds: updatedPending);
          },
          error: (_) {
            // Refresh hata verse bile pending'i kaldır,
            // mevcut listeyle devam et
            state = afterPending.copyWith(pendingIds: updatedPending);
          },
        );
      },
      error: (e) {
        state = MyPatientsError(
          message: e.message,
          previousState: afterPending.copyWith(pendingIds: updatedPending),
        );
      },
    );
  }

  Future<void> removePatient(MyPatient patient) async {
    final myPatientId = patient.id;
    final hospId = patient.hospitalization?.id;
    if (myPatientId == null || hospId == null) return;

    final current = state;
    if (current is! MyPatientsIdle) return;

    // Butonu spinner'a çevir.
    state = current.copyWith(pendingIds: {...current.pendingIds, hospId});

    final result = await _removePatients.call([myPatientId]);

    final afterPending = state;
    if (afterPending is! MyPatientsIdle) return;

    final updatedPending = {...afterPending.pendingIds}..remove(hospId);

    result.when(
      ok: (_) {
        state = afterPending.copyWith(
          myPatients: afterPending.myPatients.where((p) => p.id != myPatientId).toList(),
          pendingIds: updatedPending,
        );
      },
      error: (e) {
        state = MyPatientsError(
          message: e.message,
          previousState: afterPending.copyWith(pendingIds: updatedPending),
        );
      },
    );
  }

  void onSearchChanged(String value) {
    final current = state;
    if (current is MyPatientsIdle) {
      state = current.copyWith(search: value);
    }
  }

  void dismissError() {
    final current = state;
    if (current is MyPatientsError) state = current.previousState;
  }

  List<Hospitalization> _toHospitalizations(List<BedAssignment> assignments) {
    return assignments.map((a) => a.hospitalization).whereType<Hospitalization>().toList();
  }
}
