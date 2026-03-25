import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/main.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import 'job_loginoption.dart';
import 'job_onboarding.dart';

class JobWelcome extends StatefulWidget {
  const JobWelcome({Key? key}) : super(key: key);

  @override
  State<JobWelcome> createState() => _JobWelcomeState();
}

class _JobWelcomeState extends State<JobWelcome> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    goup();
  }

  // goup() async {
  //   var navigator = Navigator.of(context);
  //   bool otpverified = storage.read('otpverified') ?? false;
  //   bool? seen = sharedPref.getBool('seenJobWelcome');
  //   await Future.delayed(const Duration(seconds: 5));
  //   if (seen == null || seen == false) {
  //     navigator.push(MaterialPageRoute(
  //       builder: (context) {
  //         return const JobOnboarding();
  //       },
  //     ));
  //   }
  //   else
  //     {
  //       if(otpverified==false) {
  //         navigator.push(MaterialPageRoute(
  //           builder: (context) {
  //             return const JobLoginoption();
  //           },
  //         ));
  //       }
  //     }
  // }

  goup() async {
    final navigator = Navigator.of(context);
    final storage = GetStorage();

    bool otpVerified = storage.read('otpverified') ?? false;
    bool seenWelcome = sharedPref.getBool('seenJobWelcome') ?? false;
    bool isLoggedIn = storage.read('is_logged_in') ?? false;

    await Future.delayed(const Duration(seconds: 2)); // optional splash delay

    if (!seenWelcome) {
      // First time user, go to onboarding
      await sharedPref.setBool('seenJobWelcome', true);
      Get.offAllNamed("/onboarding");
    } else if (!otpVerified) {
      Get.offAllNamed("/login");
    } else if (isLoggedIn) {
      Get.offAllNamed("/dashboard");
    } else {
    Get.offAllNamed("/register");
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(JobPngimage.bgwelcome,height: height/1,width: width/1,fit: BoxFit.fill,),
          // Positioned(
          //   left: 0,
          //     right: 0,
          //     bottom: 40,
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(horizontal: width/36),
          //       child: Column(
          //         children: [
          //           Text("Welcome_to_Jobee".tr,textAlign: TextAlign.center,style: urbanistBold.copyWith(fontSize: 48,color: JobColor.white),maxLines: 2,overflow: TextOverflow.ellipsis,),
          //           SizedBox(height: height/56,),
          //           Text("The best job finder & job portal app where the best jobs will find you.".tr,textAlign: TextAlign.center,style: urbanistMedium.copyWith(fontSize: 18,color: JobColor.white),maxLines: 2,overflow: TextOverflow.ellipsis,),
          //         ],
          //       ),
          //     )
          // )
        ],
      ),
    );
  }
}
