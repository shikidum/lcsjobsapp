import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_otpverification.dart';
import 'package:lcsjobs/job/job_pages/job_post/jobpostscreen.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_auth_controller/job_login_controller.dart';
import 'job_login.dart';
import 'job_signup.dart';

class JobLoginoption extends StatefulWidget {
  const JobLoginoption({Key? key}) : super(key: key);

  @override
  State<JobLoginoption> createState() => _JobLoginoptionState();
}

class _JobLoginoptionState extends State<JobLoginoption> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobLoginController controller = Get.put(JobLoginController());
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            children: [
              SizedBox(height: height/10,),
              Image.asset(JobPngimage.loginoption,height: height/4.5,fit: BoxFit.fitHeight,),
              SizedBox(height: height/46,),
              Text("Lets_you_in".tr,style: urbanistBold.copyWith(fontSize: 40)),
              SizedBox(height: height/43,),
              Form(
                key: controller.formKey,
                child: TextFormField(
                  controller: controller.phoneController,
                  style: urbanistSemiBold.copyWith(fontSize: 16),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Phone number is required';
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) return 'Enter valid 10-digit mobile number';
                    return null;
                  },
                  decoration: InputDecoration(
                    counterText: "",
                    hintStyle: urbanistRegular.copyWith(fontSize: 16),
                    hintText: "Enter Mobile".tr,
                    fillColor: themedata.isdark ? JobColor.lightblack : JobColor.appgray,
                    filled: true,
                    prefixIcon: Icon(Icons.call, size: height / 46),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: JobColor.appcolor),
                    ),
                  ),
                ),
              ),
              SizedBox(height: height/43,),
              /// 🔘 Sign In With OTP Button
              Obx(() => InkWell(
                onTap: controller.isLoading.value
                    ? null
                    : () {
                  if (controller.formKey.currentState!.validate()) {
                    controller.sendOtp(controller.phoneController.text.trim(), context);
                  }
                },
                child: Container(
                  height: height / 15,
                  width: width,
                  decoration: BoxDecoration(
                    color: controller.isLoading.value ? Colors.grey : JobColor.appcolor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : Text(
                      "Are You Looking For a Job ?",
                      style: urbanistBold.copyWith(fontSize: 16, color: JobColor.white),
                    ),
                  ),
                ),
              )),

              SizedBox(height: height / 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: height / 500,
                      width: width / 2.4,
                      color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
                  SizedBox(width: width / 56),
                  Text(
                    "OR".tr,
                    style: urbanistSemiBold.copyWith(
                        fontSize: 15, color: JobColor.textgray),
                  ),
                  SizedBox(width: width / 78),
                  Container(
                      height: height / 500,
                      width: width / 2.4,
                      color: themedata.isdark?JobColor.borderblack:JobColor.bggray),
                ],
              ),
              SizedBox(height: height/36,),
              SizedBox(height: height/36,),
              Text("Post a Job",style: urbanistBold.copyWith(fontSize: 40)),
              SizedBox(height: height/36,),
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return JobPostScreen();
                    },
                  ));
                },
                child: Container(
                  height: height/15,
                  width: width/1,
                  decoration: BoxDecoration(
                    color: JobColor.appcolor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(child: Text("Are You Looking For Staff ?",style: urbanistBold.copyWith(fontSize: 16,color: JobColor.white),)),
                ),
              ),
              SizedBox(height: height/36,),
            ],
          ),
        ),
      ),
    );
  }
}
