import '../../domain/models/farmer_model.dart';
import '../../domain/models/payment_model.dart';
import '../../domain/repositories/farmer_repository.dart';
import '../../../../data/demo_catalog.dart';

class DemoFarmerRepository implements FarmerRepository {
  @override
  Future<List<FarmerModel>> getFarmers() async {
    return DemoCatalog.farmers;
  }

  @override
  Future<FarmerModel?> getFarmerById(String id) async {
    return DemoCatalog.farmerById(id);
  }

  @override
  Future<void> addFarmer(FarmerModel farmer) async {
    DemoCatalog.farmers.add(farmer);
  }

  @override
  Future<void> updateFarmer(FarmerModel farmer) async {
    final index = DemoCatalog.farmers.indexWhere((f) => f.id == farmer.id);
    if (index != -1) {
      DemoCatalog.farmers[index] = farmer;
    } else {
      DemoCatalog.farmers.add(farmer);
    }
  }

  @override
  Future<List<PaymentModel>> getPaymentsForFarmer(String farmerId, {String? sessionId}) async {
    return DemoCatalog.paymentsForFarmer(farmerId, sessionId: sessionId);
  }

  @override
  Future<void> addPayment(PaymentModel payment) async {
    DemoCatalog.addPayment(payment);
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    DemoCatalog.deletePayment(paymentId);
  }
}
