import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcsjobs/job/utils/job_transaction_controller.dart';
import 'package:lcsjobs/job/utils/pdfdownloader.dart';

class JobTransactionScreen extends StatefulWidget {
  const JobTransactionScreen({Key? key}) : super(key: key);

  @override
  State<JobTransactionScreen> createState() =>
      _JobTransactionScreenState();
}

class _JobTransactionScreenState extends State<JobTransactionScreen> {
  final controller = Get.put(JobTransactionController());
  final storage = GetStorage();
  final PdfDownloader _pdfDownloader = PdfDownloader();

  @override
  void initState() {
    super.initState();
    // Replace with your actual user UID
    controller.fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.transactions.isEmpty) {
          return const Center(
            child: Text("No transactions found"),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.transactions.length,
          itemBuilder: (context, index) {
            final txn = controller.transactions[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn['plan_name'] ?? "Subscription",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text("Amount: ₹${txn['amount']}"),
                    Text("Date: ${txn['created_at']}"),
                    Text("Status: ${txn['status']}"),
                    const SizedBox(height: 12),

                    if (txn['invoice_url'] != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          _pdfDownloader.openInvoice(
                            txn['invoice_url'],
                            context,
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text("Download Invoice"),
                      )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
