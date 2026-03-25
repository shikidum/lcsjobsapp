import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/utils/job_post_controller.dart';

import '../job_theme/job_themecontroller.dart';
import '../job_widget/jobformheader.dart';
import '../job_widget/formuiwidget.dart';
import 'jobpostpart2screen.dart';

class JobPostScreen extends StatelessWidget {
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
            JobFormHeader(currentStep: 1, fillColor:  JobColor.appcolor.withOpacity(0.3),),
            Text("Job Category", style: urbanistMedium.copyWith(fontSize: 16)),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedCategorySlug.value.isEmpty
                  ? null
                  : controller.selectedCategorySlug.value,
              items: controller.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category['slug'], // internal value
                  child: Text(category['name']!), // UI label
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                controller.selectedCategorySlug.value = value;
                controller.selectedCategoryName.value =
                controller.categories
                    .firstWhere((e) => e['slug'] == value)['name']!;

                controller.fetchRoles(value);
              },
              decoration:
              Formuiwidget.inputDecoration("I want to hire a", themedata),
            )),
            SizedBox(height: height / 36),
            Text("Job Role", style: urbanistMedium.copyWith(fontSize: 16)),
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedRole.value.isEmpty
                  ? null
                  : controller.selectedRole.value,
              items: controller.roles.map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                controller.selectedRole.value = value;
              },
              decoration:
              Formuiwidget.inputDecoration("Select Role", themedata),
            )),
            SizedBox(height: height / 36),

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
            Text("I will pay a monthly salary of ", style: urbanistMedium.copyWith(fontSize: 16)),
            Row(
              children: [
                Expanded(child: Formuiwidget.textField("Min. Salary", themedata, keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],controller: controller.minSalaryController,)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("to", style: urbanistMedium.copyWith(fontSize: 16)),
                ),
                Expanded(child: Formuiwidget.textField("Max Salary", themedata,  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],controller: controller.maxSalaryController,)),
              ],
            ),
            Obx(() => controller.salaryError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.salaryError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            SizedBox(height: height / 36),
            Text("Do you offer bonus in addition to monthly salary?", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 36),
            Obx(() => Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.bonus.value = true,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.bonus.value ? JobColor.appcolor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: JobColor.appcolor),
                      ),
                      alignment: Alignment.center,
                      child: Text("Yes", style: TextStyle(color: controller.bonus.value ? Colors.white : JobColor.appcolor)),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.bonus.value = false,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !controller.bonus.value ? JobColor.appcolor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: JobColor.appcolor),
                      ),
                      alignment: Alignment.center,
                      child: Text("No", style: TextStyle(color: !controller.bonus.value ? Colors.white : JobColor.appcolor)),
                    ),
                  ),
                ),
              ],
            )),
            SizedBox(height: height / 36),
            Obx(() => controller.bonus.value
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Maximum bonus amount", style: urbanistMedium.copyWith(fontSize: 16)),
                SizedBox(height: 8),
                Formuiwidget.textField("Enter bonus amount", themedata,  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],controller: controller.bonusAmountController,),
                Obx(() => controller.bonusError.value.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    controller.bonusError.value,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                )
                    : SizedBox.shrink()),
                SizedBox(height: 16),
                Text("Bonus type", style: urbanistMedium.copyWith(fontSize: 16)),
                SizedBox(height: 8),
                Formuiwidget.textField("Incentive / Referral / Other", themedata,controller: controller.bonusTypeController,),
                SizedBox(height: 24),
              ],
            )
                : SizedBox.shrink(),
            ),
            SizedBox(height: height / 36),
            Text("No. of staff i need", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: 8),
            Formuiwidget.textField("No. of Staff", themedata, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],controller: controller.staffCountController,),
            Obx(() => controller.staffError.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                controller.staffError.value,
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            )
                : SizedBox.shrink()),
            SizedBox(height: height / 20),
            InkWell(
              onTap: () {
                final min = int.tryParse(controller.minSalaryController.text) ?? 0;
                final max = int.tryParse(controller.maxSalaryController.text) ?? 0;
                final bonusAmount = int.tryParse(controller.bonusAmountController.text) ?? 0;
                final bonusType = controller.bonusTypeController.text.trim();
                final staff = int.tryParse(controller.staffCountController.text) ?? 0;

                controller.salaryError.value = '';
                controller.bonusError.value = '';
                controller.staffError.value = '';

                bool hasError = false;

                if (min >= max) {
                  controller.salaryError.value = "Min salary must be less than max salary";
                  hasError = true;
                }

                if (controller.bonus.value && (bonusAmount <= 0 || bonusType.isEmpty)) {
                  controller.bonusError.value = "Please enter valid bonus details";
                  hasError = true;
                }

                if (staff <= 0 ) {
                  controller.staffError.value = "Staff count must be at least 1";
                  hasError = true;
                }
                if (hasError) return;
                controller.saveCurrentStepLocally();
                Get.toNamed('/jobpost2');
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
          ],
        ),
      ),
    );
  }



}
