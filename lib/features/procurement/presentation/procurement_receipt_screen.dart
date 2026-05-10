import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/demo_catalog.dart';
import '../../../data/procurement_model.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_provider.dart';
import 'add_procurement_screen.dart';

class ProcurementReceiptScreen extends StatefulWidget {
  final String procurementId;

  const ProcurementReceiptScreen({
    super.key,
    required this.procurementId,
  });

  @override
  State<ProcurementReceiptScreen> createState() => _ProcurementReceiptScreenState();
}

class _ProcurementReceiptScreenState extends State<ProcurementReceiptScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  Future<void> _shareReceiptImage(AppLocalizations l10n, {bool whatsappOnly = false}) async {
    try {
      // Capture with a bit of extra delay to ensure rendering is complete
      final image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );
      if (image == null) return;

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/receipt_${widget.procurementId}.png').create();
      await imagePath.writeAsBytes(image);

      if (whatsappOnly) {
        // share_plus doesn't support "WhatsApp only" directly easily on all platforms without specific packages,
        // but we can provide a targeted share text.
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: l10n.appTitle,
        );
      } else {
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Receipt from ${l10n.appTitle}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error sharing receipt: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final procurement = DemoCatalog.procurements.firstWhere((p) => p.id == widget.procurementId);
    final farmer = DemoCatalog.farmerById(procurement.farmerId);
    final l10n = AppLocalizations.of(context)!;
    final bhatti = context.read<AuthProvider>().bhatti;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(l10n.intakeReceipt.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
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
                  builder: (context) => AddProcurementScreen(editProcurementId: widget.procurementId),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        // Removed SingleChildScrollView to try and keep it non-scrollable as requested
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header with Logo and Bhatti Name
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF365E32),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Image.asset('assets/images/bhatti_logo.png', height: 40, width: 40),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        (bhatti?.bhattiName ?? l10n.appTitle).toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        "${bhatti?.village ?? 'Chourai'}, ${bhatti?.district ?? 'MP'}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildInfoColumn(l10n.date, DateFormat('dd MMM yyyy').format(procurement.date)),
                                    _buildInfoColumn(l10n.receiptNo, (widget.procurementId.length > 8 ? widget.procurementId.substring(0, 8) : widget.procurementId).toUpperCase()),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow("FARMER", farmer?.name ?? l10n.unknownFarmer, isBold: true),
                                _buildInfoRow("VILLAGE", farmer?.village ?? "-"),
                                _buildInfoRow("VEHICLE", procurement.vehicleNumber),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),
                                
                                _buildWeightRow(l10n.gross, procurement.grossWeightQtl),
                                _buildWeightRow(l10n.tare, procurement.tareWeightQtl),
                                _buildWeightRow(l10n.trash, procurement.trashDeductionQtl, isNegative: true),
                                const SizedBox(height: 6),
                                _buildWeightRow(l10n.netWeight, procurement.netWeightQtl, isBold: true, fontSize: 16),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                                ),
                                _buildCurrencyRow(l10n.ratePerQtl, procurement.ratePerQtl),
                                _buildCurrencyRow(l10n.totalAmount.toUpperCase(), procurement.totalAmount, isBold: true, fontSize: 16, color: const Color(0xFF365E32)),
                                
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Container(height: 1, width: 120, color: Colors.black12),
                                        const SizedBox(height: 4),
                                        Text(l10n.authorizedSignatory.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black38)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Zig-zag edge simulation
                          Row(
                            children: List.generate(20, (index) => Expanded(
                              child: Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: index.isEven ? const BorderRadius.vertical(bottom: Radius.circular(5)) : null,
                                ),
                              ),
                            )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () => _shareReceiptImage(l10n, whatsappOnly: true),
                icon: const Icon(Icons.share, size: 20),
                label: const Text("SHARE ON WHATSAPP", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _shareReceiptImage(l10n),
                icon: const Icon(Icons.more_horiz),
                label: const Text("OTHER OPTIONS"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: const Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightRow(String label, double value, {bool isNegative = false, bool isBold = false, double fontSize = 13}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: const Color(0xFF1E293B), fontWeight: isBold ? FontWeight.w900 : FontWeight.w500)),
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

  Widget _buildCurrencyRow(String label, double value, {bool isBold = false, double fontSize = 13, Color color = const Color(0xFF1E293B)}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: value % 1 == 0 ? 0 : 2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, color: color, fontWeight: isBold ? FontWeight.w900 : FontWeight.w500)),
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
