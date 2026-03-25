import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_editjobcategory.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_editprofile.dart';
import 'package:lcsjobs/job/utils/job_app_settings.dart';
import '../../utils/job_home_controller.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_details.dart';
import 'job_notification.dart';
import 'job_recentjobs.dart';
import 'job_search.dart';
import 'dart:async';

class JobHome extends StatefulWidget {
  const JobHome({Key? key}) : super(key: key);

  @override
  State<JobHome> createState() => _JobHomeState();
}

class _JobHomeState extends State<JobHome> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());

  final ScrollController scrollController = ScrollController();
  final JobAppController jobappcontroller = Get.put(JobAppController());
  final homecontroller = Get.find<JobHomeController>();
  Timer? _refreshTimer; // 🔹 auto-refresh timer

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      homecontroller.loadInitialMatchedJobs();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel(); // 🔹 important: cancel timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  size = MediaQuery.of(context).size;
  height = size.height;
  width = size.width;
  final storedLocality = homecontroller.storage.read("preferred_locality");
  final Categ = homecontroller.storage.read("desired_category");
    return Scaffold(
      appBar: AppBar(
        leadingWidth: width/1,
        toolbarHeight: height/9,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: homecontroller.UserProfile.value == ''
                    ? AssetImage(JobPngimage.profile) as ImageProvider
                    : NetworkImage(homecontroller.UserProfile.value),
              ),
              SizedBox(width: width/26,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height/120,),
                  Text("Hi",style: urbanistRegular.copyWith(fontSize: 16 )),
                  SizedBox(height: height/120,),
                  Text(homecontroller.UserName.value,style: urbanistBold.copyWith(fontSize: 12 )),
                ],
              ),
              const Spacer(),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                  jobappcontroller.shareReferral();
                },
                child: Container(
                  height: height/16,
                  width: height/10,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
                    color: themedata.isdark?JobColor.black:JobColor.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.whatapp,height: height/36,color: themedata.isdark?JobColor.white:JobColor.black,),
                        Text("Refer",style: urbanistRegular.copyWith(fontSize: 12 )),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Get.toNamed('/alerts');
                },
                child: Container(
                  height: height/16,
                  width: height/16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(JobPngimage.notification,height: height/36,color: themedata.isdark?JobColor.white:JobColor.black,),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      // 🔹 Pull-to-refresh added here
      body: Column(
        children: [
          Container(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      splashColor: JobColor.transparent,
                      highlightColor: JobColor.transparent,
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const JobEditprofile();
                        },));
                      },
                      child: Container(child:
                      Row(
                        children: [
                          Icon(Icons.pin_drop_outlined, color: themedata.isdark?JobColor.white:JobColor.black, size: 20),
                          Text(storedLocality,style: urbanistRegular.copyWith(fontSize: 16)),
                        ],
                      )),
                    ),
                    InkWell(
                      splashColor: JobColor.transparent,
                      highlightColor: JobColor.transparent,
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const JobEditJobCategry();
                        },));
                      },
                      child: Container(child: Row(
                        children: [
                          Icon(Icons.account_box_outlined, color: themedata.isdark?JobColor.white:JobColor.black, size: 20),
                          Text(Categ,style: urbanistRegular.copyWith(fontSize: 16)),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          /// 🔹 FIXED SEARCH BAR
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width / 36,
              vertical: height / 36,
            ),
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JobSearch(),
                  ),
                );
              },
              style: urbanistSemiBold.copyWith(fontSize: 16),
              decoration: InputDecoration(
                hintStyle: urbanistRegular.copyWith(
                  fontSize: 16,
                  color: JobColor.textgray,
                ),
                hintText: "Search for a job or company".tr,
                fillColor: themedata.isdark
                    ? JobColor.lightblack
                    : JobColor.appgray,
                filled: true,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: height / 36,
                  color: JobColor.textgray,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    JobPngimage.filter,
                    height: height / 36,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          /// 🔹 SCROLLABLE + REFRESHABLE LIST
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await homecontroller.loadInitialMatchedJobs();
              },
              child: Obx(() {
                final jobs = homecontroller.matchedJobs;
                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width / 36),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: jobs.length + 3, // +1 for loader
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return jobappcontroller.companyBannerUrl != null &&
                          jobappcontroller.companyBannerUrl.toString().isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          jobappcontroller.companyBannerUrl.toString(),
                          width: width,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Image.asset(
                              JobPngimage.homebanner,
                              width: width,
                              fit: BoxFit.fitWidth,
                            );
                          },
                        ),
                      )
                          : Image.asset(
                        JobPngimage.homebanner,
                        width: width,
                        fit: BoxFit.fitWidth,
                      );
                    }

                    /// 🔹 1️⃣ TITLE
                    if (index == 1) {
                      return Row(
                        children: [
                          Text(
                            "Jobs for you",
                            style: urbanistBold.copyWith(fontSize: 20),
                          ),
                          const Spacer(),
                        ],
                      );
                    }

                    /// 🔥 LOAD MORE TRIGGER
                    if (index == jobs.length) {
                      if (!homecontroller.isLoadingMore.value) {
                        homecontroller.loadMoreMatchedJobs();
                      }
                    }

                    /// 🔹 LOADER
                    if (index == jobs.length + 2) {
                      return Obx(() => homecontroller.isLoadingMore.value
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      )
                          : const SizedBox());
                    }

                    /// 🔹 JOB ITEMS (OFFSET BY 2)
                    final job = jobs[index - 2];

                    String citySlug = job['city'] ?? '';
                    String cityName = homecontroller.cities
                        .firstWhere(
                          (city) => city['slug'] == citySlug,
                      orElse: () => {"name": citySlug},
                    )['name']!;
                    return InkWell(
                      onTap: () {
                        Get.to(() => JobDetails(jobId: job['job_id']));
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: themedata.isdark ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: themedata.isdark
                                ? JobColor.borderblack
                                : JobColor.bggray,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job['role'] ?? 'N/A',
                              style: urbanistSemiBold.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job['company_name'] ?? '',
                              style: urbanistRegular.copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${job['locality'] ?? ''}, $cityName",
                              style: urbanistRegular.copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Rs.${job['min_salary']} - Rs.${job['max_salary']} /month",
                              style: urbanistSemiBold.copyWith(
                                fontSize: 10,
                                color: JobColor.appcolor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildTag(job['category']),
                                const SizedBox(width: 4),
                                _buildTag(job['english_skill']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      // RefreshIndicator(
      //   onRefresh: () async {
      //     await homecontroller.loadInitialMatchedJobs();
      //   },
      //   child: SingleChildScrollView(
      //     controller: scrollController,
      //     physics: const AlwaysScrollableScrollPhysics(), // 🔹 needed for RefreshIndicator
      //     child: Padding(
      //       padding: EdgeInsets.symmetric(
      //         horizontal: width / 36,
      //         vertical: height / 36,
      //       ),
      //       child: Column(
      //         children: [
      //           TextField(
      //             onTap: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(
      //                   builder: (context) {
      //                     return const JobSearch();
      //                   },
      //                 ),
      //               );
      //             },
      //             style: urbanistSemiBold.copyWith(fontSize: 16),
      //             readOnly: true,
      //             decoration: InputDecoration(
      //               hintStyle: urbanistRegular.copyWith(
      //                 fontSize: 16,
      //                 color: JobColor.textgray,
      //               ),
      //               hintText: "Search for a job or company".tr,
      //               fillColor: themedata.isdark
      //                   ? JobColor.lightblack
      //                   : JobColor.appgray,
      //               filled: true,
      //               prefixIcon: Icon(
      //                 Icons.search_rounded,
      //                 size: height / 36,
      //                 color: JobColor.textgray,
      //               ),
      //               suffixIcon: Padding(
      //                 padding: const EdgeInsets.all(12),
      //                 child: Image.asset(
      //                   JobPngimage.filter,
      //                   height: height / 36,
      //                 ),
      //               ),
      //               enabledBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(16),
      //                 borderSide: BorderSide.none,
      //               ),
      //               focusedBorder: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(16),
      //                 borderSide: BorderSide.none,
      //               ),
      //             ),
      //           ),
      //           SizedBox(height: height / 36),
      //           jobappcontroller.companyBannerUrl != null && jobappcontroller.companyBannerUrl.toString().isNotEmpty
      //       ? ClipRRect(
      //     borderRadius: BorderRadius.circular(12),
      //     child: Image.network(
      //       jobappcontroller.companyBannerUrl.toString(),
      //       width: width,
      //       fit: BoxFit.cover,
      //       errorBuilder: (_, __, ___) {
      //         return Image.asset(
      //           JobPngimage.homebanner,
      //           width: width,
      //           fit: BoxFit.fitWidth,
      //         );
      //       },
      //     ),
      //   )
      //       : Image.asset(
      //     JobPngimage.homebanner,
      //     width: width,
      //     fit: BoxFit.fitWidth,
      //   ),
      //           SizedBox(height: height / 26),
      //           Row(
      //             children: [
      //               Text(
      //                 "Jobs for you",
      //                 style: urbanistBold.copyWith(fontSize: 20),
      //               ),
      //               const Spacer(),
      //             ],
      //           ),
      //           SizedBox(height: height / 36),
      //
      //           // 🔹 Job list (no own scroll controller)
      //           Obx(() {
      //             if (homecontroller.jobs.isEmpty) {
      //               return Padding(
      //                 padding: const EdgeInsets.only(top: 32.0),
      //                 child: Text(
      //                   "No jobs found",
      //                   style: urbanistRegular.copyWith(fontSize: 16),
      //                 ),
      //               );
      //             }
      //
      //             return ListView.separated(
      //               physics: const NeverScrollableScrollPhysics(),
      //               shrinkWrap: true,
      //               itemCount: homecontroller.matchedJobs.length,
      //               itemBuilder: (context, index) {
      //                 final job = homecontroller.matchedJobs[index];
      //                 String citySlug = job['city'] ?? '';
      //
      //                 String cityName = homecontroller.cities
      //                     .firstWhere(
      //                       (city) => city['slug'] == citySlug,
      //                   orElse: () => {"name": citySlug},
      //                 )['name']!;
      //                 return InkWell(
      //                   onTap: () {
      //                     Get.to(() => JobDetails(jobId: job['job_id']));
      //                   },
      //                   child: Container(
      //                     margin:
      //                     const EdgeInsets.symmetric(vertical: 1),
      //                     padding: const EdgeInsets.all(5),
      //                     decoration: BoxDecoration(
      //                       color: themedata.isdark
      //                           ? Colors.black
      //                           : Colors.white,
      //                       borderRadius: BorderRadius.circular(20),
      //                       border: Border.all(
      //                         color: themedata.isdark
      //                             ? JobColor.borderblack
      //                             : JobColor.bggray,
      //                       ),
      //                       boxShadow: const [
      //                         BoxShadow(
      //                           color: Colors.black12,
      //                           blurRadius: 6,
      //                           offset: Offset(0, 3),
      //                         )
      //                       ],
      //                     ),
      //                     child: Column(
      //                       crossAxisAlignment:
      //                       CrossAxisAlignment.start,
      //                       children: [
      //                         const SizedBox(height: 2),
      //                         Text(
      //                           job['role'] ?? 'N/A',
      //                           style: urbanistBold.copyWith(
      //                               fontSize: 12),
      //                         ),
      //                         const SizedBox(height: 2),
      //                         Text(
      //                           job['company_name'] ?? '',
      //                           style: urbanistSemiBold.copyWith(
      //                               fontSize: 10),
      //                         ),
      //                         const SizedBox(height: 2),
      //                         Text(
      //                           "${job['locality'] ?? ''}, $cityName",
      //                           style: urbanistRegular.copyWith(
      //                               fontSize: 10),
      //                         ),
      //                         const SizedBox(height: 2),
      //                         Text(
      //                           "Rs.${job['min_salary']} - Rs.${job['max_salary']} /month",
      //                           style: urbanistSemiBold.copyWith(
      //                             fontSize: 10,
      //                             color: JobColor.appcolor,
      //                           ),
      //                         ),
      //                         const SizedBox(height: 12),
      //                         Row(
      //                           children: [
      //                             _buildTag(job['category'] ?? ''),
      //                             const SizedBox(width: 4),
      //                             _buildTag(job['english_skill'] ?? ''),
      //                           ],
      //                         ),
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               },
      //               separatorBuilder: (_, __) =>
      //               const SizedBox(height: 2),
      //             );
      //           }),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
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
}
