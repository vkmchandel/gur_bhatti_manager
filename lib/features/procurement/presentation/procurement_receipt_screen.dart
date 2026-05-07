import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../data/demo_catalog.dart';
import '../../../data/procurement_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'add_procurement_screen.dart';

class ProcurementReceiptScreen extends StatelessWidget {
  final String procurementId;

  const ProcurementReceiptScreen({
    super.key,
    required this.procurementId,
  });

  @override
  Widget build(BuildContext context) {
    final procurement = DemoCatalog.procurements.firstWhere((p) => p.id == procurementId);
    final farmer = DemoCatalog.farmerById(procurement.farmerId);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(l10n.appTitle.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddProcurementScreen(editProcurementId: procurementId),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sharing receipt PDF...")),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.intakeReceipt.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Chourai, Madhya Pradesh",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoColumn(l10n.date, DateFormat('dd MMM yyyy, hh:mm a').format(procurement.date)),
                          _buildInfoColumn(l10n.receiptNo, (procurement.id.length > 8 ? procurement.id.substring(0, 8) : procurement.id).toUpperCase()),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildInfoRow("FARMER", farmer?.name ?? l10n.unknownFarmer, isBold: true),
                      _buildInfoRow("VILLAGE", farmer?.village ?? "-"),
                      _buildInfoRow("VEHICLE", procurement.vehicleNumber),
                      const Divider(height: 32),
                      
                      _buildWeightRow(l10n.gross, procurement.grossWeightQtl),
                      _buildWeightRow(l10n.tare, procurement.tareWeightQtl),
                      _buildWeightRow(l10n.trash.toUpperCase(), procurement.trashDeductionQtl, isNegative: true),
                      const SizedBox(height: 8),
                      _buildWeightRow(l10n.netWeight, procurement.netWeightQtl, isBold: true, fontSize: 16),
                      const Divider(height: 24),
                      _buildCurrencyRow(l10n.ratePerQtl, procurement.ratePerQtl),
                      const SizedBox(height: 8),
                      _buildCurrencyRow(l10n.totalAmount.toUpperCase(), procurement.totalAmount, isBold: true, fontSize: 16),
                      const Divider(height: 32),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              height: 1,
                              width: 150,
                              color: Colors.black26,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.authorizedSignatory.toUpperCase(),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          l10n.thankYouBusiness,
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sharing receipt PDF...")),
            );
          },
          icon: const Icon(Icons.share_outlined),
          label: Text(l10n.shareReceipt.toUpperCase()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildWeightRow(String label, double value, {bool isNegative = false, bool isBold = false, double fontSize = 14}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF1E293B),
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            "${isNegative ? '-' : ''}${value.toStringAsFixed(2)} Qtl",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isNegative ? Colors.red : const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String label, double value, {bool isBold = false, double fontSize = 14, Color color = const Color(0xFF1E293B)}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: value % 1 == 0 ? 0 : 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
            ),
          ),
          Text(
            formatter.format(value),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
