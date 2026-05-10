import 'package:flutter/foundation.dart';
import '../domain/models/farmer_model.dart';
import '../domain/models/payment_model.dart';
import '../domain/repositories/farmer_repository.dart';

class FarmerProvider with ChangeNotifier {
  final FarmerRepository _repository;
  List<FarmerModel> _farmers = [];

  FarmerProvider(this._repository) {
    _loadFarmers();
  }

  List<FarmerModel> get farmers => _farmers;

  Future<void> _loadFarmers() async {
    _farmers = await _repository.getFarmers();
    notifyListeners();
  }

  Future<void> addFarmer(FarmerModel farmer) async {
    await _repository.addFarmer(farmer);
    await _loadFarmers();
  }

  Future<void> updateFarmer(FarmerModel farmer) async {
    await _repository.updateFarmer(farmer);
    await _loadFarmers();
  }

  List<FarmerModel> searchFarmers(String query) {
    if (query.isEmpty) return _farmers;
    final lowerQuery = query.toLowerCase();
    return _farmers.where((f) {
      return f.name.toLowerCase().contains(lowerQuery) || 
             f.village.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  FarmerModel? getFarmerById(String id) {
    try {
      return _farmers.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get knownVillages {
    final names = _farmers.map((f) => f.village).toSet().toList()..sort();
    return names;
  }
  
  Future<List<PaymentModel>> getPaymentsForFarmer(String farmerId, {String? sessionId}) async {
    return _repository.getPaymentsForFarmer(farmerId, sessionId: sessionId);
  }

  Future<void> addPayment(PaymentModel payment) async {
    await _repository.addPayment(payment);
    notifyListeners();
  }

  Future<void> deletePayment(String paymentId) async {
    await _repository.deletePayment(paymentId);
    notifyListeners();
  }
}
