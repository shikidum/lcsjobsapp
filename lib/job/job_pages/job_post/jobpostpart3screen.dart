import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_post/jobpostpart2screen.dart';
import 'package:lcsjobs/job/utils/job_post_controller.dart';


import '../job_theme/job_themecontroller.dart';
import '../job_widget/formuiwidget.dart';
import '../job_widget/jobformheader.dart';
import 'jobpostscreen.dart';

class JobPostPart3Screen extends StatelessWidget {
  final controller = Get.put(JobPostController());
  final themedata = Get.put(JobThemecontroler());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text("Post Job".tr, style: urbanistBold.copyWith(fontSize: 22)),
        backgroundColor: themedata.isdark ? JobColor.black : JobColor.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width / 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobFormHeader(currentStep: 3, fillColor:  JobColor.appcolor.withOpacity(0.3),),
            //// Company Name
            SizedBox(height: height / 26),
            Text("Name of My Company", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Formuiwidget.textField("Company Name", themedata, keyboardType: TextInputType.text, controller: controller.CompanyController,),
            Obx(() => controller.companyNameError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.companyNameError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            //// Contact Person
            SizedBox(height: height / 26),
            Text("Contact Person/ Recruiter Name", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Formuiwidget.textField("Recruiter Name", themedata, keyboardType: TextInputType.text,
              controller: controller.ContactPersonController,),
            Obx(() => controller.contactPersonError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.contactPersonError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            //// Email Id
            SizedBox(height: height / 26),
            Text("Email Id", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Formuiwidget.textField("Email Id", themedata, keyboardType: TextInputType.text,
              controller: controller.EmailIdController,),
            Obx(() => controller.EmailIdError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.EmailIdError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            //// Phone Number
            SizedBox(height: height / 26),
            Text("Phone Number", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Formuiwidget.textField("Phone Number", themedata, keyboardType: TextInputType.text,
              controller: controller.PhoneNoController,),
            Obx(() => controller.PhoneNoError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.PhoneNoError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            //// Company Address
            SizedBox(height: height / 26),
            Text("My Company Address", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Formuiwidget.textField("My Company Address", themedata, keyboardType: TextInputType.text,
              controller: controller.CompanyAddressController,lines: 3),
            Obx(() => controller.CompanyAddressError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.CompanyAddressError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            SizedBox(height: height / 26),
            Text("How Often do you have a new job category?", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Obx(() => Wrap(
              spacing: 10,
              children: controller.JobRepeatOptions.map((e) {
                final isSelected = controller.JopRepeat.value == e;
                return ChoiceChip(
                  label: Text(
                    e,
                    style: TextStyle(
                      color: isSelected ? Colors.white : JobColor.appcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.JopRepeat.value = e,
                  selectedColor: JobColor.appcolor,
                  backgroundColor: Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(color: JobColor.appcolor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                );
              }).toList(),
            )),
            SizedBox(height: height / 26),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  color: JobColor.appcolor,
                  borderRadius: BorderRadius.circular(8), // optional: for rounded corners
                ),
                child: Text("Asking job seeker for any kind of payment is strictly prohibited.", style: urbanistMedium.copyWith(fontSize: 16, color: Colors.white,))),
            SizedBox(height: height / 26),
          Obx(() {
            return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    // Back Button
    Formuiwidget.navigationButton(Icons.arrow_back, () {
    controller.currentStep.value = 1;
    Get.toNamed('/jobpost2');
    }),

    // Submit Job Button
    InkWell(
      onTap: controller.isSubmitting.value
          ? null
          : () async {
        controller.isSubmitting.value = true;
        // Send OTP first
        await controller.sendOtpToPhone(controller.PhoneNoController.text.trim());
        // Show OTP Dialog
        Get.dialog(
          AlertDialog(
            title: Text("OTP Verification"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Enter the 6-digit OTP sent to your number"),
                SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (val) => controller.enteredOtp.value = val,
                  decoration: InputDecoration(hintText: "Enter OTP"),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("Verify"),
                  onPressed: () async {
                    bool isValid = await controller.verifyOtp(controller.enteredOtp.value);
                    if (isValid) {
                      Get.back(); // Close dialog
                      await controller.submitJobPost();
                    } else {
                      Get.snackbar("Invalid OTP", "Please try again");
                    }
                    controller.isSubmitting.value = false;
                  },
              ),
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Get.back();
                  controller.isSubmitting.value = false;
                },
              ),
            ],
          ),
        );
      },

      child: Container(
    width: width / 2,
    height: height / 15,
    decoration: BoxDecoration(
    color: controller.isSubmitting.value
    ? Colors.grey
        : JobColor.appcolor,
    borderRadius: BorderRadius.circular(50),
    ),
    child: Center(
    child: controller.isSubmitting.value
    ? const CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    )
        : Text(
    "Submit Job",
    style:
    urbanistSemiBold.copyWith(color: Colors.white),
    ),
    ),
    ),
    ),
    //   InkWell(
    //     onTap: controller.isSubmitting.value
    //         ? null
    //         : () async {
    //       controller.isSubmitting.value = true;
    //       // Send OTP first
    //       await controller.sendOtpToPhone(controller.PhoneNoController.text.trim());
    //       // Show OTP Dialog
    //       Get.dialog(
    //         AlertDialog(
    //           title: Text("OTP Verification"),
    //           content: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Text("Enter the 6-digit OTP sent to your number"),
    //               SizedBox(height: 10),
    //               TextField(
    //                 keyboardType: TextInputType.number,
    //                 maxLength: 6,
    //                 onChanged: (val) => controller.enteredOtp.value = val,
    //                 decoration: InputDecoration(hintText: "Enter OTP"),
    //               ),
    //             ],
    //           ),
    //           actions: [
    //             TextButton(
    //               child: Text("Verify"),
    //               onPressed: () async {
    //                 bool isValid = await controller.verifyOtp(controller.enteredOtp.value);
    //                 if (isValid) {
    //                   Get.back(); // Close dialog
    //                   await controller.submitJobPost();
    //                 } else {
    //                   Get.snackbar("Invalid OTP", "Please try again");
    //                 }
    //                 controller.isSubmitting.value = false;
    //               },
    //             ),
    //             TextButton(
    //               child: Text("Cancel"),
    //               onPressed: () {
    //                 Get.back();
    //                 controller.isSubmitting.value = false;
    //               },
    //             ),
    //           ],
    //         ),
    //       );
    //     },
    //     // ...
    //   ),

    ],
    );
           })
          ],
    ),
      ),
    );
  }



}