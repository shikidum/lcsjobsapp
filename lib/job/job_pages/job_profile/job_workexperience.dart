import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/job_pages/job_widget/formuiwidget.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';
import '../../utils/job_home_controller.dart';

class JobWorkExperience extends StatefulWidget {
  const JobWorkExperience({Key? key}) : super(key: key);

  @override
  State<JobWorkExperience> createState() => _JobWorkExperienceState();
}

class _JobWorkExperienceState extends State<JobWorkExperience> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final controller = Get.put(JobHomeController());
  bool isDark = true;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Work_Experience".tr,style: urbanistBold.copyWith(fontSize: 22 )),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(13),
        //     child: Image.asset(JobPngimage.delete,height: height/36,),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Wrap(
                spacing: 8,
                children: ['Yes', 'No'].map((e) {
                  final isSelected = controller.selectedexperience.value == e;
                  return
                    GestureDetector(
                      onTap: () {
                        controller.selectedexperience.value = e;
                        controller.specializationOptions.clear();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? JobColor.appcolor : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: JobColor.appcolor),
                        ),
                        alignment: Alignment.center,
                        width: (width-40)/2,
                        child: Text(e, style: TextStyle(color: isSelected ? Colors.white : JobColor.appcolor)),
                      ),
                    );
                }).toList(),
              )),
              Obx(() => controller.SelectExpError.value.isNotEmpty
                  ? Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  controller.SelectExpError.value,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
                  : SizedBox.shrink()),
              SizedBox(height: height/36,),
              Obx(() =>controller.selectedexperience.value=='Yes'?
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height/36,),
                    Text("Total Years of Experience", style: urbanistMedium.copyWith(fontSize: 16)),
                    Row(
                      children: [
                        Flexible(
                          child: Formuiwidget.dropdownField(
                              "Total Years of Experience",
                              themedata,
                              controller.ExpYearsOptions,
                              controller.selectedExperience
                          ),
                        ),
                      ],
                    ),
                    Obx(() => controller.ExperienceError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.ExperienceError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
                    SizedBox(height: height/36,),
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
                      Formuiwidget.inputDecoration("Working In. eg. Accounting, Finance", themedata),
                    )),
                    Obx(() => controller.selectcatError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.selectcatError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
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
                    Obx(() => controller.selectroleError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.selectroleError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
                    SizedBox(height: height / 36),
                    Text("Industry Type(Previously Working) ?", style: urbanistMedium.copyWith(fontSize: 16)),
                    SizedBox(height: height / 36),
                    Formuiwidget.textField("Like -Automobile,Pharma, Electronic etc.", themedata, keyboardType: TextInputType.text, controller: controller.CompanyController,),
                    Obx(() => controller.companynameError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.companynameError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
                    Text("Currently working Here ?",style: urbanistMedium.copyWith(fontSize: 16 )),
                    SizedBox(height: height/36,),
                    Obx(() => Wrap(
                      spacing: 8,
                      children: ['Yes', 'No'].map((e) {
                        final isSelected = controller.selectedworking.value == e;
                        return
                          GestureDetector(
                            onTap: () {
                              controller.selectedworking.value = e;
                              controller.specializationOptions.clear();
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? JobColor.appcolor : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: JobColor.appcolor),
                              ),
                              alignment: Alignment.center,
                              width: (width-40)/2,
                              child: Text(e, style: TextStyle(color: isSelected ? Colors.white : JobColor.appcolor)),
                            ),
                          );
                      }).toList(),
                    )),
                    Obx(() => controller.workingError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.workingError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
                    SizedBox(height: height/36,),
                    Text("Current Monthly Salary", style: urbanistMedium.copyWith(fontSize: 16)),
                    SizedBox(height: height / 36),
                    Formuiwidget.textField("Enter Salary eg.12000", themedata, keyboardType: TextInputType.text, controller: controller.CurrentSalaryController,),
                    Obx(() => controller.salaryError.value.isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        controller.salaryError.value,
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    )
                        : SizedBox.shrink()),
                  ],
                ),
              ) :SizedBox.shrink(),),
            ],
          ),
        ),
      ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
          child: Obx(() => InkWell(
            splashColor: JobColor.transparent,
            highlightColor: JobColor.transparent,
            onTap: controller.isWorkExperienceUpdating.value
                ? null
                : () {
              controller.updateWorkExperience();
            },
            child: Container(
              height: height / 15,
              width: width / 1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: controller.isWorkExperienceUpdating.value
                    ? JobColor.appcolor.withOpacity(0.6)
                    : JobColor.appcolor,
              ),
              child: Center(
                child: controller.isWorkExperienceUpdating.value
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
