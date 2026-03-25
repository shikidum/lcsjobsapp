import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/utils/job_post_controller.dart';


import '../job_theme/job_themecontroller.dart';
import '../job_widget/formuiwidget.dart';
import '../job_widget/jobformheader.dart';
import 'jobpostpart3screen.dart';
import 'jobpostscreen.dart';

class JobPostPart2Screen extends StatelessWidget {
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
            JobFormHeader(currentStep: 2, fillColor:  JobColor.appcolor.withOpacity(0.3),),
            SizedBox(height: height / 26),
            Text("Total Experience of Candidate", style: urbanistMedium.copyWith(fontSize: 16)),
            SizedBox(height: height / 26),
            Obx(() => Wrap(
              spacing: 10,
              children: ['Any', 'Freshers Only', 'Experienced Only'].map((e) {
                final isSelected = controller.experienceType.value == e;
                return ChoiceChip(
                  label: Text(
                    e,
                    style: TextStyle(
                      color: isSelected ? Colors.white : JobColor.appcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => controller.experienceType.value = e,
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
            Row(
              children: [
                Flexible(
                  child: Formuiwidget.dropdownField(
                      "Min Exp.",
                      themedata,
                      controller.minExperienceOptions,
                      controller.selectedMinExp
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Formuiwidget.dropdownField(
                      "Max Exp.",
                      themedata,
                      controller.maxExperienceOptions,
                      controller.selectedMaxExp
                  ),
                ),
              ],
            ),

            SizedBox(height: height / 26),
        Text("Candidate's Minimum Qualification", style: urbanistMedium.copyWith(fontSize: 16)),
        SizedBox(height: height / 26),
        Obx(() => Wrap(
        spacing: 8,
        children: controller.qualificationOptions.map((e) {
        final isSelected = controller.selectedQualification.value == e;
        return
          ChoiceChip(
            label: Text(
              e,
              style: TextStyle(
                color: isSelected ? Colors.white : JobColor.appcolor,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => controller.selectedQualification.value = e,
            selectedColor: JobColor.appcolor,
            backgroundColor: Colors.transparent,
            shape: StadiumBorder(
              side: BorderSide(color: JobColor.appcolor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          );
        }).toList(),
        )),
    SizedBox(height: height / 26),
    Text("Gender Of The Staff Should Be", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Wrap(
    spacing: 8,
    children: ['Male', 'Female', 'Both'].map((e) {
    final isSelected = controller.selectedGender.value == e;
    return
    ChoiceChip(
      label: Text(
        e,
        style: TextStyle(
          color: isSelected ? Colors.white : JobColor.appcolor,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => controller.selectedGender.value = e,
      selectedColor: JobColor.appcolor,
      backgroundColor: Colors.transparent,
      shape: StadiumBorder(
        side: BorderSide(color: JobColor.appcolor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );

    }).toList(),
    )),
    SizedBox(height: height / 26),

    Text("English Speaking Skill", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Wrap(
    spacing: 8,
    children: controller.englishSkills.map((e) {
    final isSelected = controller.selectedEnglishSkill.value == e;
    return
      ChoiceChip(
        label: Text(
          e,
          style: TextStyle(
            color: isSelected ? Colors.white : JobColor.appcolor,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.selectedEnglishSkill.value = e,
        selectedColor: JobColor.appcolor,
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: JobColor.appcolor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }).toList(),
    )),
    SizedBox(height: 16),
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
    Text("I want calls from candidates within", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Wrap(
    spacing: 8,
    children: controller.callDistanceOptions.map((e) {
    final isSelected = controller.callDistance.value == e;
    return
      ChoiceChip(
        label: Text(
          e,
          style: TextStyle(
            color: isSelected ? Colors.white : JobColor.appcolor,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.callDistance.value = e,
        selectedColor: JobColor.appcolor,
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: JobColor.appcolor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }).toList(),
    )),
    SizedBox(height: 16),

    Text("Is it a Work From Home Job?", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Row(
    children: [
    Formuiwidget.yesNoButton("Yes", controller.isWorkFromHome.value, () => controller.isWorkFromHome.value = true),
    SizedBox(width: 12),
    Formuiwidget.yesNoButton("No", !controller.isWorkFromHome.value, () => controller.isWorkFromHome.value = false),
    ],
    )),
    SizedBox(height: 16),

    Text("Is there any security deposit charged to the candidate?", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Row(
    children: [
    Formuiwidget.yesNoButton("Yes", controller.securityDeposit.value, () => controller.securityDeposit.value = true),
    SizedBox(width: 12),
    Formuiwidget.yesNoButton("No", !controller.securityDeposit.value, () => controller.securityDeposit.value = false),
    ],
    )),
    SizedBox(height: 16),

    Text("Candidates can call me", style: urbanistMedium.copyWith(fontSize: 16)),
    Obx(() => Wrap(
    spacing: 8,
    children: controller.callAvailabilityOptions.map((e) {
    final isSelected = controller.selectedCallDays.value == e;
    return
      ChoiceChip(
        label: Text(
          e,
          style: TextStyle(
            color: isSelected ? Colors.white : JobColor.appcolor,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => controller.selectedCallDays.value = e,
        selectedColor: JobColor.appcolor,
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(
          side: BorderSide(color: JobColor.appcolor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
    }).toList(),
    )),
    SizedBox(height: 16),

    Text("Describe The Job Role For The Staff", style: urbanistMedium.copyWith(fontSize: 16)),
    Formuiwidget.textField("Enter job role", themedata, controller: controller.jobRoleController, lines: 3),
    SizedBox(height: 16),

    Text("Work Timings", style: urbanistMedium.copyWith(fontSize: 16)),
    Formuiwidget.textField("09:30 am - 6:30pm | Monday to Saturday", themedata, controller: controller.timingsController),
    SizedBox(height: 16),

    Text("Interview Would Be Done Between", style: urbanistMedium.copyWith(fontSize: 16)),
    Formuiwidget.textField("11:00 am - 4:00pm | Monday to Saturday", themedata, controller: controller.interviewTimingsController),
    SizedBox(height: height / 20),

    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Formuiwidget.navigationButton(Icons.arrow_back, () {
    controller.currentStep.value = 1;
    Get.toNamed('/jobpost');
    }),
    Formuiwidget.navigationButton(Icons.arrow_forward, () {
    controller.saveStepTwoData();
    controller.currentStep.value = 3;
    Get.toNamed('/jobpost3');
    }),
    ],),
      ],
    ),
      ),
    );
  }



}