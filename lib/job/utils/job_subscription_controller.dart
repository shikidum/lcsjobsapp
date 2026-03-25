import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_dashboard.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../job_pages/job_authentication/job_loginoption.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class JobSubscriptionController extends GetxController {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
 // final storage = GetStorage(); // 🔐 local storage
  final subscriptionExpiry = Rx<DateTime?>(null);
  final isSubscriptionValid = false.obs;
  final storage = GetStorage();

  final String candidateId = GetStorage().read("candidate_id");
  // var plans = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> plans = <Map<String, dynamic>>[].obs;
  Rxn<Map<String, dynamic>> currentPlan = Rxn<Map<String, dynamic>>();

  RxDouble discountAmount = 0.0.obs;
  RxDouble payableAmount = 0.0.obs;
  RxnString appliedCouponCode = RxnString();

  // store pending payment data for success handler
  String? _pendingPlanId;
  int? _pendingDurationDays;
  double? _pendingAmount;

  late Razorpay _razorpay;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> fetchPlans() async {
    final snapshot = await database.child('subscriptions').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      plans.value = data.entries.map<Map<String, dynamic>>((e) {
        final value = Map<String, dynamic>.from(e.value);
        value['id'] = e.key;
        return value;
      }).toList();
    } else {
      plans.clear();
    }
  }

  Future<void> fetchCurrentPlan() async {
    try {
      final candidateId = storage.read('candidate_id');

      if (candidateId == null) {
        currentPlan.value = null;
        return;
      }

      final candidateRef = database.child('candidate/$candidateId');
      final snapshot = await candidateRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        currentPlan.value = null;
        return;
      }

      final serverData = Map<String, dynamic>.from(snapshot.value as Map);
      final subscription = serverData['subscription'];

      // No subscription saved
      if (subscription == null || subscription is! Map) {
        currentPlan.value = null;
        return;
      }

      // Subscription present
      final subMap = Map<String, dynamic>.from(subscription as Map);
      final planId = subMap['plan_id']?.toString() ?? '';
      final startDateStr = subMap['start_date']?.toString() ?? '';
      final endDateStr = subMap['end_date']?.toString() ?? '';

      if (planId.isEmpty) {
        currentPlan.value = null;
        return;
      }

      // Try to find plan details from plans list (for name / price etc.)
      Map<String, dynamic>? matchedPlan;
      for (final p in plans) {
        if (p['id']?.toString() == planId) {
          matchedPlan = p;
          break;
        }
      }

      final planName = matchedPlan?['name']?.toString() ?? 'Current Plan';

      // (Optional) try to detect expiry – if it fails, we just ignore and show it
      bool isExpired = false;
      if (endDateStr.isNotEmpty) {
        try {
          // Adjust this format to whatever you’re saving in DB
          final endDate = DateTime.parse(endDateStr); // e.g. "2025-12-31"
          if (endDate.isBefore(DateTime.now())) {
            isExpired = true;
          }
        } catch (_) {
          // ignore parse errors, treat as not expired
        }
      }

      if (isExpired) {
        // If you don’t want to show expired subscription as current
        currentPlan.value = null;
        return;
      }

      // This map is what the screen uses
      currentPlan.value = {
        'plan_id': planId,
        'name': planName,
        'start_date': startDateStr,
        'expires_at': endDateStr,
      };
    } catch (e) {
      // On any error, treat as no current subscription
      currentPlan.value = null;
      debugPrint('fetchCurrentPlan error: $e');
    }
  }

  // Future<void> buyPlan(String planId, int duration) async {
  //   final now = DateTime.now();
  //   final endDate = now.add(Duration(days: duration));
  //
  //   await database.child("candidate").child(candidateId).child("subscription").set({
  //     'plan_id': planId,
  //     'start_date': now.toIso8601String(),
  //     'end_date': endDate.toIso8601String(),
  //   });
  //   // Optionally save locally
  //   final storage = GetStorage();
  //   storage.write("plan_end_date", endDate.toIso8601String());
  //   storage.write("subscription_status", "active");
  //   Get.snackbar("Subscribed", "Subscription successful!");
  //   Get.back();
  // }

  bool isUserSubscribed() {
    final storage = GetStorage();
    final endDateString = storage.read("plan_end_date");
    if (endDateString == null) return false;

    final endDate = DateTime.tryParse(endDateString);
    if (endDate == null) return false;

    return endDate.isAfter(DateTime.now());
  }


// ---------- COUPON LOGIC ----------

  void resetCouponState(double originalAmount) {
    discountAmount.value = 0.0;
    appliedCouponCode.value = null;
    payableAmount.value = originalAmount;
  }

  Future<void> applyCoupon(String code, double originalAmount) async {
    if (code.isEmpty) {
      Get.snackbar("Coupon", "Please enter coupon code");
      return;
    }

    try {
      final upperCode = code.toUpperCase();
      final couponRef = database.child("coupons").child(upperCode);
      final snapshot = await couponRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        Get.snackbar("Invalid", "Coupon does not exist");
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      if (data['is_active'] != true) {
        Get.snackbar("Invalid", "Coupon is not active");
        return;
      }

      final discountType = data['discount_type']?.toString() ?? 'flat'; // flat / percent
      final discountValue = (data['discount_value'] ?? 0).toDouble();
      final maxDiscount = (data['max_discount'] ?? double.infinity).toDouble();
      final minAmount = (data['min_amount'] ?? 0).toDouble();

      // we’re using usage_limit as "per user" limit
      final int perUserLimit = (data['usage_limit'] ?? 0) as int;
      // you defined this but not using it – that's fine:
      final int globalUsedCount = (data['used_count'] ?? 0) as int;

      // amount check
      if (originalAmount < minAmount) {
        Get.snackbar(
          "Not applicable",
          "Minimum order amount ₹$minAmount required for this coupon.",
        );
        return;
      }

      // ========== PER USER LIMIT CHECK ==========
      if (perUserLimit > 0) {
        final candidateId = storage.read('candidate_id')?.toString() ?? '';
        if (candidateId.isNotEmpty) {
          final reportRef = database.child("Coupon Report");
          final reportSnap = await reportRef
              .orderByChild("candidate_id")
              .equalTo(candidateId)
              .get();

          int usedByThisUser = 0;

          if (reportSnap.exists && reportSnap.value != null) {
            final value = reportSnap.value;

            // In Realtime DB queries usually return a Map of pushKeys
            if (value is Map) {
              final map = Map<dynamic, dynamic>.from(value);
              map.forEach((key, v) {
                if (v == null) return;
                final row = Map<String, dynamic>.from(v as Map);
                if ((row['coupon_code']?.toString().toUpperCase() ?? '') ==
                    upperCode) {
                  usedByThisUser++;
                }
              });
            }
            // In some shapes it could be a List – be defensive
            else if (value is List) {
              for (final v in value) {
                if (v == null) continue;
                final row = Map<String, dynamic>.from(v as Map);
                if ((row['coupon_code']?.toString().toUpperCase() ?? '') ==
                    upperCode) {
                  usedByThisUser++;
                }
              }
            }
          }

          if (usedByThisUser >= perUserLimit) {
            Get.snackbar(
              "Limit reached",
              "You have already used this coupon $perUserLimit time(s).",
            );
            return;
          }
        }
      }
      // ========== END PER USER LIMIT CHECK ==========

      // date validity check (valid_from / valid_to in "YYYY-MM-DD")
      final today = DateTime.now();
      DateTime? validFrom;
      DateTime? validTo;

      if (data['valid_from'] != null &&
          data['valid_from'].toString().isNotEmpty) {
        validFrom = DateTime.parse(data['valid_from']); // 2025-11-24
      }
      if (data['valid_to'] != null && data['valid_to'].toString().isNotEmpty) {
        validTo = DateTime.parse(data['valid_to']);
      }

      if (validFrom != null && today.isBefore(validFrom)) {
        Get.snackbar("Not started", "Coupon not valid yet.");
        return;
      }
      if (validTo != null) {
        final endOfValidTo = validTo.add(const Duration(days: 1));
        if (today.isAfter(endOfValidTo)) {
          Get.snackbar("Expired", "Coupon has expired.");
          return;
        }
      }

      // calculate discount
      double discount = 0.0;
      if (discountType == 'percent') {
        discount = originalAmount * (discountValue / 100);
      } else {
        // flat
        discount = discountValue;
      }

      // cap with max_discount
      if (discount > maxDiscount) {
        discount = maxDiscount;
      }

      double payable = originalAmount - discount;
      if (payable < 0) payable = 0;

      discountAmount.value = discount;
      payableAmount.value = payable;
      appliedCouponCode.value = upperCode;

      Get.snackbar(
        "Coupon Applied",
        "You saved ₹${discount.toStringAsFixed(2)}. Payable: ₹${payable.toStringAsFixed(2)}",
      );
    } catch (e) {
      Get.snackbar("Error", "Failed to apply coupon");
      debugPrint("applyCoupon error: $e");
    }
  }

  void removeCoupon(double originalAmount) {
    resetCouponState(originalAmount);
  }
  // ---------- RAZORPAY CHECKOUT ----------



  void openCheckout({
    required String planId,
    required String planName,
    required double amount, // final payable amount
    required int durationDays,
  })
  {
    _pendingPlanId = planId;
    _pendingDurationDays = durationDays;
    _pendingAmount = amount;

    final candidateId = storage.read('candidate_id') ?? "";
    final razorpaykey=storage.read('razorpay_key')??"";
    print("razorpaykey is "+razorpaykey);
    // Razorpay expects amount in paise (₹100 => 10000)
    final int amountInPaise = (amount * 100).round();

    var options = {
      'key': razorpaykey,
      'amount': amountInPaise,
      'name': 'LCS Jobs',
      'description': 'Subscription - $planName',
      // 'order_id': 'order_DBJOWzybf0sJbb', // Ideally from your server
      'prefill': {
        'contact': storage.read('phone') ?? '',
        'email': storage.read('candidate_email') ?? '',
      },
      'notes': {
        'candidate_id': candidateId,
        'plan_id': planId,
      },
      'theme': {
        'color': '#0A7AFF',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      Get.snackbar("Payment Error", "Unable to start payment");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // 0. Basic shared data
      final candidateId = storage.read('candidate_id')?.toString() ?? '';
      String candidateName = '';
      String candidateMobile = '';

      // Fetch candidate details (name, mobile, etc.) ONCE
      try {
        if (candidateId.isNotEmpty) {
          final candidateSnap =
          await database.child("candidate").child(candidateId).get();
          if (candidateSnap.exists && candidateSnap.value != null) {
            final cData = Map<String, dynamic>.from(candidateSnap.value as Map);
            candidateName = cData['name']?.toString() ?? '';
            candidateMobile =
                cData['mobile']?.toString() ?? cData['phone']?.toString() ?? '';
          }
        }
      } catch (_) {
        // ignore error, leave name/mobile empty if something goes wrong
      }

      // Amount actually paid (after discount)
      final double paidAmount = _pendingAmount ?? payableAmount.value;
      final String? couponCode = appliedCouponCode.value;
      final String planId = _pendingPlanId ?? '';
      final int planDays = _pendingDurationDays ?? 0;
      final nowIso = DateTime.now().toIso8601String();

      // 1. Activate plan
      if (_pendingPlanId != null && _pendingDurationDays != null) {
        await buyPlan(_pendingPlanId!, _pendingDurationDays!);
      }

      // 2. If coupon used, increment used_count and create COUPON REPORT entry
      if (couponCode != null) {
        final couponRef = database.child("coupons").child(couponCode);
        final couponSnap = await couponRef.get();

        if (couponSnap.exists && couponSnap.value != null) {
          final data = Map<String, dynamic>.from(couponSnap.value as Map);
          final usedCount = (data['used_count'] ?? 0) as int;
          await couponRef.update({'used_count': usedCount + 1});
        }

        // ---- COUPON REPORT ENTRY ----
        final reportRef = database.child("Coupon Report").push();
        await reportRef.set({
          'coupon_code': couponCode,
          'candidate_id': candidateId,
          'candidate_name': candidateName,
          'candidate_mobile': candidateMobile,
          'plan_id': planId,
          'plan_duration_days': planDays,
          'amount_paid': paidAmount,
          'redeemed_at': nowIso,
          'payment_id': response.paymentId ?? '',
          'razorpay_order_id': response.orderId ?? '',
          'razorpay_signature': response.signature ?? '',
        });
      }

      // 3. TRANSACTION ENTRY (always created, coupon or not)
      final double discountUsed =
      couponCode != null ? discountAmount.value : 0.0;
      final double originalAmount = paidAmount + discountUsed;
      final transactionNo = await _getNextTransactionNumber();
// Generate transaction reference FIRST
      final txRef = database.child("transactions").push();
      final String transactionId = txRef.key ?? '';

      await txRef.set({
        'transaction_no': transactionNo,
        'candidate_id': candidateId,
        'candidate_name': candidateName,
        'candidate_mobile': candidateMobile,
        'plan_id': planId,
        'plan_duration_days': planDays,
        'coupon_code': couponCode ?? '',
        'discount_amount': discountUsed,
        'original_amount': originalAmount,
        'amount_paid': paidAmount,
        'currency': 'INR',
        'payment_id': response.paymentId ?? '',
        'razorpay_order_id': response.orderId ?? '',
        'razorpay_signature': response.signature ?? '',
        'status': 'success',
        'gateway': 'razorpay',
        'created_at': nowIso,
      });

// ✅ CALL INVOICE GENERATION AFTER SUCCESSFUL TRANSACTION SAVE
      if (transactionId.isNotEmpty && candidateId.isNotEmpty) {
        await createinvoice(
          transactionid: transactionId,
          useruid: candidateId,
        );
      }

      Get.snackbar("Payment Success", "Payment id: ${response.paymentId}");
      // 🔙 go back to the screen from where user originally came
      // closes: JobCheckoutScreen + JobSubscriptionScreen
      Get.close(2);
    } catch (e) {
      debugPrint("handlePaymentSuccess error: $e");
      Get.snackbar("Payment", "Payment succeeded but logging failed.");
    }
  }

  Future<int> _getNextTransactionNumber() async {
    // Determine financial year (April to March)
    final now = DateTime.now();
    final int financialYear;

    if (now.month >= 4) {
      // April to December: Current year
      financialYear = now.year;
    } else {
      // January to March: Previous year
      financialYear = now.year - 1;
    }

    // Counter key based on financial year
    final counterRef = database.child("counters/transaction_counter_$financialYear");

    // Use transaction to ensure atomicity
    final transactionResult = await counterRef.runTransaction((currentValue) {
      int currentCount = 0;

      if (currentValue != null && currentValue is int) {
        currentCount = currentValue;
      } else if (currentValue != null && currentValue is Map) {
        currentCount = currentValue['count'] ?? 0;
      }

      return Transaction.success(currentCount + 1);
    });

    if (transactionResult.committed && transactionResult.snapshot.value != null) {
      final newCount = transactionResult.snapshot.value as int;
      return newCount;  // Just return the number
    }

    throw Exception('Failed to generate transaction number');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar("Payment Failed", response.message ?? "Something went wrong");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar("External Wallet", response.walletName ?? "");
  }

  // ---------- YOUR EXISTING buyPlan (used after successful payment) ----------

  Future<void> buyPlan(String planId, int duration) async {
    final candidateId = storage.read('candidate_id');
    final now = DateTime.now();
    final endDate = now.add(Duration(days: duration));

    await database
        .child("candidate")
        .child(candidateId)
        .child("subscription")
        .set({
      'plan_id': planId,
      'start_date': now.toIso8601String(),
      'end_date': endDate.toIso8601String(),
    });

    storage.write("plan_end_date", endDate.toIso8601String());
    storage.write("subscription_status", "active");

    // refresh currentPlan for UI
    await fetchCurrentPlan();

    Get.snackbar("Subscribed", "Subscription successful!");
    // Don't Get.back() here automatically if you already popped after payment
  }

  Future<bool> createinvoice({
  required String transactionid,
  required String useruid,
  BuildContext? context,
  }) async {
  final url = Uri.parse("https://panel.laxmiconsultancyservices.com/generate-invoice.php");

  try {
  print("🔄 Generating invoice...");
  print("Transaction ID: $transactionid");
  print("User UID: $useruid");

  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: jsonEncode({
  "user_uid": useruid,
  "transaction_id": transactionid,
  }),
  );

  print("📡 Status Code: ${response.statusCode}");
  print("📄 Response Body: ${response.body}");

  if (response.statusCode == 200) {
  try {
  final Map<String, dynamic> data = jsonDecode(response.body);

  if (data['status'] == true) {
  print("✅ Invoice generated successfully!");
  print("Invoice No: ${data['invoice_no']}");
  print("Database updated with invoice URL");

  if (context != null) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Invoice generated successfully!'),
  backgroundColor: Colors.green,
  ),
  );
  }

  return true;
  } else {
  print("❌ API Error: ${data['message']}");

  if (context != null) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Error: ${data['message']}'),
  backgroundColor: Colors.red,
  ),
  );
  }

  return false;
  }
  } catch (e) {
  print("❌ JSON Parse Error: $e");
  print("Raw Response: ${response.body}");

  if (context != null) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Invalid server response'),
  backgroundColor: Colors.red,
  ),
  );
  }

  return false;
  }
  } else {
  print("❌ HTTP Error: ${response.statusCode}");
  print("Response: ${response.body}");

  if (context != null) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Server error: ${response.statusCode}'),
  backgroundColor: Colors.red,
  ),
  );
  }

  return false;
  }

  } catch (e) {
  print("❌ Network Exception: $e");

  if (context != null) {
  ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
  content: Text('Network error: $e'),
  backgroundColor: Colors.red,
  ),
  );
  }

  return false;
  }
  }

}