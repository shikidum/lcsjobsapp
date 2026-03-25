import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import '../../../job_gloabelclass/job_fontstyle.dart';
import '../job_auth_controller/job_onboarding_controller.dart';
import '../../job_theme/job_themecontroller.dart';
import '../../job_widget/formuiwidget.dart';

class JobExperience extends StatefulWidget {
  const JobExperience({Key? key}) : super(key: key);

  @override
  State<JobExperience> createState() => _JobExperienceState();
}

class _JobExperienceState extends State<JobExperience> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobOnboardingController controller = Get.put(JobOnboardingController());
  bool isDark = true;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Experience".tr,style: urbanistBold.copyWith(fontSize: 22 )),
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
              Text("Do you have any work experience ?",style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/36,),
              Obx(() => Wrap(
                spacing: 8,
                children: ['Yes', 'No'].map((e) {
                  final isSelected = controller.selectedexperience.value == e;
                  return
                    GestureDetector(
                      onTap: () {
                        controller.selectedexperience.value = e;
                        // Clear dependent selections safely
                        // controller.selectedCourse.value = '';
                        // controller.selectedSpecialization.value = '';
                        // controller.selectedDegree.value = '';
                        // Optional: clear specializationOptions
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
                    Text("Industry Type(Previously Working) ?", style: urbanistMedium.copyWith(fontSize: 12)),
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
                              // Clear dependent selections safely
                              // controller.selectedCourse.value = '';
                              // controller.selectedSpecialization.value = '';
                              // controller.selectedDegree.value = '';

                              // Optional: clear specializationOptions
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
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/56),
          child: Row(
            children: [
              Flexible(
                child:InkWell(
                  splashColor:JobColor.transparent,
                  highlightColor:JobColor.transparent,
                  onTap: () {
                    Get.offNamed('/register2');
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
                  onTap: () {
                    bool isValid = true;

                    // Reset all error messages
                    controller.SelectExpError.value = '';
                    controller.ExperienceError.value = '';
                    controller.selectcatError.value = '';
                    controller.selectroleError.value = '';
                    controller.companynameError.value = '';
                    controller.workingError.value = '';
                    controller.salaryError.value = '';

                    // Validate experience selection
                    if (controller.selectedexperience.value.isEmpty) {
                      controller.SelectExpError.value = "Please select your work experience status";
                      isValid = false;
                    }

                    // If "Yes", validate all fields
                    if (controller.selectedexperience.value == 'Yes') {
                      if (controller.selectedExperience.value.isEmpty) {
                        controller.ExperienceError.value = "Please select total years of experience";
                        isValid = false;
                      }

                      if (controller.selectedCategoryName.value.isEmpty) {
                        controller.selectcatError.value = "Please select a job category";
                        isValid = false;
                      }

                      if (controller.selectedRole.value.isEmpty) {
                        controller.selectroleError.value = "Please select a job role";
                        isValid = false;
                      }

                      if (controller.CompanyController.text.trim().isEmpty) {
                        controller.companynameError.value = "Please enter your Industry Name";
                        isValid = false;
                      }

                      if (controller.selectedworking.value.isEmpty) {
                        controller.workingError.value = "Please select your current work status";
                        isValid = false;
                      }

                      if (controller.CurrentSalaryController.text.trim().isEmpty) {
                        controller.salaryError.value = "Please enter your current salary";
                        isValid = false;
                      }
                    }
                    else
                      {
                        controller.selectedExperience.value="Fresher";
                      }
                    // If all valid, proceed
                    if (isValid) {
                      controller.save3rdStepLocally();
                      Get.offNamed('/register4');
                    }
                  },
                  child: Container(
                    height: height/15,
                    width: width/2,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color:JobColor.appcolor,
                    ),
                    child: Center(
                      child: Text("Next",style: urbanistSemiBold.copyWith(fontSize: 16,color:JobColor.white)),
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
