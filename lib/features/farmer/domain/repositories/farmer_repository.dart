import '../models/farmer_model.dart';
import '../models/payment_model.dart';

abstract class FarmerRepository {
  Future<List<FarmerModel>> getFarmers();
  Future<FarmerModel?> getFarmerById(String id);
  Future<void> addFarmer(FarmerModel farmer);
  Future<void> updateFarmer(FarmerModel farmer);
  
  Future<List<PaymentModel>> getPaymentsForFarmer(String farmerId, {String? sessionId});
  Future<void> addPayment(PaymentModel payment);
  Future<void> deletePayment(String paymentId);
}
