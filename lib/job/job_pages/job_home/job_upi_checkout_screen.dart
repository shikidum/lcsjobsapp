import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/job_subscription_controller.dart';

/// Pass the plan the candidate picked from the plans list screen.
class JobUpiCheckoutScreen extends StatefulWidget {
  final String planId;
  final String planName;
  final int durationDays;
  final double originalAmount;
  final double payableAmount; // after any coupon applied on the previous screen

  const JobUpiCheckoutScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.durationDays,
    required this.originalAmount,
    required this.payableAmount,
  });

  @override
  State<JobUpiCheckoutScreen> createState() => _JobUpiCheckoutScreenState();
}

class _JobUpiCheckoutScreenState extends State<JobUpiCheckoutScreen> {
  final controller = Get.find<JobSubscriptionController>();
  final utrController = TextEditingController();
  File? screenshotFile;

  @override
  void initState() {
    super.initState();
    controller.fetchActiveUpiAccount();
    controller.fetchMyPendingTransaction();
  }

  Future<void> _pickScreenshot() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() => screenshotFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final upi = controller.activeUpiAccount.value;
    if (upi == null) {
      Get.snackbar("Error", "No active UPI account found");
      return;
    }

    final success = await controller.submitManualPayment(
      planId: widget.planId,
      planName: widget.planName,
      durationDays: widget.durationDays,
      originalAmount: widget.originalAmount,
      amountPaid: widget.payableAmount,
      utrNumber: utrController.text,
      upiIdUsed: upi['upi_id'] ?? '',
      screenshotFile: screenshotFile,
    );

    if (success && mounted) {
      // Stay on screen — it will now show the pending status via Obx below.
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Payment")),
      body: Obx(() {
        final pending = controller.pendingTransaction.value;

        // If there's already a transaction awaiting/decided, show status instead of the pay form.
        if (pending != null) {
          return _buildStatusView(pending);
        }

        final upi = controller.activeUpiAccount.value;
        if (upi == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(widget.planName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("₹${widget.payableAmount.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Scan & Pay", style: TextStyle(fontWeight: FontWeight.bold)),
                      if ((upi['account_name'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(upi['account_name'], style: const TextStyle(color: Colors.grey)),
                      ],
                      if ((upi['qr_url'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: Image.network(upi['qr_url'], height: 220),
                        ),
                      ],
                      const SizedBox(height: 16),
                      const Text("Or pay to this UPI ID", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                upi['upi_id'] ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: upi['upi_id'] ?? ''));
                                Get.snackbar("Copied", "UPI ID copied to clipboard");
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("After paying, submit your payment proof",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: utrController,
                        decoration: const InputDecoration(
                          labelText: "UPI Transaction / UTR Number *",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _pickScreenshot,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(screenshotFile == null
                            ? "Attach Screenshot (optional)"
                            : "Screenshot Attached ✓"),
                      ),
                      const SizedBox(height: 16),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isSubmittingPayment.value ? null : _submit,
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                        child: controller.isSubmittingPayment.value
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text("Submit for Verification"),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusView(Map<String, dynamic> txn) {
    final status = txn['status']?.toString() ?? 'pending';

    IconData icon;
    Color color;
    String title;
    String subtitle;

    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        title = "Payment Approved";
        subtitle = "Your subscription is now active.";
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        title = "Payment Rejected";
        subtitle = (txn['rejection_reason']?.toString().isNotEmpty ?? false)
            ? txn['rejection_reason']
            : "We couldn't verify this payment. Please contact support or try again.";
        break;
      default:
        icon = Icons.hourglass_top;
        color = Colors.orange;
        title = "Payment Under Review";
        subtitle = "We've received your payment details (UTR: ${txn['utr_number'] ?? ''}). "
            "Your plan will be activated once verified — usually within a few hours.";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (status == 'rejected')
              ElevatedButton(
                onPressed: () {
                  controller.pendingTransaction.value = null;
                },
                child: const Text("Try Again"),
              ),
          ],
        ),
      ),
    );
  }
}