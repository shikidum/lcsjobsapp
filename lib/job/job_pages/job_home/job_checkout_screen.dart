import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/utils/job_settings_controller.dart';

import '../../utils/job_subscription_controller.dart';

class JobCheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const JobCheckoutScreen({Key? key, required this.plan}) : super(key: key);

  @override
  State<JobCheckoutScreen> createState() => _JobCheckoutScreenState();
}

class _JobCheckoutScreenState extends State<JobCheckoutScreen> {
  final controller = Get.put(JobSubscriptionController());
  final settingcontroller = Get.put(JobSettingsController());

  final TextEditingController couponCtrl = TextEditingController();

  late double originalPrice;
  late int durationDays;

  @override
  void initState() {
    super.initState();
    originalPrice = double.tryParse(widget.plan['price'].toString()) ?? 0.0;
    durationDays = int.tryParse(widget.plan['duration'].toString().replaceAll(RegExp(r'[^0-9]'), ''),) ?? 30;
    // initialize payable with original price
    controller.resetCouponState(originalPrice);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: urbanistBold.copyWith(fontSize: 20),
        ),
        backgroundColor: JobColor.appcolor,
      ),
      body: Obx(() {
        final discount = controller.discountAmount.value;
        final payable = controller.payableAmount.value;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan details card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: JobColor.bggray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'] ?? '',
                      style: urbanistBold.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan['duration']} days',
                      style: urbanistSemiBold.copyWith(
                          fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan['description'] ?? '',
                      style: urbanistRegular.copyWith(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Coupon field
              Text(
                "Apply Coupon",
                style: urbanistSemiBold.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 8),
              // Row(
              //   children: [
              //     Expanded(
              //       child: TextField(
              //         controller: couponCtrl,
              //         decoration: InputDecoration(
              //           hintText: "Enter coupon code",
              //           border: OutlineInputBorder(
              //             borderRadius: BorderRadius.circular(10),
              //           ),
              //           contentPadding: const EdgeInsets.symmetric(
              //               horizontal: 12, vertical: 10),
              //         ),
              //         textCapitalization: TextCapitalization.characters,
              //       ),
              //     ),
              //     const SizedBox(width: 10),
              //     ElevatedButton(
              //       onPressed: () {
              //         controller.applyCoupon(
              //           couponCtrl.text.trim().toUpperCase(),
              //           originalPrice,
              //         );
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: JobColor.appcolor,
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 16, vertical: 12),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       ),
              //       child: Text(
              //         "Apply",
              //         style: urbanistSemiBold.copyWith(
              //             fontSize: 14, color: Colors.white),
              //       ),
              //     ),
              //   ],
              // ),
              Obx(() {
                final bool hasAppliedCoupon = controller.appliedCouponCode.value != null;

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: couponCtrl,
                        readOnly: hasAppliedCoupon, // 🔒 lock when applied
                        decoration: InputDecoration(
                          hintText: "Enter coupon code",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          suffixIcon: hasAppliedCoupon
                              ? const Icon(Icons.lock, size: 18)
                              : null,
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (hasAppliedCoupon) {
                          // REMOVE COUPON
                          controller.removeCoupon(originalPrice);
                          couponCtrl.clear(); // now user can type new one
                        } else {
                          // APPLY COUPON
                          controller.applyCoupon(
                            couponCtrl.text.trim().toUpperCase(),
                            originalPrice,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JobColor.appcolor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        hasAppliedCoupon ? "Remove" : "Apply", // 🔁 change label
                        style: urbanistSemiBold.copyWith(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 20),

              // Price summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JobColor.appcolor.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: JobColor.appcolor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _priceRow("Plan Price", "₹${originalPrice.toStringAsFixed(2)}"),
                    const SizedBox(height: 8),
                    _priceRow(
                      "Discount",
                      discount > 0
                          ? "- ₹${discount.toStringAsFixed(2)}"
                          : "₹0.00",
                    ),
                    const Divider(height: 24),
                    _priceRow(
                      "Total Payable",
                      "₹${payable.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final payable = controller.payableAmount.value;
            final isDisabled = payable <= 0;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 Terms & Conditions text
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      children: [
                        const TextSpan(
                          text: 'By clicking the button below, you agree to our ',
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: settingcontroller.openTerms,
                            child: Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                fontSize: 12,
                                color: JobColor.appcolor,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),

                // 🔹 Pay button
                SizedBox(
                  width: double.infinity, // 🔥 full screen width
                  child: ElevatedButton(
                    onPressed: isDisabled
                        ? null
                        : () {
                      controller.openCheckout(
                        planId: widget.plan['id'].toString(),
                        planName: widget.plan['name']?.toString() ?? '',
                        amount: payable,
                        durationDays: durationDays,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isDisabled ? Colors.grey : JobColor.appcolor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pay ₹${payable.toStringAsFixed(2)}',
                      style: urbanistBold.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: (isBold ? urbanistBold : urbanistRegular).copyWith(
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: (isBold ? urbanistBold : urbanistRegular).copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
