import 'package:flutter/foundation.dart';
import '../domain/models/procurement_model.dart';
import '../domain/repositories/procurement_repository.dart';

class ProcurementProvider with ChangeNotifier {
  final ProcurementRepository _repository;

  ProcurementProvider(this._repository);

  Future<List<ProcurementModel>> getRecentProcurements() {
    return _repository.getRecentProcurements();
  }

  Future<List<ProcurementModel>> getProcurementsForSession(String sessionId) {
    return _repository.getProcurementsForSession(sessionId);
  }

  Future<List<ProcurementModel>> getProcurementsForFarmer(String farmerId, {String? sessionId}) {
    return _repository.getProcurementsForFarmer(farmerId, sessionId: sessionId);
  }

  Future<ProcurementModel?> getProcurementById(String id) {
    return _repository.getProcurementById(id);
  }

  Future<void> addProcurement(ProcurementModel procurement) async {
    await _repository.addProcurement(procurement);
    notifyListeners();
  }

  Future<void> updateProcurement(ProcurementModel procurement) async {
    await _repository.updateProcurement(procurement);
    notifyListeners();
  }

  Future<double> getTotalNetWeightForSession(String sessionId) {
    return _repository.getTotalNetWeightForSession(sessionId);
  }

  Future<(double due, double paid)> getFinancialTotalsForSession(String sessionId) {
    return _repository.getFinancialTotalsForSession(sessionId);
  }

  Future<List<double>> getLastSevenDayIntake() {
    return _repository.getLastSevenDayIntake();
  }
}
