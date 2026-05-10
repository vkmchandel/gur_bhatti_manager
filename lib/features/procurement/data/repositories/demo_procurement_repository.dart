import '../../domain/models/procurement_model.dart';
import '../../domain/repositories/procurement_repository.dart';
import '../../../../data/demo_catalog.dart';

class DemoProcurementRepository implements ProcurementRepository {
  @override
  Future<List<ProcurementModel>> getRecentProcurements({int n = 5}) async {
    return DemoCatalog.recentProcurements(n: n);
  }

  @override
  Future<List<ProcurementModel>> getProcurementsForSession(String sessionId) async {
    return DemoCatalog.procurementsForSession(sessionId);
  }

  @override
  Future<List<ProcurementModel>> getProcurementsForFarmer(String farmerId, {String? sessionId}) async {
    return DemoCatalog.procurementsForFarmer(farmerId, sessionId: sessionId);
  }

  @override
  Future<ProcurementModel?> getProcurementById(String id) async {
    try {
      return DemoCatalog.procurements.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addProcurement(ProcurementModel procurement) async {
    DemoCatalog.addProcurement(procurement);
  }

  @override
  Future<void> updateProcurement(ProcurementModel procurement) async {
    DemoCatalog.updateProcurement(procurement);
  }

  @override
  Future<double> getTotalNetWeightForSession(String sessionId) async {
    return DemoCatalog.totalNetWeightQtlForSession(sessionId);
  }

  @override
  Future<(double due, double paid)> getFinancialTotalsForSession(String sessionId) async {
    return DemoCatalog.financialTotalsForSession(sessionId);
  }

  @override
  Future<List<double>> getLastSevenDayIntake() async {
    return DemoCatalog.lastSevenDayIntakeQtl();
  }
}
