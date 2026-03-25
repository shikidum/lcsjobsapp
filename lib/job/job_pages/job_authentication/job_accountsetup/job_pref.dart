import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import '../../../job_gloabelclass/job_fontstyle.dart';
import '../job_auth_controller/job_onboarding_controller.dart';
import '../../job_theme/job_themecontroller.dart';
import '../../job_widget/formuiwidget.dart';

class JobPreferences extends StatefulWidget {
  const JobPreferences({Key? key}) : super(key: key);

  @override
  State<JobPreferences> createState() => _JobPreferencesState();
}

class _JobPreferencesState extends State<JobPreferences> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final JobOnboardingController controller = Get.put(JobOnboardingController());
  bool isDark = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller.fetchRoles(controller.selectedCategorySlug.value);
    controller.selectedDesiredRole.value=controller.selectedRole.value;
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Preferences".tr,style: urbanistBold.copyWith(fontSize: 22 )),
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
              Text("Add more details about your role",style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/36,),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Desired Job Category", style: urbanistMedium.copyWith(fontSize: 16)),
                    Obx(() => DropdownButtonFormField<String>(
                      items: controller.categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['slug'], // internal value
                          child: Text(category['name']!), // UI label
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.selectedDesiredCategorySlug.value = value;
                        controller.selectedDesiredCategoryName.value =
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
                    Text("Job Role you looking for", style: urbanistMedium.copyWith(fontSize: 16)),
                    Obx(() => DropdownButtonFormField<String>(
                      items: controller.roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        controller.selectedDesiredRole.value = value;
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
                    Obx(() {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Skills *", style: urbanistMedium.copyWith(fontSize: 16)),
                          SizedBox(height: 8),
                          /// Selected skills
                          Wrap(
                            spacing: 8,
                            children: controller.selectedSkills.map((skill) {
                              return Chip(
                                avatar: Icon(Icons.star_border, color: JobColor.appcolor, size: 16),
                                label: Text(skill, style: TextStyle(color: JobColor.appcolor)),
                                shape: StadiumBorder(side: BorderSide(color: JobColor.appcolor)),
                                backgroundColor: Colors.white,
                                deleteIcon: Icon(Icons.close, size: 16, color: JobColor.appcolor),
                                onDeleted: () => controller.selectedSkills.remove(skill),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 12),
                          /// Search field
                          TextField(
                            controller: controller.skillsSearchController,
                            onChanged: controller.filterSkills,
                            decoration: InputDecoration(
                              hintText: "Type to search for skills",
                              filled: true,
                              fillColor: themedata.isdark ? JobColor.lightblack : JobColor.appgray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),

                          /// Dropdown list (filtered + add option)
                          if (controller.filteredSkills.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: controller.filteredSkills.map((skill) {
                                  final isAddOption = skill.startsWith("Add + ");
                                  final actualSkill = isAddOption ? skill.replaceFirst("Add + ", "") : skill;

                                  return ListTile(
                                    leading: isAddOption
                                        ? Icon(Icons.add, color: JobColor.appcolor)
                                        : Icon(Icons.star_border, color: JobColor.appcolor),
                                    title: Text(
                                      actualSkill,
                                      style: TextStyle(
                                        fontWeight: isAddOption ? FontWeight.bold : FontWeight.normal,
                                        color: isAddOption ? JobColor.appcolor : Colors.black,
                                      ),
                                    ),
                                    onTap: () => controller.addSkill(actualSkill),
                                  );
                                }).toList(),
                              ),
                            ),
                          SizedBox(height: 12),
                          /// Suggested skills
                          Wrap(
                            spacing: 8,
                            children: controller.suggestedSkills.map((e) {
                              return ActionChip(
                                label: Text(e),
                                onPressed: () => controller.addSkill(e),
                              );
                            }).toList(),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              )
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
                    Get.offNamed('/register3');
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
                    bool hasError = false;
                    // Validate job category
                    if (controller.selectedDesiredCategoryName.value.isEmpty) {
                      controller.selectcatError.value = "Please select a job category";
                      hasError = true;
                    } else {
                      controller.selectcatError.value = '';
                    }

                    // Validate job role
                    if (controller.selectedDesiredRole.value.isEmpty) {
                      controller.selectroleError.value = "Please select a job role";
                      hasError = true;
                    } else {
                      controller.selectroleError.value = '';
                    }

                    // Validate at least 1 skill
                    if (controller.selectedSkills.isEmpty) {
                      Get.snackbar("Skills Missing", "Please select at least one skill",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                      hasError = true;
                    }

                    if (hasError) return;
                    controller.save4thStepLocally();
                    Get.offNamed('/register5');
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
