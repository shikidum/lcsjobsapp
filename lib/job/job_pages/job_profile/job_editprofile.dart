import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_widget/formuiwidget.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';

import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';

class JobEditprofile extends StatefulWidget {
  const JobEditprofile({Key? key}) : super(key: key);

  @override
  State<JobEditprofile> createState() => _JobEditprofileState();
}

class _JobEditprofileState extends State<JobEditprofile> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final controller = Get.put(JobHomeController());
  final storage = GetStorage(); // 🔐 local storage
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    final storedCity = storage.read("preferred_city");
    final preferredCity = (storedCity ?? "").toString().trim().toLowerCase();
    final storedLocality = storage.read("preferred_locality");
    final preferredLocality = (storedLocality ?? "").toString().trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child:  Stack(
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
              ),
              SizedBox(height: height/30,),
              Text("Full_name".tr,style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/66,),
              TextField(
                style: urbanistSemiBold.copyWith(fontSize: 16),
                controller: controller.fullNameController,
                decoration: InputDecoration(
                  hintStyle: urbanistRegular.copyWith(fontSize: 16,color:JobColor.textgray,),
                  hintText: "Full_name".tr,
                 fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                  filled: true,
                  //  prefixIcon:Icon(Icons.search_rounded,size: height/36,color: JobColor.textgray,),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: JobColor.appcolor)
                  ),
                ),
              ),
              SizedBox(height: height/66,),
              Text("Gender", style: urbanistMedium.copyWith(fontSize: 16)),
              SizedBox(height: height/66,),
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
              SizedBox(height: height/66,),
              Obx(() => controller.genderError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.genderError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: height / 36),
              Text("Prefered Location", style: urbanistMedium.copyWith(fontSize: 16)),
              Text("City", style: urbanistMedium.copyWith(fontSize: 16)),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.cities.any((c) => c['slug'] == preferredCity)
                    ? preferredCity
                    : null,
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
                value: controller.localities.contains(preferredLocality)
                    ? preferredLocality
                    : null,
                items: controller.localities.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  controller.selectedLocality.value = value!;
                },
                decoration: Formuiwidget.inputDecoration("Select Locality", themedata),
              )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
        child: Obx(() => InkWell(
          splashColor: JobColor.transparent,
          highlightColor: JobColor.transparent,
          onTap: controller.isProfileUpdating.value
              ? null
              : () {
            controller.updateBasicProfile();
          },
          child: Container(
            height: height / 15,
            width: width / 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: controller.isProfileUpdating.value
                  ? JobColor.appcolor.withOpacity(0.6)
                  : JobColor.appcolor,
            ),
            child: Center(
              child: controller.isProfileUpdating.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                "Save".tr,
                style: urbanistSemiBold.copyWith(
                  fontSize: 16,
                  color: JobColor.white,
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
