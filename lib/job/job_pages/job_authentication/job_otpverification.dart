import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';
import 'job_auth_controller/job_login_controller.dart';
import 'job_createpassword.dart';

class JobOtpverification extends StatefulWidget {
  const JobOtpverification({Key? key}) : super(key: key);

  @override
  State<JobOtpverification> createState() => _JobOtpverificationState();
}

class _JobOtpverificationState extends State<JobOtpverification> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobLoginController controller = Get.find<JobLoginController>();
  final TextEditingController otp1Controller = TextEditingController();
  final TextEditingController otp2Controller = TextEditingController();
  final TextEditingController otp3Controller = TextEditingController();
  final TextEditingController otp4Controller = TextEditingController();
  final TextEditingController otp5Controller = TextEditingController();
  final TextEditingController otp6Controller = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    startTimer();
  }
  bool isresend=false;
  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 2);
  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }
  void setCountDown() {
    const reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        isresend = true;
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }
// 🔹 NEW: reset + restart
  void resetTimer() {
    countdownTimer?.cancel();
    setState(() {
      myDuration = const Duration(minutes: 2);
      isresend = false;
    });
    startTimer();
  }
  @override
  void dispose() {
    otp1Controller.dispose();
    otp2Controller.dispose();
    otp3Controller.dispose();
    otp4Controller.dispose();
    otp5Controller.dispose();
    otp6Controller.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(2));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP_Code_Verification".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height/5,),
            Text("Code has been send to "+controller.phoneNumber.value,style: urbanistMedium.copyWith(fontSize: 16,)),
            SizedBox(height: height/16,),
            Form(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp1Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                       fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp2Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                       fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp3Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                       fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp4Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                       fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp5Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height/16,
                    width: height/16,
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 1){
                          FocusScope.of(context).nextFocus();
                        }
                      },
                      onSaved: (pin1){},
                      controller: otp6Controller,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(color: JobColor.appcolor)
                        ),
                        fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                        filled: true,
                      ),
                      style: urbanistSemiBold.copyWith(fontSize: 16),
                      cursorColor: JobColor.textgray,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height/36),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("Resend_code_in".tr,style: urbanistRegular.copyWith(fontSize: 16)),
            //     SizedBox(width: width/96),
            //     Text("${minutes.toString()}:${seconds.toString()}s".tr,style: urbanistMedium.copyWith(fontSize: 16,color: JobColor.appcolor)),
            //   ],
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isresend) ...[
                  Text(
                    "Resend_code_in".tr,
                    style: urbanistRegular.copyWith(fontSize: 16),
                  ),
                  SizedBox(width: width / 96),
                  Text(
                    "$minutes:$seconds",
                    style: urbanistMedium.copyWith(
                      fontSize: 16,
                      color: JobColor.appcolor,
                    ),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                      // 🔹 resend OTP to same number
                      final number = controller.phoneNumber.value;
                      if (number.isNotEmpty) {
                        controller.sendOtp(number, context);
                        resetTimer();  // 🔹 restart 2-minute countdown
                      } else {
                        Get.snackbar(
                          "Error",
                          "Phone number not found. Please go back and try again.",
                        );
                      }
                    },
                    child: Text(
                      "Resend OTP",
                      style: urbanistMedium.copyWith(
                        fontSize: 16,
                        color: JobColor.appcolor,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const Spacer(),
            Obx(() => InkWell(
              onTap: controller.isLoading.value
                  ? null
                  : () {
                final enteredOtp = otp1Controller.text +
                    otp2Controller.text +
                    otp3Controller.text +
                    otp4Controller.text +
                    otp5Controller.text +
                    otp6Controller.text;

                if (enteredOtp.length == 6) {
                  controller.verifyOtp(enteredOtp, context);
                } else {
                  Get.snackbar("Error", "Please enter all 6 digits of the OTP");
                }
              },
              child:
              Container(
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
                      "Verify".tr,
                    style: urbanistBold.copyWith(fontSize: 16, color: JobColor.white),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
