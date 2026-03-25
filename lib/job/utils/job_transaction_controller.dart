import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';

class JobTransactionController extends GetxController {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final storage = GetStorage();

  RxList<Map<String, dynamic>> transactions =
      <Map<String, dynamic>>[].obs;

  RxBool isLoading = false.obs;

  String get candidateId =>
      storage.read("candidate_id")?.toString() ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    final String candidateId = GetStorage().read("candidate_id");
    try {
      isLoading.value = true;
      if (candidateId.isEmpty) {
        transactions.clear();
        return;
      }

      // Fetch all transactions
      final txnSnapshot = await database.child('transactions').get();

      if (!txnSnapshot.exists || txnSnapshot.value == null) {
        transactions.clear();
        return;
      }

      final txnData =Map<String, dynamic>.from(txnSnapshot.value as Map);

      // Fetch plans (to map plan name)
      final plansSnapshot =await database.child('subscriptions').get();

      Map<String, dynamic> plansMap = {};
      if (plansSnapshot.exists && plansSnapshot.value != null) {
        plansMap =
        Map<String, dynamic>.from(plansSnapshot.value as Map);
      }

      List<Map<String, dynamic>> result = [];

      txnData.forEach((txnId, value) {
        if (value == null) return;

        final txn = Map<String, dynamic>.from(value);

        if (txn['candidate_id'] != candidateId) return;

        // Attach plan name
        String planName = "Subscription";
        final planId = txn['plan_id'];

        if (planId != null &&
            plansMap.containsKey(planId)) {
          final plan =
          Map<String, dynamic>.from(plansMap[planId]);
          planName = plan['name'] ?? "Subscription";
        }

        result.add({
          'id': txnId,
          'plan_id': txn['plan_id'],
          'plan_name': planName,
          'amount': txn['amount_paid'] ?? txn['amount'] ?? 0,
          'status': txn['status'] ?? '',
          'created_at': txn['created_at'] ?? '',
          'invoice_url': txn['invoice_url'],
        });
      });

      // Sort by latest first
      result.sort((a, b) =>
          b['created_at'].toString().compareTo(a['created_at'].toString()));

      transactions.value = result;
    } catch (e) {
      print("Transaction fetch error: $e");
      transactions.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
