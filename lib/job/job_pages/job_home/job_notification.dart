// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart'; // 👈 for date formatting
// import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
// import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
// import 'package:lcsjobs/job/utils/job_notification_controller4.dart';
//
// import '../../job_gloabelclass/job_fontstyle.dart';
// import '../job_theme/job_themecontroller.dart';
// // 👇 import the controller we created
//
//
// class JobNotification extends StatefulWidget {
//   const JobNotification({Key? key}) : super(key: key);
//
//   @override
//   State<JobNotification> createState() => _JobNotificationState();
// }
//
// class _JobNotificationState extends State<JobNotification> {
//   dynamic size;
//   double height = 0.00;
//   double width = 0.00;
//   final themedata = Get.put(JobThemecontroler());
//
//   // 🔹 We'll still reuse your icon/color lists, but now for dynamic notifications
//   final List<String> icon = [
//     JobPngimage.g1,
//     JobPngimage.g2,
//     JobPngimage.g3,
//     JobPngimage.g4,
//     JobPngimage.g5,
//   ];
//
//   final List<Color> color = const [
//     Color(0x1A246BFD),
//     Color(0x1A246BFD),
//     Color(0x1AFF9800),
//     Color(0x1AF75555),
//     Color(0x1A4CAF50),
//   ];
//
//   final List<Color> textcolor = const [
//     Color(0xff246BFD),
//     Color(0xff246BFD),
//     Color(0xffFACC15),
//     Color(0xffF75555),
//     Color(0xff07BD74),
//   ];
//
//   // 🔹 Applications tab demo data (unchanged)
//   List application = [
//     "Product Management",
//     "UX Designer & Developer",
//     "Quality Assurance",
//     "Software Engineer",
//     "Network Administrator"
//   ];
//   List applicationdesc = [
//     "Dribbble Inc.",
//     "Sketch",
//     "AirBNB",
//     "Twitter Inc.",
//     "WeChat"
//   ];
//   List applicationsicon = [
//     JobPngimage.a1,
//     JobPngimage.a2,
//     JobPngimage.a3,
//     JobPngimage.a4,
//     JobPngimage.a5,
//   ];
//
//   List status = [
//     "Application Sent",
//     "Application Sent",
//     "Application Pending",
//     "Application Rejected",
//     "Application Accepted"
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery.of(context).size;
//     height = size.height;
//     width = size.width;
//
//     // 👇 Get the NotificationController with FCM data
//     final notificationController = Get.find<NotificationController>();
//
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             "Notification".tr,
//             style: urbanistBold.copyWith(fontSize: 22),
//           ),
//           actions: [
//             Padding(
//               padding: const EdgeInsets.all(15),
//               child: Image.asset(
//                 JobPngimage.more,
//                 height: height / 36,
//                 color: themedata.isdark ? JobColor.white : JobColor.black,
//               ),
//             ),
//           ],
//           bottom: TabBar(
//             indicatorColor: JobColor.appcolor,
//             dividerColor: JobColor.bggray,
//             labelColor: JobColor.appcolor,
//             labelPadding: EdgeInsets.only(bottom: height / 96),
//             indicatorPadding: EdgeInsets.symmetric(horizontal: width / 26),
//             unselectedLabelColor: JobColor.textgray,
//             unselectedLabelStyle:
//             urbanistSemiBold.copyWith(fontSize: 18),
//             labelStyle: urbanistSemiBold.copyWith(fontSize: 18),
//             tabs: [
//               Text("General".tr),
//               Text("Applications".tr),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             /// 🔹 GENERAL TAB - now uses FCM notifications
//             Obx(() {
//               final notifs = notificationController.notifications;
//
//               if (notifs.isEmpty) {
//                 // your original empty-state UI
//                 return Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: width / 36, vertical: height / 36),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         JobPngimage.empty,
//                         height: height / 3.5,
//                         fit: BoxFit.fitHeight,
//                       ),
//                       SizedBox(height: height / 16),
//                       Text(
//                         "Empty".tr,
//                         style:
//                         urbanistSemiBold.copyWith(fontSize: 24),
//                       ),
//                       SizedBox(height: height / 46),
//                       Text(
//                         "You_dont_have_any_notifications_at_this_time"
//                             .tr,
//                         style:
//                         urbanistRegular.copyWith(fontSize: 18),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 );
//               }
//
//               return SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: width / 36, vertical: height / 36),
//                   child: Column(
//                     children: [
//                       ListView.separated(
//                         itemCount: notifs.length,
//                         physics: const NeverScrollableScrollPhysics(),
//                         shrinkWrap: true,
//                         itemBuilder: (context, index) {
//                           final notif = notifs[index];
//
//                           // 🔹 Format date like your template
//                           final formattedDate =
//                           DateFormat('dd MMM, yyyy | hh:mm a')
//                               .format(notif.receivedAt);
//
//                           final bgColor =
//                           color[index % color.length]; // cycle
//                           final iconPath =
//                           icon[index % icon.length]; // cycle
//
//                           // 🔹 Mark "New" if received in last 24 hours
//                           final bool isNew =
//                               DateTime.now()
//                                   .difference(notif.receivedAt)
//                                   .inHours <
//                                   24;
//
//                           return InkWell(
//                             splashColor: JobColor.transparent,
//                             highlightColor: JobColor.transparent,
//                             onTap: () {
//                               // You can navigate to details if needed
//                             },
//                             child: Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                       height: height / 13,
//                                       width: height / 13,
//                                       decoration: BoxDecoration(
//                                         borderRadius:
//                                         BorderRadius.circular(50),
//                                         color: bgColor,
//                                       ),
//                                       child: Padding(
//                                         padding: const EdgeInsets.all(18),
//                                         child: Image.asset(
//                                           iconPath,
//                                           height: height / 66,
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: width / 26),
//                                     Column(
//                                       crossAxisAlignment:
//                                       CrossAxisAlignment.start,
//                                       children: [
//                                         SizedBox(
//                                           width: width / 1.8,
//                                           child: Text(
//                                             notif.title.isEmpty
//                                                 ? "Notification"
//                                                 : notif.title,
//                                             style: urbanistSemiBold.copyWith(
//                                                 fontSize: 19),
//                                             maxLines: 1,
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                           ),
//                                         ),
//                                         SizedBox(height: height / 80),
//                                         Text(
//                                           formattedDate,
//                                           style: urbanistRegular.copyWith(
//                                               fontSize: 14),
//                                           maxLines: 1,
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                         ),
//                                       ],
//                                     ),
//                                     const Spacer(),
//                                     if (isNew) ...[
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           borderRadius:
//                                           BorderRadius.circular(6),
//                                           color: JobColor.appcolor,
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.symmetric(
//                                             horizontal: width / 36,
//                                             vertical: height / 110,
//                                           ),
//                                           child: Text(
//                                             "New".tr,
//                                             style: urbanistSemiBold
//                                                 .copyWith(
//                                               fontSize: 10,
//                                               color: JobColor.white,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                                 SizedBox(height: height / 40),
//                                 Text(
//                                   notif.body.isEmpty
//                                       ? ""
//                                       : notif.body,
//                                   style: urbanistRegular.copyWith(
//                                       fontSize: 15),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                         separatorBuilder: (context, index) {
//                           return Column(
//                             children: [
//                               SizedBox(height: height / 80),
//                               Divider(
//                                 color: themedata.isdark
//                                     ? JobColor.borderblack
//                                     : JobColor.bggray,
//                               ),
//                               SizedBox(height: height / 80),
//                             ],
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             }),
//
//             /// 🔹 APPLICATIONS TAB - unchanged (your design)
//             SingleChildScrollView(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: width / 36, vertical: height / 36),
//                 child: Column(
//                   children: [
//                     ListView.separated(
//                       itemCount: application.length,
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemBuilder: (context, index) {
//                         return InkWell(
//                           splashColor: JobColor.transparent,
//                           highlightColor: JobColor.transparent,
//                           onTap: () {},
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Container(
//                                     height: height / 13,
//                                     width: height / 13,
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                       BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: themedata.isdark
//                                             ? JobColor.borderblack
//                                             : JobColor.bggray,
//                                       ),
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(12),
//                                       child: Image.asset(
//                                         applicationsicon[index],
//                                         height: height / 36,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: width / 26),
//                                   Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       SizedBox(
//                                         width: width / 1.8,
//                                         child: Text(
//                                           application[index],
//                                           style:
//                                           urbanistSemiBold.copyWith(
//                                               fontSize: 19),
//                                           maxLines: 1,
//                                           overflow:
//                                           TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       SizedBox(height: height / 80),
//                                       Text(
//                                         applicationdesc[index],
//                                         style: urbanistMedium.copyWith(
//                                           fontSize: 16,
//                                           color: JobColor.textgray,
//                                         ),
//                                         maxLines: 1,
//                                         overflow:
//                                         TextOverflow.ellipsis,
//                                       ),
//                                     ],
//                                   ),
//                                   const Spacer(),
//                                   Icon(
//                                     Icons.arrow_forward_ios,
//                                     size: height / 46,
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: height / 80),
//                               Row(
//                                 crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                                 children: [
//                                   Container(
//                                     height: height / 20,
//                                     width: height / 13,
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                       BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: JobColor.transparent,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: width / 26),
//                                   Container(
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                       BorderRadius.circular(6),
//                                       color: color[index %
//                                           color.length],
//                                     ),
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: width / 36,
//                                         vertical: height / 110,
//                                       ),
//                                       child: Text(
//                                         status[index],
//                                         style:
//                                         urbanistSemiBold.copyWith(
//                                           fontSize: 10,
//                                           color: textcolor[index %
//                                               textcolor.length],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                       separatorBuilder: (context, index) {
//                         return Column(
//                           children: [
//                             Divider(
//                               color: themedata.isdark
//                                   ? JobColor.borderblack
//                                   : JobColor.bggray,
//                             ),
//                             SizedBox(height: height / 80),
//                           ],
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/utils/app_notification.dart';
import 'package:lcsjobs/job/utils/job_notification_controller4.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';
import 'package:lcsjobs/job/utils/job_notification_controller4.dart';

class JobNotification extends StatefulWidget {
  const JobNotification({Key? key}) : super(key: key);

  @override
  State<JobNotification> createState() => _JobNotificationState();
}

class _JobNotificationState extends State<JobNotification> {
  dynamic size;
  double height = 0.0;
  double width = 0.0;
  final themedata = Get.put(JobThemecontroler());
  final dateFormat = DateFormat('dd MMM, yyyy | hh:mm a');

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    final notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notification".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              if (notificationController.notifications.isNotEmpty) {
                notificationController.clearAll();
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        final notifs = notificationController.notifications;

        if (notifs.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width / 36, vertical: height / 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // You can use your own empty image or remove it
                // Image.asset(JobPngimage.empty, height: height / 3.5, fit: BoxFit.fitHeight),
                Icon(Icons.notifications_off,
                    size: height / 6, color: JobColor.textgray),
                SizedBox(height: height / 16),
                Text(
                  "Empty".tr,
                  style: urbanistSemiBold.copyWith(fontSize: 24),
                ),
                SizedBox(height: height / 46),
                Text(
                  "You_dont_have_any_notifications_at_this_time".tr,
                  style: urbanistRegular.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(
              horizontal: width / 36, vertical: height / 36),
          itemCount: notifs.length,
          separatorBuilder: (context, index) => Divider(
            color: themedata.isdark
                ? JobColor.borderblack
                : JobColor.bggray,
          ),
          itemBuilder: (context, index) {
            final notif = notifs[index];

            final dateText = dateFormat.format(notif.receivedAt);

            // color based on type
            final Color chipColor = _colorForType(notif.type);

            return InkWell(
              splashColor: JobColor.transparent,
              highlightColor: JobColor.transparent,
              onTap: () {
                _handleNotificationTap(notif);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: height / 120),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Leading circle with first letter
                    CircleAvatar(
                      radius: height / 28,
                      backgroundColor: chipColor.withOpacity(0.2),
                      child: Text(
                        (notif.title.isNotEmpty
                            ? notif.title[0]
                            : 'N')
                            .toUpperCase(),
                        style: urbanistSemiBold.copyWith(
                          fontSize: 18,
                          color: chipColor,
                        ),
                      ),
                    ),
                    SizedBox(width: width / 26),
                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.title.isEmpty
                                ? "Notification"
                                : notif.title,
                            style: urbanistSemiBold.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: height / 200),
                          Text(
                            dateText,
                            style: urbanistRegular.copyWith(
                              fontSize: 13,
                              color: JobColor.textgray,
                            ),
                          ),
                          SizedBox(height: height / 120),
                          if (notif.body.isNotEmpty)
                            Text(
                              notif.body,
                              style: urbanistRegular.copyWith(
                                fontSize: 15,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Delete icon
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        notificationController
                            .deleteNotification(notif.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'job':
        return JobColor.appcolor;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      default:
        return themedata.isdark
            ? JobColor.white
            : JobColor.appcolor;
    }
  }

  void _handleNotificationTap(AppNotification notif) {
    // Example: if your FCM data contains {"type":"job","jobId":"123"}
    final data = notif.data ?? {};

    if (data['type'] == 'job' && data['jobId'] != null) {
      final jobId = data['jobId'];

      // Navigate to your job detail page (adjust route/args as needed)
      Get.toNamed(
        '/job_detail',
        arguments: {'jobId': jobId},
      );
    } else {
      // No deep link -> maybe just show a dialog or do nothing
       Get.snackbar("Notification", "No linked action");
    }
  }
}
