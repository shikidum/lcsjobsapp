import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_auth_controller/job_login_controller.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_login.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_loginoption.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_dashboard.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_setting/job_invitefriends.dart';
import 'package:store_redirect/store_redirect.dart';
// import 'package:url_launcher/url_launcher.dart';

import '../../../job_gloabelclass/job_fontstyle.dart';
import '../../job_theme/job_themecontroller.dart';
import 'job_deactivateaccount.dart';
import 'job_helpcenter.dart';
import 'job_languagesetting.dart';
import 'job_linkedaccounts.dart';
import 'job_notificationsetting.dart';
import 'job_personalinfor.dart';
import 'job_security.dart';
import 'job_seekingstatus.dart';

class JobSetting extends StatefulWidget {
  const JobSetting({Key? key}) : super(key: key);

  @override
  State<JobSetting> createState() => _JobSettingState();
}

class _JobSettingState extends State<JobSetting> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobLoginController joblogincontroller = Get.put(JobLoginController());
  bool isDark = false;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height/36,),
              Row(
                children: [
                  Image.asset(JobPngimage.show,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                  SizedBox(width: width/26),
                  Text("Dark_Mode".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                  const Spacer(),
                  SizedBox(
                    height: height / 36,
                    child: Switch(
                        activeColor: JobColor.appcolor,
                        onChanged: (state) {
                          setState(() {
                            themedata.changeThem(state);
                            isDark = state;
                            themedata.update();
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return JobDashboard("0");
                          },));
                        },
                        value: themedata.isdark),
                  ),
                ],
              ),
              // SizedBox(height: height/36,),
              // InkWell(
              //   splashColor: JobColor.transparent,
              //   highlightColor: JobColor.transparent,
              //   onTap: () {
              //     _showbottomsheet();
              //   },
              //   child: Row(
              //     children: [
              //       Image.asset(JobPngimage.swap,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
              //       SizedBox(width: width/26),
              //       Text("Change_Layout".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
              //       const Spacer(),
              //       const Icon(Icons.arrow_forward_ios_outlined,size: 15),
              //     ],
              //   ),
              // ),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobHelpcenter();
                  },));
                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.infosquare,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                    SizedBox(width: width/26),
                    Text("Help_Center".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_outlined,size: 15),
                  ],
                ),
              ),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                  // final packageName = "com.lcs.jobs"; // Replace with your real Play Store package name
                  // final playStoreUrl = Uri.parse("market://details?id=$packageName");
                  //
                  // if (await canLaunchUrl(playStoreUrl)) {
                  // await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
                  // } else {
                  // // Fallback to browser if Play Store app is not available
                  // final webUrl = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");
                  // await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  // }
                  // FlutterWebBrowser.openWebPage(
                  //   url: "market://details?id=$packageName",
                  //   customTabsOptions: const CustomTabsOptions(
                  //     colorScheme: CustomTabsColorScheme.dark,
                  //     toolbarColor: Colors.deepPurple,
                  //     secondaryToolbarColor: Colors.green,
                  //     navigationBarColor: Colors.amber,
                  //     shareState: CustomTabsShareState.on,
                  //     instantAppsEnabled: true,
                  //     showTitle: true,
                  //     urlBarHidingEnabled: true,
                  //   ),
                  //   safariVCOptions: const SafariViewControllerOptions(
                  //     barCollapsingEnabled: true,
                  //     preferredBarTintColor: Colors.green,
                  //     preferredControlTintColor: Colors.amber,
                  //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                  //     modalPresentationCapturesStatusBarAppearance: true,
                  //   ),
                  // );
                  //RateUsOnStore(androidPackageName: "com.lcs.jobs", appstoreAppId: "284882215").launch();
                  StoreRedirect.redirect(
                    androidAppId: "com.lcs.jobs",
                    iOSAppId: "6738212345", // numeric App Store ID, not bundle name
                  );
                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.star1,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                    SizedBox(width: width/26),
                    Text("Rate_us".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_outlined,size: 15),
                  ],
                ),
              ),
              SizedBox(height: height/56,),
               Divider(color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
              SizedBox(height: height/56,),
              Text("About",style: urbanistSemiBold.copyWith(fontSize: 16,color: JobColor.textgray)),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                    // Fallback to browser if Play Store app is not available
                    // final webUrl = Uri.parse("https://laxmiconsultancyservices.com/privacy-policy");
                    // await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  FlutterWebBrowser.openWebPage(
                    url: "https://laxmiconsultancyservices.com/privacy-policy",
                    customTabsOptions: const CustomTabsOptions(
                      colorScheme: CustomTabsColorScheme.dark,
                      toolbarColor: Colors.deepPurple,
                      secondaryToolbarColor: Colors.green,
                      navigationBarColor: Colors.amber,
                      shareState: CustomTabsShareState.on,
                      instantAppsEnabled: true,
                      showTitle: true,
                      urlBarHidingEnabled: true,
                    ),
                    safariVCOptions: const SafariViewControllerOptions(
                      barCollapsingEnabled: true,
                      preferredBarTintColor: Colors.green,
                      preferredControlTintColor: Colors.amber,
                      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                      modalPresentationCapturesStatusBarAppearance: true,
                    ),
                  );

                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.security,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                    SizedBox(width: width/26),
                    Text("Privacy_Policy".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_outlined,size: 15),
                  ],
                ),
              ),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                  // Fallback to browser if Play Store app is not available
                  // final webUrl = Uri.parse("https://laxmiconsultancyservices.com/terms_of_services/");
                  // await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  FlutterWebBrowser.openWebPage(
                    url: "https://laxmiconsultancyservices.com/terms_of_services",
                    customTabsOptions: const CustomTabsOptions(
                      colorScheme: CustomTabsColorScheme.dark,
                      toolbarColor: Colors.deepPurple,
                      secondaryToolbarColor: Colors.green,
                      navigationBarColor: Colors.amber,
                      shareState: CustomTabsShareState.on,
                      instantAppsEnabled: true,
                      showTitle: true,
                      urlBarHidingEnabled: true,
                    ),
                    safariVCOptions: const SafariViewControllerOptions(
                      barCollapsingEnabled: true,
                      preferredBarTintColor: Colors.green,
                      preferredControlTintColor: Colors.amber,
                      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                      modalPresentationCapturesStatusBarAppearance: true,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.password,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                    SizedBox(width: width/26),
                    Text("Terms_of_Services".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_outlined,size: 15),
                  ],
                ),
              ),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () async {
                  // Fallback to browser if Play Store app is not available
                  // final webUrl = Uri.parse("https://laxmiconsultancyservices.com/about/");
                  // await launchUrl(webUrl, mode: LaunchMode.externalApplication);
                  FlutterWebBrowser.openWebPage(
                    url: "https://laxmiconsultancyservices.com/about",
                    customTabsOptions: const CustomTabsOptions(
                      colorScheme: CustomTabsColorScheme.dark,
                      toolbarColor: Colors.deepPurple,
                      secondaryToolbarColor: Colors.green,
                      navigationBarColor: Colors.amber,
                      shareState: CustomTabsShareState.on,
                      instantAppsEnabled: true,
                      showTitle: true,
                      urlBarHidingEnabled: true,
                    ),
                    safariVCOptions: const SafariViewControllerOptions(
                      barCollapsingEnabled: true,
                      preferredBarTintColor: Colors.green,
                      preferredControlTintColor: Colors.amber,
                      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
                      modalPresentationCapturesStatusBarAppearance: true,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.infosquare,height: height/30,width: height/30,color: themedata.isdark ? JobColor.white : JobColor.black,),
                    SizedBox(width: width/26),
                    Text("About_us".tr,style: urbanistSemiBold.copyWith(fontSize: 18)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_outlined,size: 15),
                  ],
                ),
              ),
              SizedBox(height: height/56,),
               Divider(color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  _showlogoutbottomsheet();
                },
                child: Row(
                  children: [
                    Image.asset(JobPngimage.logout,height: height/30,width: height/30,color:JobColor.red,),
                    SizedBox(width: width/26),
                    Text("Logout".tr,style: urbanistSemiBold.copyWith(fontSize: 18,color: JobColor.red)),

                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  _showlogoutbottomsheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                    height: height / 3.8,
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
                            "Logout".tr,
                            style: urbanistSemiBold.copyWith(
                              fontSize: 22,color: JobColor.red
                            ),
                          ),
                          SizedBox(
                            height: height / 56,
                          ),
                          const Divider(),
                          SizedBox(
                            height: height / 56,
                          ),
                          Text(
                            "Are_you_sure_you_want_to_log_out".tr,
                            style: urbanistBold.copyWith(
                              fontSize: 18,
                            ),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                              height: height / 36,
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
                                  joblogincontroller.logout();
                                },
                                child: Container(
                                  height: height / 15,
                                  width: width / 2.2,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: JobColor.appcolor,
                                  ),
                                  child: Center(
                                    child: Text("Yes_Logout".tr,
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

    _showbottomsheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  height: height / 4,
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          top: 10,
                          bottom: 10,
                        ),
                        child: Text('selectapplicationlayout'.tr,
                            style: urbanistSemiBold.copyWith(
                              fontSize: 18,
                            )),
                      ),
                      const Divider(),
                      SizedBox(
                        height: height / 26,
                        child: InkWell(
                          highlightColor: JobColor.transparent,
                          splashColor: JobColor.transparent,
                          onTap: () async {
                            await Get.updateLocale(const Locale('en', 'US'));
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ltr'.tr,
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        height: height / 26,
                        child: InkWell(
                          highlightColor: JobColor.transparent,
                          splashColor: JobColor.transparent,
                          onTap: () async {
                            await Get.updateLocale(const Locale('ar', 'ab'));
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'rtl'.tr,
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(),
                      SizedBox(
                        height: height / 26,
                        child: InkWell(
                          highlightColor: JobColor.transparent,
                          splashColor: JobColor.transparent,
                          onTap: () async {
                            Navigator.of(context).pop();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'cancel'.tr,
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

}
