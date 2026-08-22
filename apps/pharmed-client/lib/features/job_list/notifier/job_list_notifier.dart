import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmed_client/features/job_list/notifier/job_list_state.dart';
import 'package:pharmed_core/pharmed_core.dart';

import '../../../core/providers/providers.dart';

final jobListNotifierProvider = NotifierProvider<JobListNotifier, JobListState>(JobListNotifier.new);

class JobListNotifier extends Notifier<JobListState> {
  GetMyPatientsUseCase get _getMyPatients => ref.read(getMyPatientsUseCaseProvider);
  GetDailyJobListUseCase get _getJobList => ref.read(getDailyJobListUseCaseProvider);

  @override
  JobListState build() => const JobListUninitialized();

  Future<void> init() async {
    state = JobListLoading();

    final myResult = await _getMyPatients.call();

    if (myResult is Error) {
      state = JobListError(
        message: (myResult as Error).error.message,
        previousState: JobListIdle(allPatients: const [], selectedHospitalization: null, jobList: const []),
      );
      return;
    }

    final myPatients = (myResult as Ok<List<MyPatient>>).data ?? [];
    final allPatients = _toHospitalizations(myPatients);

    state = JobListIdle(allPatients: allPatients, selectedHospitalization: null, jobList: const []);

    // Liste boş değilse ilk eleman otomatik seçilir.
    if (allPatients.isNotEmpty) {
      await selectPatient(allPatients.first);
    }
  }

  Future<void> selectPatient(Hospitalization hospitalization) async {
    final hospId = hospitalization.id;
    if (hospId == null) return;

    final current = state;
    if (current is! JobListIdle) return;

    state = current.copyWith(selectedHospitalization: hospitalization, isJobListLoading: true);

    final result = await _getJobList.call(hospId);

    final afterFetch = state;
    if (afterFetch is! JobListIdle) return;
    // Fetch sürerken kullanıcı başka bir hastaya tıkladıysa, eski sonucu uygulama.
    if (afterFetch.selectedHospitalizationId != hospId) return;

    result.when(
      ok: (jobList) {
        state = afterFetch.copyWith(jobList: jobList, isJobListLoading: false);
      },
      error: (e) {
        state = JobListError(message: e.message, previousState: afterFetch.copyWith(isJobListLoading: false));
      },
    );
  }

  void onSearchChanged(String value) {
    final current = state;
    if (current is JobListIdle) {
      state = current.copyWith(search: value);
    }
  }

  void dismissError() {
    final current = state;
    if (current is JobListError) state = current.previousState;
  }

  List<Hospitalization> _toHospitalizations(List<MyPatient> patients) {
    return patients.map((p) => p.hospitalization).whereType<Hospitalization>().toList();
  }
}
