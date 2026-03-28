import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../domain/entity/patient.dart';
import '../../domain/repository/i_patient_repository.dart';

class PatientSelectionListViewModel extends ChangeNotifier {
  final IPatientRepository _patientRepository;

  // Variables
  APIRequestStatus _getStatus = APIRequestStatus.initial;
  String? _statusMessage;
  List<Patient> _patients = [];
  Patient? _selectedPatient;
  String _searchQuery = '';

  PatientSelectionListViewModel({required IPatientRepository patientRepository})
      : _patientRepository = patientRepository;

  // Getters
  APIRequestStatus get getStatus => _getStatus;
  String? get statusMessage => _statusMessage;
  Patient? get selectedPatient => _selectedPatient;

  List<Patient> get patients {
    var filtered = _patients;

    if (_searchQuery.isNotEmpty) {
      filtered = _searchInPatients(filtered, _searchQuery);
    }

    return filtered;
  }

  // Setters

  set selectedPatient(Patient? patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  // Functions

  Future<void> getPatients() async {
    _getStatus = APIRequestStatus.loading;
    _statusMessage = null;

    final res = await _patientRepository.getPatients();
    res.when(
      ok: (response) {
        _patients = response.data ?? [];
        _getStatus = APIRequestStatus.success;
        notifyListeners();
      },
      error: (error) {
        _getStatus = APIRequestStatus.failed;
        _statusMessage = error.message;
        notifyListeners();
      },
    );
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Helpers
  List<Patient> _searchInPatients(List<Patient> patients, String query) {
    if (query.isEmpty) return patients;

    return patients.where((p) {
      bool name = p.fullName.toLowerCase().contains(query.toLowerCase());
      bool tc = p.tcNo?.toString().toLowerCase().contains(query.toLowerCase()) ?? false;

      return name || tc;
    }).toList();
  }
}
