import '../models/procurement_model.dart';

abstract class ProcurementRepository {
  Future<List<ProcurementModel>> getRecentProcurements({int n = 5});
  Future<List<ProcurementModel>> getProcurementsForSession(String sessionId);
  Future<List<ProcurementModel>> getProcurementsForFarmer(String farmerId, {String? sessionId});
  Future<ProcurementModel?> getProcurementById(String id);
  Future<void> addProcurement(ProcurementModel procurement);
  Future<void> updateProcurement(ProcurementModel procurement);
  
  Future<double> getTotalNetWeightForSession(String sessionId);
  Future<(double due, double paid)> getFinancialTotalsForSession(String sessionId);
  Future<List<double>> getLastSevenDayIntake();
}
