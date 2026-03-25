import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/utils/job_app_settings.dart';

import 'job_welcomescreen.dart';

class JobSplash extends StatefulWidget {
  const JobSplash({Key? key}) : super(key: key);

  @override
  State<JobSplash> createState() => _JobSplashState();
}

class _JobSplashState extends State<JobSplash> {

  final JobAppController controller = Get.put(JobAppController());
  @override
  void initState() {
    super.initState();
    controller.fetchSettings();
    //print("Apply limit :"+controller.freeApplyLimit!.toString());
    goup();
  }

  goup() async {

    var navigator = Navigator.of(context);
    await Future.delayed(const Duration(seconds: 5));
    navigator.push(MaterialPageRoute(
      builder: (context) {
        return const JobWelcome();
      },
    ));
  }

  dynamic size;
  double height = 0.00;
  double width = 0.00;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: Center(
          child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(JobPngimage.splash,height: height/6,fit: BoxFit.fitHeight,),
              Image.asset(JobPngimage.splashlogo,width: width*0.8,fit: BoxFit.fitHeight,),
            ],
          ),
          ),
    );
  }
}
