import '../core/domain/payment_status.dart';

class ProcurementModel {
  const ProcurementModel({
    required this.id,
    required this.sessionId,
    required this.farmerId,
    required this.date,
    required this.vehicleNumber,
    required this.grossWeightQtl,
    required this.tareWeightQtl,
    required this.trashDeductionQtl,
    required this.netWeightQtl,
    required this.ratePerQtl,
    required this.totalAmount,
    required this.amountPaid,
    required this.paymentStatus,
    required this.hasVehiclePhoto,
  });

  final String id;
  final String sessionId;
  final String farmerId;
  final DateTime date;
  final String vehicleNumber;
  final double grossWeightQtl;
  final double tareWeightQtl;
  final double trashDeductionQtl;
  final double netWeightQtl;
  final double ratePerQtl;
  final double totalAmount;
  final double amountPaid;
  final PaymentStatus paymentStatus;
  final bool hasVehiclePhoto;
}
