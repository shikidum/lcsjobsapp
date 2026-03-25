import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_checkout_screen.dart';

import '../../utils/job_subscription_controller.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_dashboard.dart';



class JobSubscriptionScreen extends StatefulWidget {
  const JobSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<JobSubscriptionScreen> createState() => _JobSubscriptionScreenState();
}

class _JobSubscriptionScreenState extends State<JobSubscriptionScreen> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final controller = Get.put(JobSubscriptionController());
  String? selectedPlanId;

  @override
  void initState() {
    super.initState();
    controller.fetchPlans();
    controller.fetchCurrentPlan(); // ⬅️ NEW: load current subscription
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Plan', style: urbanistBold.copyWith(fontSize: 20)),
        backgroundColor: JobColor.appcolor,
      ),
      body: Obx(() {
        if (controller.plans.isEmpty) {
          return Center(
            child: Text('No plans available.', style: urbanistRegular),
          );
        }

        final currentPlan = controller.currentPlan.value;

        return Column(
          children: [
            // ---------- CURRENT SUBSCRIPTION CARD ----------
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: JobColor.appcolor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: JobColor.appcolor.withOpacity(0.2)),
                ),
                child: currentPlan == null
                    ? Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No active subscription',
                        style: urbanistSemiBold.copyWith(fontSize: 14),
                      ),
                    ),
                  ],
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Subscription',
                      style: urbanistBold.copyWith(
                        fontSize: 16,
                        color: JobColor.appcolor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentPlan['name'] ?? 'Unknown plan',
                      style: urbanistSemiBold.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    if (currentPlan['expires_at'] != null)
                      Text(
                        'Valid till: ${currentPlan['expires_at']}',
                        style: urbanistRegular.copyWith(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // ---------- PLAN LIST ----------
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.plans.length,
                itemBuilder: (context, index) {
                  final plan = controller.plans[index];

                  if (plan['is_active'] == false) return const SizedBox();

                  // Check if this plan is the current one
                  final bool isCurrentPlan =
                      currentPlan != null && currentPlan['plan_id'] == plan['id'];

                  return GestureDetector(
                    onTap: isCurrentPlan
                        ? null // disable if it's current plan
                        : () {
                      setState(() {
                        selectedPlanId = plan['id'];
                      });
                    },
                    child: Opacity(
                      // visually dim current plan
                      opacity: isCurrentPlan ? 0.5 : 1,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selectedPlanId == plan['id']
                              ? JobColor.appcolor.withOpacity(0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedPlanId == plan['id']
                                ? JobColor.appcolor
                                : JobColor.bggray,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: plan['id'],
                                  groupValue: selectedPlanId,
                                  onChanged: isCurrentPlan
                                      ? null // disable selection
                                      : (value) {
                                    setState(() {
                                      selectedPlanId = value;
                                    });
                                  },
                                  activeColor: JobColor.appcolor,
                                ),
                                Expanded(
                                  child: Text(
                                    plan['name'] ?? '',
                                    style: urbanistBold.copyWith(fontSize: 18),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '₹${plan['price']}',
                                  style: urbanistBold.copyWith(
                                    fontSize: 16,
                                    color: JobColor.appcolor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${plan['duration']} days',
                                  style: urbanistSemiBold.copyWith(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Spacer(),
                                if (isCurrentPlan)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: JobColor.appcolor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Current Plan',
                                      style: urbanistSemiBold.copyWith(
                                        fontSize: 11,
                                        color: JobColor.appcolor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              plan['description'] ?? '',
                              style: urbanistRegular.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: selectedPlanId == null ? () { print("I have null"); }
                : () {  print("I have " + selectedPlanId.toString());
              final selected = controller.plans
                  .firstWhere((plan) => plan['id'] == selectedPlanId);

              final duration = int.tryParse(
                selected['duration']
                    .toString()
                    .replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
                  30;

              //controller.buyPlan(selectedPlanId!, duration);
             // Get.to(() => JobDashboard("0"));
            Get.to(() => JobCheckoutScreen(plan: selected));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: JobColor.appcolor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Buy Subscription',
              style: urbanistBold.copyWith(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
