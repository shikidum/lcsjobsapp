// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
// import 'package:lcsjobs/job/utils/job_home_controller.dart';
// import '../../job_gloabelclass/job_fontstyle.dart';
// import '../../job_gloabelclass/job_icons.dart';
// import '../job_theme/job_themecontroller.dart';
// import 'job_applicationstages.dart';
//
//
// class JobApplication extends StatefulWidget {
//   const JobApplication({Key? key}) : super(key: key);
//
//   @override
//   State<JobApplication> createState() => _JobApplicationState();
// }
//
// class _JobApplicationState extends State<JobApplication> {
//   dynamic size;
//   double height = 0.00;
//   double width = 0.00;
//   final themedata = Get.put(JobThemecontroler());
//   final JobHomeController controller = Get.find<JobHomeController>();
//   final ScrollController scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     scrollController.addListener(() {
//       if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
//         controller.loadMoreJobs();
//       }
//     });
//   }
//
//   List color = [
//     const Color(0x1A246BFD),
//     const Color(0x1A246BFD),
//     const Color(0x1AFF9800),
//     const Color(0x1AF75555),
//     const Color(0x1A4CAF50),
//   ];
//
//   List textcolor = [
//     const Color(0xff246BFD),
//     const Color(0xff246BFD),
//     const Color(0xffFACC15),
//     const Color(0xffF75555),
//     const Color(0xff07BD74),
//   ];
//
//
//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery.of(context).size;
//     height = size.height;
//     width = size.width;
//     return Scaffold(
//       appBar: AppBar(
//         leading: Padding(
//           padding: const EdgeInsets.all(15),
//           child: Image.asset(JobPngimage.logo,height: height/36,),
//         ),
//         title: Text("My Applications".tr,style: urbanistBold.copyWith(fontSize: 22 )),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(15),
//             child: Image.asset(JobPngimage.more,height: height/36,color: themedata.isdark?JobColor.white:JobColor.black,),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
//           child: Column(
//             children: [
//               SizedBox(height: height/36,),
//               Obx(() {
//                 return ListView.separated(
//                   controller: scrollController,
//                   physics: const NeverScrollableScrollPhysics(),
//                   shrinkWrap: true,
//                   itemCount: controller.jobs.length,
//                   itemBuilder: (context, index) {
//                     final job = controller.jobs[index];
//                     return Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(28),
//                         border: Border.all(color: themedata.isdark ? JobColor.borderblack : JobColor.bggray),
//                       ),
//                       child: ListTile(
//                         title: Text(job['role'] ?? 'N/A', style: urbanistSemiBold.copyWith(fontSize: 18)),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("${job['company_name'] ?? ''} • ${job['city'] ?? ''}", style: urbanistRegular),
//                         Container(
//                                           decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(6),
//                                               color: color[index]
//                                           ),
//                                           child: Padding(
//                                             padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/110),
//                                             child: Text("Application Status",style: urbanistSemiBold.copyWith(fontSize: 10,color: textcolor[index])),
//                                           ),
//                                         ),
//                           ],
//                         ),
//                         onTap: () {
//                                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                                     return const JobApplicationStages();
//                                   },));
//                         },
//                       ),
//                     );
//                   },
//                   separatorBuilder: (_, __) => SizedBox(height: 16),
//                 );
//               })
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_applicationstages.dart';

class JobApplication extends StatefulWidget {
  const JobApplication({Key? key}) : super(key: key);

  @override
  State<JobApplication> createState() => _JobApplicationState();
}

class _JobApplicationState extends State<JobApplication> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());

  // 🔹 Use existing controller instance
  final JobHomeController controller = Get.find<JobHomeController>();

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // 🔹 Load applications on screen open
    controller.loadUserApplications();
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case "applied":
        return const Color(0x1A246BFD);
      case "under_review":
        return const Color(0x1AFF9800);
      case "rejected":
        return const Color(0x1AF75555);
      case "hired":
        return const Color(0x1A4CAF50);
      default:
        return const Color(0x1A246BFD);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "applied":
        return const Color(0xff246BFD);
      case "under_review":
        return const Color(0xffFACC15);
      case "rejected":
        return const Color(0xffF75555);
      case "hired":
        return const Color(0xff07BD74);
      default:
        return const Color(0xff246BFD);
    }
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
          "My Applications".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(15),
          //   child: Image.asset(
          //     JobPngimage.more,
          //     height: height / 36,
          //     color:
          //     themedata.isdark ? JobColor.white : JobColor.black,
          //   ),
          // ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.loadUserApplications();
        },
        child: SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width / 36,
              vertical: height / 36,
            ),
            child: Column(
              children: [
                SizedBox(height: height / 36),
                Obx(() {
                  final items = controller.applicationsWithJobs;

                  if (items.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Text(
                        "You haven't applied to any jobs yet.",
                        style: urbanistRegular.copyWith(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final job = item["job"] ?? {};
                      final status =
                      (item["status"] ?? "applied") as String;

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: themedata.isdark
                                ? JobColor.borderblack
                                : JobColor.bggray,
                          ),
                        ),
                        child: ListTile(
                          title: Text(
                            job['role'] ?? 'N/A',
                            style: urbanistSemiBold.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${job['company_name'] ?? ''} • ${job['city'] ?? ''}",
                                style: urbanistRegular,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(6),
                                  color: _statusBgColor(status),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width / 36,
                                    vertical: height / 110,
                                  ),
                                  child: Text(
                                    status.capitalizeFirst ??
                                        "Application Status",
                                    style: urbanistSemiBold.copyWith(
                                      fontSize: 10,
                                      color: _statusTextColor(status),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            final item = items[index]; // from your Obx builder
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return JobApplicationStages(application: item);
                                },
                              ),
                            );
                          },
                        ),
                      );
                    },
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
