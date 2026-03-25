import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_details.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_search.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../job_theme/job_themecontroller.dart';

class JobSaveapplication extends StatefulWidget {
  const JobSaveapplication({Key? key}) : super(key: key);

  @override
  State<JobSaveapplication> createState() => _JobSaveapplicationState();
}

class _JobSaveapplicationState extends State<JobSaveapplication> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final themedata = Get.put(JobThemecontroler());
  final homecontroller = Get.find<JobHomeController>();

  Timer? _refreshTimer; // 🔹 auto-refresh timer

  @override
  void initState() {
    super.initState();
    // 🔹 Auto refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 100), (_) {
      homecontroller.loadInitialJobs();
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

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset(
            JobPngimage.logo,
            height: height / 36,
          ),
        ),
        title: Text(
          "Recent_Jobs".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
      ),

      body: Column(
        children: [
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
                await homecontroller.loadInitialJobs();
              },
              child: Obx(() {
                final jobs = homecontroller.jobs;

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: width / 36),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: jobs.length + 1, // +1 for loader
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {

                    /// 🔥 LOAD MORE TRIGGER
                    if (index == jobs.length - 3) {
                      homecontroller.loadMoreJobs();
                    }

                    /// 🔹 SHOW LOADER AT END
                    if (index == jobs.length) {
                      return Obx(() => homecontroller.isLoadingMore.value
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : const SizedBox());
                    }

                    final job = jobs[index];
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
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: JobColor.bggray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: urbanistMedium.copyWith(fontSize: 8),
      ),
    );
  }
  _showremovebottomsheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    height: height / 1.9,
                    decoration: const BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width / 36, vertical: height / 56),
                      child: Column(
                        children: [
                          Text(
                            "Remove_from_Saved".tr,
                            style: urbanistBold.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(
                            height: height / 80,
                          ),
                          const Divider(),
                          SizedBox(
                            height: height / 56,
                          ),
                      Container(
                        width: width/1,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: width/26,vertical: height/46),
                          child: InkWell(
                            splashColor: JobColor.transparent,
                            highlightColor: JobColor.transparent,
                            onTap: () {
                              setState(() {

                              });
                            },
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: height/12,
                                      width: height/12,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15),
                                        child: Image.asset(JobPngimage.a1,height: height/36,),
                                      ),
                                    ),
                                    SizedBox(width: width/26,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                                width: width/1.8,
                                                child: Text("UI & UX Researcher",style: urbanistSemiBold.copyWith(fontSize: 20 ),maxLines: 1,overflow: TextOverflow.ellipsis,)),
                                            SizedBox(width: width/56,),
                                            Image.asset(JobPngimage.savefill,height: height/36,color: JobColor.appcolor,),
                                          ],
                                        ),
                                        SizedBox(height: height/80,),
                                        Text("Dribbble Inc.",style: urbanistMedium.copyWith(fontSize: 16 ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),

                                  ],
                                ),
                                SizedBox(height: height/96,),
                                 Divider(color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
                                SizedBox(height: height/96,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: height/12,
                                      width: height/12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    SizedBox(width: width/26,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Paris, France",style: urbanistMedium.copyWith(fontSize: 18 ),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                        SizedBox(height: height/66,),
                                        Text("\$10,000 - \$25,000 /month".tr,style: urbanistSemiBold.copyWith(fontSize: 18,color: JobColor.appcolor),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                        SizedBox(height: height/66,),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: JobColor.textgray)
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: width/26,vertical: height/96),
                                                child: Text("Full Time".tr,style: urbanistSemiBold.copyWith(fontSize: 10,color: JobColor.textgray)),
                                              ),
                                            ),
                                            SizedBox(width: width/26,),
                                            Container(
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(color: JobColor.textgray)
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: width/26,vertical: height/96),
                                                child: Text("Onsite".tr,style: urbanistSemiBold.copyWith(fontSize: 10,color: JobColor.textgray)),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                          SizedBox(
                            height: height / 56,
                          ),
                          Row(
                            children: [
                              InkWell(
                                splashColor: JobColor.transparent,
                                highlightColor: JobColor.transparent,
                                onTap: () {
                                Navigator.pop(context);
                                },
                                child: Container(
                                  height: height / 15,
                                  width: width / 2.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: JobColor.lightblue,
                                  ),
                                  child: Center(
                                    child: Text("Cancel".tr,
                                        style: urbanistSemiBold.copyWith(
                                            fontSize: 16,
                                            color: JobColor.appcolor)),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                splashColor: JobColor.transparent,
                                highlightColor: JobColor.transparent,
                                onTap: () {
                                 /* Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return const JobApplywithProfile();
                                  },));*/
                                },
                                child: Container(
                                  height: height / 15,
                                  width: width / 2.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: JobColor.appcolor,
                                  ),
                                  child: Center(
                                    child: Text("Yes_Remove".tr,
                                        style: urbanistSemiBold.copyWith(
                                            fontSize: 16, color: JobColor.white)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ));
              });
        });
  }

}
