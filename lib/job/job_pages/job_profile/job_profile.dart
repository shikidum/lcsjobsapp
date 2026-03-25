import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_subscription_screen.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_profile_education.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_setting/job_setting.dart';
import 'package:lcsjobs/job/job_pages/job_profile/job_transaction_screen.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../../utils/job_home_controller.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_affiliations.dart';
import 'job_awards.dart';
import 'job_certification.dart';
import 'job_contactinfo.dart';
import 'job_editprofile.dart';
import '../job_authentication/job_accountsetup/job_education.dart';
import 'job_expectedsalary.dart';
import 'job_languages.dart';
import 'job_organizationactivities.dart';
import 'job_professionalexams.dart';
import 'job_projects.dart';
import 'job_references.dart';
import 'job_resume.dart';
import 'job_seminars.dart';
import 'job_skills.dart';
import 'job_summary.dart';
import 'job_volunteeringexperience.dart';
import 'job_workexperience.dart';

class JobProfile extends StatefulWidget {
  const JobProfile({Key? key}) : super(key: key);

  @override
  State<JobProfile> createState() => _JobProfileState();
}

class _JobProfileState extends State<JobProfile> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final controller = Get.put(JobHomeController());
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    var subSta=controller.subscription_status.value=="active"?"Active":"Inactive";
    final storedCity = controller.storage.read("preferred_city");
    final storedLocality = controller.storage.read("preferred_locality");
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(15),
          child: Image.asset(JobPngimage.logo,height: height/36,),
        ),
        title: Text("Profile".tr,style: urbanistBold.copyWith(fontSize: 22 )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobSetting();
                  },));
                },
                child: Image.asset(JobPngimage.setting,height: height/36,color: themedata.isdark? JobColor.white:JobColor.black,)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: controller.UserProfile.value == ''
                        ? AssetImage(JobPngimage.profile) as ImageProvider
                        : NetworkImage(controller.UserProfile.value),
                  ),
                  SizedBox(width: width/26,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height/120,),
                      Text(controller.UserName.value,style: urbanistBold.copyWith(fontSize: 14 )),
                      SizedBox(height: height/120,),
                      Text(controller.UserPhone.value,style: urbanistMedium.copyWith(fontSize: 14)),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    splashColor: JobColor.transparent,
                    highlightColor: JobColor.transparent,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return const JobEditprofile();
                        },));
                      },
                      child: Image.asset(JobPngimage.editicon,height: height/30,color: JobColor.appcolor))
                ],
              ),
              SizedBox(height: height/56,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Center(child: Text("You are Looking Job in "+storedLocality,style: urbanistBold.copyWith(fontSize: 14 ))),
                    ],
                  ),
                ],
              ),
              const Divider(),
              SizedBox(height: height/56,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobSubscriptionScreen();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.star,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Manage Subscription",style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/56,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobTransactionScreen();
                  }));
                },
                child: Container(
                  width: width / 1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: themedata.isdark
                              ? JobColor.borderblack
                              : JobColor.bggray)),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: width / 30, vertical: height / 56),
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long,
                            size: height / 30, color: JobColor.appcolor),
                        SizedBox(width: width / 36),
                        Text("Transactions",
                            style: urbanistBold.copyWith(fontSize: 18)),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: height / 36, color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/56,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobContactInfo();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.profileicon,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Contact_Information".tr,style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobSummary();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.document,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Summary".tr,style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobWorkExperience();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.work,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Work_Experience".tr,style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobProfileEducation();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.paper,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Education".tr,style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              // InkWell(
              //   splashColor: JobColor.transparent,
              //   highlightColor: JobColor.transparent,
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) {
              //       return const JobLanguages();
              //     },));
              //   },
              //   child: Container(
              //     width: width/1,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(24),
              //         border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
              //     ),
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
              //       child: Row(
              //         children: [
              //           Image.asset(JobPngimage.document,height: height/36,color: JobColor.appcolor,),
              //           SizedBox(width: width/36,),
              //           Text("Languages".tr,style: urbanistBold.copyWith(fontSize: 18 )),
              //           const Spacer(),
              //           Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: height/46,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const JobSkills();
                  },));
                },
                child: Container(
                  width: width/1,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
                    child: Row(
                      children: [
                        Image.asset(JobPngimage.graph,height: height/36,color: JobColor.appcolor,),
                        SizedBox(width: width/36,),
                        Text("Skills".tr,style: urbanistBold.copyWith(fontSize: 18 )),
                        const Spacer(),
                        Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              // InkWell(
              //   splashColor: JobColor.transparent,
              //   highlightColor: JobColor.transparent,
              //   onTap: () {
              //     Navigator.push(context, MaterialPageRoute(builder: (context) {
              //       return const JobResume();
              //     },));
              //   },
              //   child: Container(
              //     width: width/1,
              //     decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(24),
              //         border: Border.all(color: themedata.isdark?JobColor.borderblack:JobColor.bggray)
              //     ),
              //     child: Padding(
              //       padding: EdgeInsets.symmetric(horizontal: width/30,vertical: height/56),
              //       child: Row(
              //         children: [
              //           Image.asset(JobPngimage.paper,height: height/36,color: JobColor.appcolor,),
              //           SizedBox(width: width/36,),
              //           Text("CV_Resume".tr,style: urbanistBold.copyWith(fontSize: 18 )),
              //           const Spacer(),
              //           Image.asset(JobPngimage.plus,height: height/30,color: JobColor.appcolor),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // SizedBox(height: height/30,),
            ],
          ),
        ),
      ),
    );
  }
}
