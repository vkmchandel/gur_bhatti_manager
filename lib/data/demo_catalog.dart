import '../core/domain/payment_status.dart';
import '../features/farmer/domain/models/farmer_model.dart';
import '../features/procurement/domain/models/procurement_model.dart';
import '../features/session/domain/models/session_model.dart';
import '../features/farmer/domain/models/payment_model.dart';

/// Central demo data for UI flows; replace with API/repository.
abstract final class DemoCatalog {
  static const String activeSessionId = 's25';

  static final List<SessionModel> sessions = [
    SessionModel(
      id: 's24',
      name: '2024-25',
      startDate: DateTime(2024, 10, 1),
      endDate: DateTime(2025, 9, 30),
      isActive: false,
    ),
    SessionModel(
      id: 's25',
      name: '2025-26',
      startDate: DateTime(2025, 10, 1),
      endDate: DateTime(2026, 9, 30),
      isActive: true,
    ),
  ];

  static final List<FarmerModel> farmers = [
    const FarmerModel(
      id: 'f1',
      name: 'Rajesh Kumar',
      village: 'Chourai',
      mobile: '9876500001',
      bankName: 'State Bank — Chourai',
      bankAccount: '12345678901',
      ifscCode: 'SBIN0001234',
    ),
    const FarmerModel(
      id: 'f2',
      name: 'Sunita Devi',
      village: 'Malwa',
      mobile: '9876500002',
      bankName: 'HDFC — Sehore',
      bankAccount: '998877665544',
      ifscCode: 'HDFC0009876',
    ),
    const FarmerModel(
      id: 'f3',
      name: 'Amit Singh',
      village: 'Pipariya',
      mobile: '9876500003',
      bankName: 'ICICI — Pipariya',
      bankAccount: null,
      ifscCode: null,
    ),
    const FarmerModel(
      id: 'f4',
      name: 'Vikram Rathore',
      village: 'Sehore',
      mobile: '9876500004',
      bankName: 'Axis — Sehore',
      bankAccount: '554433221100',
      ifscCode: 'UTIB0000456',
    ),
  ];

  /// Villages seen historically — drives Add Farmer autocomplete.
  static List<String> knownVillages() {
    final names = farmers.map((f) => f.village).toSet().toList()..sort();
    return names;
  }

  static final List<ProcurementModel> procurements = [
    ProcurementModel(
      id: 'p1',
      sessionId: activeSessionId,
      farmerId: 'f1',
      date: DateTime(2026, 4, 1, 9, 20),
      vehicleNumber: 'MP09AB1234',
      grossWeightQtl: 52.4,
      tareWeightQtl: 8.2,
      trashDeductionQtl: 0.5,
      netWeightQtl: 43.7,
      ratePerQtl: 320,
      totalAmount: 13984,
      amountPaid: 0,
      paymentStatus: PaymentStatus.pending,
      hasVehiclePhoto: true,
    ),
    ProcurementModel(
      id: 'p2',
      sessionId: activeSessionId,
      farmerId: 'f2',
      date: DateTime(2026, 4, 2, 11, 5),
      vehicleNumber: 'MP15CD8899',
      grossWeightQtl: 48.0,
      tareWeightQtl: 7.5,
      trashDeductionQtl: 0.4,
      netWeightQtl: 40.1,
      ratePerQtl: 320,
      totalAmount: 12832,
      amountPaid: 5000,
      paymentStatus: PaymentStatus.partial,
      hasVehiclePhoto: true,
    ),
    ProcurementModel(
      id: 'p3',
      sessionId: activeSessionId,
      farmerId: 'f3',
      date: DateTime(2026, 4, 3, 8, 40),
      vehicleNumber: 'MP22EF4455',
      grossWeightQtl: 61.0,
      tareWeightQtl: 9.0,
      trashDeductionQtl: 0.6,
      netWeightQtl: 51.4,
      ratePerQtl: 315,
      totalAmount: 16191,
      amountPaid: 16191,
      paymentStatus: PaymentStatus.paid,
      hasVehiclePhoto: false,
    ),
    ProcurementModel(
      id: 'p4',
      sessionId: activeSessionId,
      farmerId: 'f1',
      date: DateTime(2026, 4, 3, 15, 10),
      vehicleNumber: 'MP09AB9988',
      grossWeightQtl: 50.2,
      tareWeightQtl: 8.0,
      trashDeductionQtl: 0.3,
      netWeightQtl: 41.9,
      ratePerQtl: 320,
      totalAmount: 13408,
      amountPaid: 13408,
      paymentStatus: PaymentStatus.paid,
      hasVehiclePhoto: true,
    ),
    ProcurementModel(
      id: 'p5',
      sessionId: activeSessionId,
      farmerId: 'f4',
      date: DateTime(2026, 4, 4, 10, 0),
      vehicleNumber: 'MP10GH2211',
      grossWeightQtl: 44.5,
      tareWeightQtl: 7.0,
      trashDeductionQtl: 0.2,
      netWeightQtl: 37.3,
      ratePerQtl: 318,
      totalAmount: 11861.4,
      amountPaid: 0,
      paymentStatus: PaymentStatus.pending,
      hasVehiclePhoto: true,
    ),
  ];

  static final List<PaymentModel> manualPayments = [
    PaymentModel(
      id: 'm1',
      farmerId: 'f1',
      sessionId: activeSessionId,
      date: DateTime(2026, 4, 5),
      amount: 5000,
      note: 'Initial cash payment',
    ),
    PaymentModel(
      id: 'm2',
      farmerId: 'f2',
      sessionId: activeSessionId,
      date: DateTime(2026, 4, 6),
      amount: 2000,
      note: 'Bank transfer',
    ),
  ];

  static SessionModel? activeSession() {
    for (final s in sessions) {
      if (s.isActive) return s;
    }
    return sessions.isEmpty ? null : sessions.first;
  }

  static FarmerModel? farmerById(String id) {
    for (final f in farmers) {
      if (f.id == id) return f;
    }
    return null;
  }

  static List<ProcurementModel> procurementsForSession(String sessionId) {
    return procurements.where((p) => p.sessionId == sessionId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<ProcurementModel> procurementsForFarmer(String farmerId, {String? sessionId}) {
    final sid = sessionId ?? activeSessionId;
    return procurements.where((p) => p.farmerId == farmerId && p.sessionId == sid).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<PaymentModel> paymentsForFarmer(String farmerId, {String? sessionId}) {
    final sid = sessionId ?? activeSessionId;
    return manualPayments.where((p) => p.farmerId == farmerId && p.sessionId == sid).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static void addPayment(PaymentModel payment) {
    manualPayments.add(payment);
  }

  static void addProcurement(ProcurementModel procurement) {
    procurements.add(procurement);
  }

  static void updateProcurement(ProcurementModel procurement) {
    final index = procurements.indexWhere((p) => p.id == procurement.id);
    if (index != -1) {
      procurements[index] = procurement;
    }
  }

  static void deletePayment(String paymentId) {
    manualPayments.removeWhere((p) => p.id == paymentId);
  }

  /// Last N procurement rows for dashboard feed (active session).
  static List<ProcurementModel> recentProcurements({int n = 5}) {
    final list = procurementsForSession(activeSessionId);
    return list.take(n).toList();
  }

  static double totalNetWeightQtlForSession(String sessionId) {
    return procurementsForSession(sessionId).fold<double>(0, (s, p) => s + p.netWeightQtl);
  }

  static int uniqueFarmerCountForSession(String sessionId) {
    return procurementsForSession(sessionId).map((p) => p.farmerId).toSet().length;
  }

  static (double due, double paid) financialTotalsForSession(String sessionId) {
    final list = procurementsForSession(sessionId);
    final pList = manualPayments.where((p) => p.sessionId == sessionId);

    var totalDue = 0.0;
    var totalPaid = 0.0;

    for (final p in list) {
      totalDue += p.totalAmount;
      totalPaid += p.amountPaid;
    }

    for (final pm in pList) {
      totalPaid += pm.amount;
    }

    return (totalDue, totalPaid);
  }

  /// Demo 7-day intake (quintals) ending today — static preview for chart.
  static List<double> lastSevenDayIntakeQtl() {
    return [32, 41, 28, 55, 38, 44, 49];
  }
}
