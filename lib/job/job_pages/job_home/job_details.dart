import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/utils/job_app_settings.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';
import 'package:lcsjobs/job/utils/job_share_helper.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_applyjob.dart';
import 'job_applyjobwithprofile.dart';

class JobDetails extends StatefulWidget {
  final String jobId;
  const JobDetails({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetails> createState() => _JobDetailsState();
}

class _JobDetailsState extends State<JobDetails> {

  final JobHomeController controller = Get.put(JobHomeController());
  final jobappcontroller = Get.put(JobAppController());
  final storage = GetStorage();
  final RxBool _applying = false.obs;

  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  int isselected = 0;
  List type = [
    "Job Description"
  ];

  bool isSubscribed = false;
  bool alreadyApplied = false;
  int jobappiledcount = 0;
  int freejobapplied=0;

  @override
  void initState() {
    super.initState();
   // jobappcontroller.fetchSettings();
    isSubscribed = controller.subscription_status == "active";
    alreadyApplied = controller.applied_jobs.contains(widget.jobId);
    jobappiledcount = controller.applied_jobs.length;
    freejobapplied=jobappcontroller.getSettingFromLocal<int>('free_apply_limit', 0);
    controller.loadJobDetails(widget.jobId);
  }



  @override
  Widget build(BuildContext context) {
    size = MediaQuery
        .of(context)
        .size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        actions: [
          Row(
            children: [
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                  await _shareCurrentJob();
                },
                child:Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  JobPngimage.send,
                  height: height / 30,
                  color: themedata.isdark ? JobColor.white : JobColor.black,
                ),
              ),),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.job.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }
        final job = controller.job;
        // Assuming job['posted_on'] exists and is ISO8601
        final postedDate = DateTime.parse(job['posted_on']);
        final daysAgo = DateTime
            .now()
            .difference(postedDate)
            .inDays;
        // Option 2 (optional): calculated end date 30 days after posting
        final endDate = postedDate.add(Duration(days: 30));
        final endDateDisplay = DateFormat("d MMM").format(endDate);
        final List skills =
        (job['skills'] ?? []) as List;
        String citySlug = job['city'] ?? '';

        String cityName = controller.cities
            .firstWhere(
              (city) => city['slug'] == citySlug,
          orElse: () => {"name": citySlug},
        )['name']!;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width / 36, vertical: height / 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width / 1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: themedata.isdark
                          ? JobColor.borderblack
                          : JobColor.bggray)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: width / 36, vertical: height / 46),
                    child: Column(
                      children: [
                        Container(
                          height: height / 10,
                          width: height / 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: themedata.isdark
                                  ? JobColor.borderblack
                                  : JobColor.bggray,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              JobPngimage.logo, // or a generic company icon
                              height: height / 36,
                            ),
                          ),
                        ),
                        SizedBox(height: height / 36),
                        Text(
                          job['role'],
                          style: urbanistSemiBold.copyWith(fontSize: 22),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: height / 80,
                        ),
                        Text(
                          job['company_name'],
                          style: urbanistMedium.copyWith(
                              fontSize: 18, color: JobColor.appcolor),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: height / 96,
                        ),
                        Divider(
                          color: themedata.isdark
                              ? JobColor.borderblack
                              : JobColor.bggray,
                        ),
                        SizedBox(height: height / 96),
                        Text(
                          "${job['locality'] ?? ''}, $cityName",
                          style: urbanistMedium.copyWith(
                              fontSize: 18, color: JobColor.textgray),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: height / 66,
                        ),
                        Text(
                          "Rs.${job['min_salary']} - Rs.${job['max_salary']} /month",
                          style: urbanistSemiBold.copyWith(
                              fontSize: 18, color: JobColor.appcolor),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: height / 66,
                        ),
                        Wrap(
                          spacing: width / 26,      // horizontal space between tags
                          runSpacing: height / 120, // vertical space between lines
                          children: [
                            if (job['category'].toString().isNotEmpty)
                              _buildTag(job['category'].toString()),
                            if (job['experience_type'].toString().isNotEmpty)
                              _buildTag(job['experience_type'].toString()),
                            if (job['english_skill'].toString().isNotEmpty)
                              _buildTag(job['english_skill'].toString()),
                          ],
                        ),
                        SizedBox(height: height / 66),
                        if (job['work_timings'].toString().isNotEmpty)
                          Text(
                            job['work_timings'].toString(),
                            style: urbanistSemiBold.copyWith(
                              fontSize: 14,
                              color: JobColor.textgray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        SizedBox(
                          height: height / 66,
                        ),
                        Text(
                          "Posted $daysAgo days ago, ends in $endDateDisplay."
                              .tr,
                          style: urbanistSemiBold.copyWith(
                            fontSize: 14,
                            color: JobColor.textgray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 36,
                ),
                SizedBox(
                  height: height / 15,
                  child: ListView.separated(
                    itemCount: type.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return InkWell(
                        splashColor: JobColor.transparent,
                        highlightColor: JobColor.transparent,
                        onTap: () {
                          setState(() {
                            isselected = index;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              type[index],
                              style: urbanistSemiBold.copyWith(
                                  fontSize: 18,
                                  color: isselected == index
                                      ? JobColor.appcolor
                                      : JobColor.textgray),
                            ),
                            SizedBox(
                              height: height / 96,
                            ),
                            Container(
                              color: isselected == index
                                  ? JobColor.appcolor
                                  : JobColor.transparent,
                              height: height / 300,
                              width: width / 3.5,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Container(
                        width: width / 20,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: height / 66,
                ),
                if (isselected == 0) ...[
                  Text(
                    "Job_Description".tr,
                    style: urbanistBold.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: height / 40,
                  ),
                  Text(
                    job['job_role_description'],
                    style: urbanistMedium.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Text(
                    "Minimum_Qualifications".tr,
                    style: urbanistBold.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Text(
                    job['qualification'],
                    style: urbanistMedium.copyWith(
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(
                    height: height / 120,
                  ),
                  Text(
                    "Required_Skills".tr,
                    style: urbanistBold.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: height / 40,
                  ),
        GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: skills.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 5,
        childAspectRatio: (height / 1.5) / (width / 1.8),
        ),
        itemBuilder: (context, index) {
        return InkWell(
        splashColor: JobColor.transparent,
        highlightColor: JobColor.transparent,
        onTap: () {},
        child: Container(
        height: height / 20,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: JobColor.appcolor),
        ),
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 16),
        child: Center(
        child: Text(
        skills[index].toString(),
        style: urbanistSemiBold.copyWith(
        fontSize: 10,
        color: JobColor.appcolor,
        ),
        ),
        ),
        ),
        ),
        );
        },
        ),
                  SizedBox(
                    height: height / 40,
                  ),
                  Text(
                    "Jobs_Summary".tr,
                    style: urbanistBold.copyWith(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: height / 40,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Job_Level".tr,
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                            job['role'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Job_Category".tr,
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['category'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Educational".tr,
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['qualification'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Experience".tr,
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['experience_type'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "Min :"+job['min_experience'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              "Max :"+job['max_experience'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Vacancy".tr,
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['staff_count'].toString()+" Openings",
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("English Skill",
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(job['english_skill'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Work From Home",
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['work_from_home']?"Yes":"No",
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Work Timings",
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(job['work_timings'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: height / 46,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Security Deposit",
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['security_deposit']?"Yes":"No",
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: width / 2.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Bonus",
                                style: urbanistBold.copyWith(
                                  fontSize: 16,
                                )),
                            SizedBox(
                              height: height / 96,
                            ),
                            Text(
                              job['bonus_enabled']?"Yes":"No",
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(job['bonus_type'],
                              style: urbanistMedium.copyWith(
                                  fontSize: 16, color: JobColor.appcolor),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ]
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
        child: Builder(builder: (context) {
          // safe fallback for freejobapplied: null means unlimited
          final int? freeLimit = freejobapplied; // int? from your earlier logic

          // Decide whether the user has exceeded free limit
          final bool limitExceeded = (!isSubscribed && freeLimit != null && jobappiledcount >= freeLimit);

          // Already applied case
          if (alreadyApplied) {
            return Container(
              height: height / 15,
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey,
              ),
              child: Center(
                child: Text("Already Applied",
                    style: urbanistSemiBold.copyWith(fontSize: 16, color: Colors.white)),
              ),
            );
          }

          // Limit exceeded -> show subscribe CTA
          if (limitExceeded) {
            return InkWell(
              splashColor: JobColor.transparent,
              highlightColor: JobColor.transparent,
              onTap: () {
                Get.toNamed("/subscriptions");
              },
              child: Container(
                height: height / 15,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.orange,
                ),
                child: Center(
                  child: Text(
                    "Free Job Apply Limit Reached. Subscribe to Apply",
                    textAlign: TextAlign.center,
                    style: urbanistSemiBold.copyWith(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),
            );
          }

          // Default: show Apply button (with applying spinner)
          return Obx(() {
            final bool applying = _applying.value;
            return InkWell(
              splashColor: JobColor.transparent,
              highlightColor: JobColor.transparent,
              onTap: applying
                  ? null
                  : () async {
                // pre-check candidate id
                final candidateId = storage.read('candidate_id');
                if (candidateId == null) {
                  Get.snackbar('Not signed in', 'Please login to apply for jobs.');
                  return;
                }
                // mark busy
                _applying.value = true;
                try {
                  debugPrint('Applying for job ${widget.jobId} by candidate $candidateId');
                  final bool ok = await success(widget.jobId);
                  if (ok) {
                    // update local state so UI reflects that user already applied
                    setState(() {
                      alreadyApplied = true;
                      jobappiledcount = jobappiledcount + 1; // reflect new count
                    });
                    Get.snackbar('Success', 'Application submitted');
                  } else {
                    // success returned false — show message (success() already shows snackbar for errors)
                    debugPrint('Apply returned false for job ${widget.jobId}');
                    // Optionally show a message:
                    // Get.snackbar('Failed', 'Unable to apply. Please try again.');
                  }
                } catch (e, st) {
                  debugPrint('Apply error: $e\n$st');
                  Get.snackbar('Error', 'Apply failed. Check logs.');
                } finally {
                  _applying.value = false;
                }
              },
              child: Container(
                height: height / 15,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: applying ? Colors.grey : JobColor.appcolor,
                ),
                child: Center(
                  child: applying
                      ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: JobColor.white),
                  )
                      : Text("Apply", style: urbanistSemiBold.copyWith(fontSize: 16, color: JobColor.white)),
                ),
              ),
            );
          });
        }),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: JobColor.bggray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: urbanistMedium.copyWith(fontSize: 12),
      ),
    );
  }

  Future<bool> success(String jobId) async {
    // ✅ Always use your configured database instance
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
      'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    try {
      final userId = storage.read('candidate_id'); // Replace with your actual storage key
      if (userId == null) {
        Get.snackbar('Not signed in', 'Please login to apply for jobs.');
        debugPrint('Apply aborted: candidate_id missing in storage.');
        return false;
      }
      debugPrint('Applying: jobId=$jobId, candidateId=$userId');
      // --- 1) Read candidate node and normalize applied_jobs ---
      final candSnap = await database.child('candidate/$userId').get();
      List<String> existingJobs = [];

      if (candSnap.exists && candSnap.value != null) {
        final candVal = candSnap.value;
        if (candVal is Map && candVal.containsKey('applied_jobs') && candVal['applied_jobs'] != null) {
          final aj = candVal['applied_jobs'];
          if (aj is List) {
            existingJobs = aj.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
          } else if (aj is Map) {
            existingJobs = aj.values.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
          } else if (aj is String) {
            existingJobs = [aj];
          }
        }
      }

      // --- 2) Duplicate-check ---
      if (existingJobs.contains(jobId)) {
        debugPrint('Apply aborted: already applied to $jobId');
        Get.snackbar('Info', 'You have already applied for this job.');
        return false;
      }
      existingJobs.add(jobId);

      // --- 3) Create application record ---
      final appPushRef = database.child('applications').push();
      final appId = appPushRef.key;
      if (appId == null) {
        Get.snackbar('Error', 'Failed to create application id');
        debugPrint('Failed to generate push key for /applications');
        return false;
      }

      final nowIso = DateTime.now().toUtc().toIso8601String();
      final application = {
        'job_id': jobId,
        'candidate_id': userId,
        'status': 'applied',
        "managed_by": null,
        "managed_by_name": null,
        "managed_at": null,
        'created_at': nowIso,
        'updated_at': nowIso,
      };

      // --- 4) Atomic update ---
      final Map<String, dynamic> updates = {
        '/applications/$appId': application,
        '/candidate/$userId/applied_jobs': existingJobs,
      };

      await database.update(updates);
      debugPrint('Firebase update successful for appId=$appId');

      await storage.write('applied_jobs', existingJobs);

      // --- 5) Show success dialog ---
      if (!mounted) return true;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
              child: Column(
                children: [
                  Image.asset(JobPngimage.applysuccess, height: height / 6, fit: BoxFit.fitHeight),
                  SizedBox(height: height / 30),
                  Text("Congratulations".tr,
                      style: urbanistBold.copyWith(fontSize: 24, color: JobColor.appcolor)),
                  SizedBox(height: height / 46),
                  Text(
                    "Your application has been successfully submitted. You can track the progress of your application through the applications menu."
                        .tr,
                    textAlign: TextAlign.center,
                    style: urbanistRegular.copyWith(fontSize: 16),
                  ),
                  SizedBox(height: height / 26),
                  InkWell(
                    onTap: () {
                      Get.offAllNamed("/myapplication");
                    },
                    child: Container(
                      height: height / 15,
                      width: width / 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: JobColor.appcolor,
                      ),
                      child: Center(
                        child: Text("Go_to_My_Applications".tr,
                            style: urbanistSemiBold.copyWith(fontSize: 16, color: JobColor.white)),
                      ),
                    ),
                  ),
                  SizedBox(height: height / 56),
                  InkWell(
                    splashColor: JobColor.transparent,
                    highlightColor: JobColor.transparent,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: height / 15,
                      width: width / 1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: JobColor.lightblue,
                      ),
                      child: Center(
                        child: Text("Cancel".tr,
                            style: urbanistSemiBold.copyWith(fontSize: 16, color: JobColor.appcolor)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

      return true;
    } catch (e, st) {
      debugPrint('Apply error: $e\n$st');
      Get.snackbar('Error', 'Unable to apply. Please try again later.');
      return false;
    }
  }

  Future<void> _shareCurrentJob() async {
    if (controller.job.isEmpty) {
      Get.snackbar(
        'Error',
        'Job details not loaded yet',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final job = controller.job;

    // Get company settings
    final imageUrl = jobappcontroller.companyFileUrl;
    final companyUrl = jobappcontroller.getSetting<String>(
      'company_website',
      'https://laxmiconsultancyservices.com/',
    );

    await JobShareHelper.shareJobWithCompanyImage(
      context: context,
      job: job,
      imageUrl: imageUrl,
      companyUrl: companyUrl,
    );
  }


}

