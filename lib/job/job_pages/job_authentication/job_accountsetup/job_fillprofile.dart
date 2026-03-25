import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_auth_controller/job_onboarding_controller.dart';
import '../../../job_gloabelclass/job_fontstyle.dart';
import '../../job_theme/job_themecontroller.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../job_widget/formuiwidget.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class JobFillProfile extends StatefulWidget {
  const JobFillProfile({Key? key}) : super(key: key);

  @override
  State<JobFillProfile> createState() => _JobFillProfileState();
}

class _JobFillProfileState extends State<JobFillProfile> {
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
        title: Text("Fill_Your_Profile".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            children: [
              Stack(
                children: [
                  Obx(() {
                    final hasUploadedImage = controller.profilePicUrl.isNotEmpty;
                    final localPicked = controller.pickedImagePath.value;

                    return CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: hasUploadedImage
                          ? NetworkImage(controller.profilePicUrl.value)
                          : localPicked.isNotEmpty
                          ? FileImage(File(localPicked)) as ImageProvider
                          : AssetImage(JobPngimage.profile),
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                        if (picked != null) {
                          final file = File(picked.path);
                          controller.pickedImagePath.value = picked.path;
                          await controller.uploadProfilePic(file);
                        }
                      },
                      child: Container(
                        width: height / 26,
                        height: height / 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: JobColor.appcolor,
                        ),
                        child: controller.isProfilePicUploading.value
                            ? Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.edit_sharp, size: 22, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height/30,),
              Formuiwidget.textField("Enter Full Name", themedata,  keyboardType: TextInputType.text, controller: controller.fullNameController),
              Obx(() => controller.NameError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.NameError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: height/46,),
              Formuiwidget.textField("Enter age", themedata,  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],controller: controller.ageController),
              Obx(() => controller.AgeError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.AgeError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: height/46,),
              Formuiwidget.textField("Email Id (Optional)", themedata,  keyboardType: TextInputType.emailAddress, controller: controller.emailController),
              Obx(() => controller.emailError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.emailError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: height/46,),
              Text("Gender", style: urbanistMedium.copyWith(fontSize: 16)),
              SizedBox(height: height/46,),
              Obx(() => Wrap(
                spacing: 8,
                children: ['Male', 'Female', 'Other'].map((e) {
                  final isSelected = controller.selectedGender.value == e;
                  return
                    ChoiceChip(
                      label: Text(
                        e,
                        style: TextStyle(
                          color: isSelected ? Colors.white : JobColor.appcolor,
                          fontWeight: FontWeight.bold,
                            fontSize: 16
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (_) => controller.selectedGender.value = e,
                      selectedColor: JobColor.appcolor,
                      backgroundColor: Colors.transparent,
                      shape: StadiumBorder(
                        side: BorderSide(color: JobColor.appcolor),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    );

                }).toList(),
              )),
              SizedBox(height: height/46,),
              Obx(() => controller.genderError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.genderError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/56),
        child: InkWell(
          onTap: () {
            final age = int.tryParse(controller.ageController.text) ?? 0;
            final FullName = controller.fullNameController.text.trim();
            final email=controller.emailController.text.trim();
            controller.NameError.value = '';
            controller.AgeError.value = '';
            controller.genderError.value = '';
            controller.emailError.value = '';
            bool hasError = false;

            if (FullName.isEmpty || FullName.length<3) {
              controller.NameError.value = "Please enter valid Name to Continue.";
              hasError = true;
            }
            if (age <= 18) {
              controller.AgeError.value = "Are you not over 18 Years ? Please check your age !";
              hasError = true;
            }



            if (email.isNotEmpty) {
              bool isValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
              if (!isValid) {
                controller.emailError.value = "Please enter a valid email";
                hasError = true;
              }
            }

            if (controller.selectedGender.isEmpty) {
              controller.genderError.value = "Please select a gender";
              hasError = true;
            }

            if (hasError) return;
            controller.save1stStepLocally();
            Get.offNamed('/register2');
          },
          child: Container(
            width: width,
            height: height / 15,
            decoration: BoxDecoration(
              color: JobColor.appcolor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Center(
              child: Text("Next", style: urbanistSemiBold.copyWith(color: Colors.white)),
            ),
          ),
        )
      ),
    );
  }
}
