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

class JobEditJobCategry extends StatefulWidget {
  const JobEditJobCategry({Key? key}) : super(key: key);

  @override
  State<JobEditJobCategry> createState() => _JobEditJobCategryState();
}

class _JobEditJobCategryState extends State<JobEditJobCategry> {
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
    final storedCatge = storage.read("desired_category");
    final preferredCategory = (storedCatge ?? "").toString().trim().toLowerCase();
    final storedRole = storage.read("desired_role");
    final preferredRole = (storedRole ?? "").toString().trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(
        title: Text("Desired Category and Role".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height / 36),
              Text("Prefered Job Category", style: urbanistMedium.copyWith(fontSize: 16)),
              Text("Categories", style: urbanistMedium.copyWith(fontSize: 16)),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCategoryName.value.isNotEmpty &&
                  controller.categories.any(
                          (c) => c['name'] == controller.selectedCategoryName.value)
                  ? controller.selectedCategoryName.value
                  : preferredCategory.isNotEmpty &&
                  controller.categories.any(
                          (c) => c['name'] == preferredCategory)
                  ? preferredCategory
                  : null,
              items: controller.categories.map((cat) {
                return DropdownMenuItem<String>(
                  value: cat['name'],  // ✅ use name as value
                  child: Text(cat['name']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                controller.selectedCategoryName.value = value;
                // 🔥 If you still need slug for API
                final selected = controller.categories
                    .firstWhere((c) => c['name'] == value);
                controller.selectedCategorySlug.value = selected['slug']!;
                controller.fetchRoles(selected['slug']!);
              },
              decoration:
              Formuiwidget.inputDecoration("Select Category", themedata),
            )),
              SizedBox(height: height / 36),
              Text("Roles", style: urbanistMedium.copyWith(fontSize: 16)),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedRole.value.isNotEmpty &&
                    controller.roles.contains(controller.selectedRole.value)
                    ? controller.selectedRole.value
                    : controller.roles.contains(preferredRole)
                    ? preferredRole
                    : null,
                items: controller.roles.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (value) {
                  controller.selectedRole.value = value!;
                },
                decoration: Formuiwidget.inputDecoration("Select role", themedata),
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
            controller.updateJobCategory();
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
