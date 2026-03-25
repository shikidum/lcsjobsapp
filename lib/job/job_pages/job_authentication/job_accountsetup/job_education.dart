import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import '../../../job_gloabelclass/job_fontstyle.dart';
import '../job_auth_controller/job_onboarding_controller.dart';
import '../../job_theme/job_themecontroller.dart';
import '../../job_widget/formuiwidget.dart';

class JobEducation extends StatefulWidget {
  const JobEducation({Key? key}) : super(key: key);

  @override
  State<JobEducation> createState() => _JobEducationState();
}

class _JobEducationState extends State<JobEducation> {
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
        title: Text("Education".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Educational_Attainment".tr,style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/36,),
              Obx(() => Wrap(
                spacing: 8,
                children: ['Less Than Tenth', 'Tenth', 'Twelfth and Above','Graduate and Above'].map((e) {
                  final isSelected = controller.highestEducation.value == e;
                  return
                    GestureDetector(
                      onTap: () {
                        controller.highestEducation.value = e;

                        // Clear dependent selections safely
                        controller.selectedCourse.value = '';
                        controller.selectedSpecialization.value = '';
                        controller.selectedDegree.value = '';

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
              SizedBox(height: height/36,),
          Obx(() =>controller.highestEducation.value=='Twelfth and Above'?
              Row(
                children: [
                  Flexible(
                    child: Formuiwidget.dropdownField(
                        "Course",
                        themedata,
                        controller.TwelfthCourseOptions,
                        controller.selectedCourse
                    ),
                  ),
                ],
              ) :SizedBox.shrink(),),
              SizedBox(height: height/36,),
          Obx(() =>controller.highestEducation.value=='Twelfth and Above'&& controller.selectedCourse!='Others'?
              Row(
                children: [
                  Flexible(
                    child: Formuiwidget.dropdownField(
                        "Branch / Field of Study",
                        themedata,
                        controller.CourseSpecializatonOptions,
                        controller.selectedSpecialization
                    ),
                  ),
                ],
              ) :SizedBox.shrink(),),
              SizedBox(height: height/36,),
          Obx(() =>controller.highestEducation.value=='Graduate and Above'?
              Obx(() => Row(
                children: [
                  Flexible(
                    child:
              DropdownButtonFormField<String>(
                value: controller.selectedDegree.value == '' ? null : controller.selectedDegree.value,
                decoration: Formuiwidget.inputDecoration("Degree / Course", themedata),
                isDense: true,
                isExpanded: true,
                items: controller.degreeToSpecializations.keys.map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  controller.onDegreeChanged(value!);
                },
              ),
                  ),
                ],
              )):SizedBox.shrink(),),
              SizedBox(height: height/36,),
              Obx(() => controller.highestEducation.value=='Graduate and Above'&&controller.selectedDegree.value != 'Others' &&
                  controller.specializationOptions.isNotEmpty
                  ? Row(
                children: [
                  Flexible(
                    child: Formuiwidget.dropdownField(
                      "Branch / Field of Study",
                      themedata,
                      controller.specializationOptions,
                      controller.selectedSpecialization,
                    ),
                  ),
                ],
              )
                  : SizedBox.shrink()),
              SizedBox(height: height/36,),
          Obx(() =>controller.highestEducation.value=='Graduate and Above'?
              Formuiwidget.textField("Enter College Name", themedata, controller: controller.CollageNameController, )
                  : SizedBox.shrink()),
              SizedBox(height: height/36,),
              Obx(() =>controller.highestEducation.value=='Graduate and Above'?
              Formuiwidget.textField("Enter Passing Year", themedata, controller: controller.PassingyearController, keyboardType: TextInputType.number,)
                  : SizedBox.shrink()),
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
                Get.offNamed('/register');
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
                  controller.save2stStepLocally();
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
