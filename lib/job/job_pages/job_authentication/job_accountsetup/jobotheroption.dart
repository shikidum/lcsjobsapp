import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_auth_controller/job_onboarding_controller.dart';
import 'package:lcsjobs/job/job_pages/job_theme/job_themecontroller.dart';

import '../../job_widget/formuiwidget.dart';


class JobOtherOptions extends StatefulWidget {
  const JobOtherOptions({Key? key}) : super(key: key);

  @override
  State<JobOtherOptions> createState() => _JobOtherOptionsState();
}

class _JobOtherOptionsState extends State<JobOtherOptions> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobOnboardingController controller = Get.put(JobOnboardingController());
  @override
Widget build(BuildContext context) {
  size = MediaQuery.of(context).size;
  height = size.height;
  width = size.width;
  return Scaffold(
    appBar: AppBar(
      title: Text("Other Preferences".tr,style: urbanistBold.copyWith(fontSize: 22 )),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
        child: Column(
          children: [
           // JobFormHeader(currentStep: 3, fillColor:  JobColor.appcolor.withOpacity(0.3),),
            //// Company Name
            SizedBox(height: height / 36),
            Text("Prefered Location", style: urbanistMedium.copyWith(fontSize: 16)),
            Text("City", style: urbanistMedium.copyWith(fontSize: 16)),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCity.value.isEmpty
                  ? null
                  : controller.selectedCity.value,

              items: controller.cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city['slug'],      // 🔥 slug stored
                  child: Text(city['name']!), // 🔥 name shown
                );
              }).toList(),
              onChanged: (value) {
                controller.selectedCity.value = value!;
                controller.fetchLocalities(value); // value = slug
              },
              decoration: Formuiwidget.inputDecoration(
                  "Select City", themedata),
            )),
            SizedBox(height: height / 36),
            Text("Locality", style: urbanistMedium.copyWith(fontSize: 16)),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedLocality.value == '' ? null : controller.selectedLocality.value,
              items: controller.localities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) {
                controller.selectedLocality.value = value!;
              },
              decoration: Formuiwidget.inputDecoration("Select Locality", themedata),
            )),
            SizedBox(height: height / 36),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Assets * (Optional)", style: urbanistMedium.copyWith(fontSize: 16)),
                  SizedBox(height: 8),
                  /// Selected assets
                  Wrap(
                    spacing: 8,
                    children: controller.selectedAssets.map((asset) {
                      return Chip(
                        avatar: Icon(Icons.star_border, color: JobColor.appcolor, size: 16),
                        label: Text(asset, style: TextStyle(color: JobColor.appcolor)),
                        shape: StadiumBorder(side: BorderSide(color: JobColor.appcolor)),
                        backgroundColor: Colors.white,
                        deleteIcon: Icon(Icons.close, size: 16, color: JobColor.appcolor),
                        onDeleted: () => controller.selectedAssets.remove(asset),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                  /// Suggested skills
                  Wrap(
                    spacing: 8,
                    children: controller.allAssets.map((e) {
                      return ActionChip(
                        label: Text(e),
                        onPressed: () => controller.addAssets(e),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            SizedBox(height: height / 36),
            Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Languages *(Optional)", style: urbanistMedium.copyWith(fontSize: 16)),
                  SizedBox(height: 8),
                  /// Selected languages
                  Wrap(
                    spacing: 8,
                    children: controller.selectedLanguages.map((language) {
                      return Chip(
                        avatar: Icon(Icons.star_border, color: JobColor.appcolor, size: 16),
                        label: Text(language, style: TextStyle(color: JobColor.appcolor)),
                        shape: StadiumBorder(side: BorderSide(color: JobColor.appcolor)),
                        backgroundColor: Colors.white,
                        deleteIcon: Icon(Icons.close, size: 16, color: JobColor.appcolor),
                        onDeleted: () => controller.selectedLanguages.remove(language),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),
                  /// Suggested skills
                  Wrap(
                    spacing: 8,
                    children: controller.allLanguages.map((e) {
                      return ActionChip(
                        label: Text(e),
                        onPressed: () => controller.addLanguages(e),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
            // Obx(() {
            //   return Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       SizedBox(height: height / 36),
            //       Text("Upload Resume", style: urbanistMedium.copyWith(fontSize: 16)),
            //       SizedBox(height: 12),
            //       if (!controller.isResumeSkipped.value)
            //         GestureDetector(
            //           onTap: () async {
            //             FilePickerResult? result = await FilePicker.platform.pickFiles(
            //               type: FileType.custom,
            //               allowedExtensions: ['pdf', 'docx'],
            //             );
            //             if (result != null) {
            //               File file = File(result.files.single.path!);
            //               controller.resumePath.value = result.files.single.name;
            //               await controller.uploadResumeToFirebase(file);
            //             }
            //           },
            //           child: Container(
            //             width: width,
            //             padding: EdgeInsets.all(14),
            //             decoration: BoxDecoration(
            //               color: themedata.isdark ? JobColor.lightblack : JobColor.appgray,
            //               borderRadius: BorderRadius.circular(16),
            //               border: Border.all(color: JobColor.appcolor.withOpacity(0.6)),
            //             ),
            //             child: Row(
            //               children: [
            //                 Icon(Icons.upload_file, color: JobColor.appcolor),
            //                 SizedBox(width: 12),
            //                 Expanded(
            //                   child: Obx(() => controller.isUploading.value
            //                       ? Row(
            //                     children: [
            //                       SizedBox(
            //                         height: 16,
            //                         width: 16,
            //                         child: CircularProgressIndicator(
            //                           strokeWidth: 2,
            //                           valueColor: AlwaysStoppedAnimation(JobColor.appcolor),
            //                         ),
            //                       ),
            //                       SizedBox(width: 8),
            //                       Text("Uploading...", style: TextStyle(color: JobColor.textgray)),
            //                     ],
            //                   )
            //                       : Text(
            //                     controller.resumePath.value.isEmpty
            //                         ? "Tap to upload .pdf or .docx"
            //                         : controller.resumePath.value,
            //                     style: urbanistSemiBold.copyWith(fontSize: 14, color: JobColor.textgray),
            //                     overflow: TextOverflow.ellipsis,
            //                   )),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //
            //       SizedBox(height: 12),
            //
            //       Align(
            //         alignment: Alignment.centerRight,
            //         child: TextButton(
            //           onPressed: () {
            //             controller.isResumeSkipped.value = true;
            //             controller.resumePath.value = '';
            //             controller.resumeDownloadUrl.value = '';
            //           },
            //           child: Text(
            //             controller.isResumeSkipped.value ? "Resume Skipped" : "Skip Resume",
            //             style: TextStyle(
            //               color: controller.isResumeSkipped.value ? Colors.red : JobColor.appcolor,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   );
            // }),
          ],
        ),
      ),
    ),

    bottomNavigationBar: Padding(
      padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/56),
      child: Row(
        children: [
          Flexible(
            child:InkWell(
              splashColor:JobColor.transparent,
              highlightColor:JobColor.transparent,
              onTap: () {
                Get.offNamed('/register4');
              },
              child: Container(
                height: height/15,
                width: width/2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:JobColor.appcolor,
                ),
                child: Center(
                  child: Text("Back",style: urbanistSemiBold.copyWith(fontSize: 16,color:JobColor.white)),
                ),
              ),
            ),),
          Flexible(
            child: InkWell(
              splashColor:JobColor.transparent,
              highlightColor:JobColor.transparent,
              onTap: () async {
                bool hasError = false;
                // Validate preferred city (required)
                if (controller.selectedCity.value.isEmpty) {
                  Get.snackbar("Missing Field", "Please select your preferred city",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent,
                    colorText: Colors.white,
                  );
                  hasError = true;
                }
                if (hasError) return;
                controller.save5thStepLocally();
                await controller.SubmitProfile();
              },
              child: Container(
                height: height/15,
                width: width/2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color:JobColor.appcolor,
                ),
                child: Center(
                  child: Text("Submit Profile",style: urbanistSemiBold.copyWith(fontSize: 16,color:JobColor.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
