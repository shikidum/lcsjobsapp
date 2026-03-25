import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';

class JobSkills extends StatefulWidget {
  const JobSkills({Key? key}) : super(key: key);

  @override
  State<JobSkills> createState() => _JobSkillsState();
}

class _JobSkillsState extends State<JobSkills> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final themedata = Get.put(JobThemecontroler());
  final storage = GetStorage();
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  // use same controller as onboarding
  final JobHomeController controller = Get.find<JobHomeController>();

  @override
  void initState() {
    super.initState();

    // Initialize selectedSkills from storage if present
    final storedSkills = storage.read("skills");
    if (storedSkills != null) {
      final list = List<String>.from(storedSkills);
      controller.selectedSkills.value = list;
    }
  }

  Future<void> _saveSkillsFromController() async {
    final currentSkills = controller.selectedSkills.toList();

    // 🔹 Save locally
    storage.write("skills", currentSkills);

    // 🔹 Also update candidate profile in DB
    final candidateId = storage.read("candidate_id");
    if (candidateId != null && candidateId.toString().isNotEmpty) {
      try {
        await database
            .child("candidate/$candidateId")
            .update({"skills": currentSkills});
      } catch (e) {
        print("Error updating skills in DB: $e");
      }
    }
  }

  void _onAddSkill(String skill) {
    controller.addSkill(skill);
    _saveSkillsFromController();
  }

  void _onRemoveSkill(String skill) {
    controller.selectedSkills.remove(skill);
    _saveSkillsFromController();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Skills".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              await _saveSkillsFromController();
              Get.back();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / 36,
            vertical: height / 36,
          ),
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Skills *",
                    style: urbanistMedium.copyWith(fontSize: 16)),
                SizedBox(height: 8),

                /// 🔹 Selected skills (chips)
                Wrap(
                  spacing: 8,
                  children: controller.selectedSkills.map((skill) {
                    return Chip(
                      avatar: Icon(
                        Icons.star_border,
                        color: JobColor.appcolor,
                        size: 16,
                      ),
                      label: Text(
                        skill,
                        style: TextStyle(color: JobColor.appcolor),
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: JobColor.appcolor),
                      ),
                      backgroundColor: Colors.white,
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                        color: JobColor.appcolor,
                      ),
                      onDeleted: () => _onRemoveSkill(skill),
                    );
                  }).toList(),
                ),

                SizedBox(height: 12),

                /// 🔹 Search / type field
                TextField(
                  controller: controller.skillsSearchController,
                  onChanged: controller.filterSkills,
                  decoration: InputDecoration(
                    hintText: "Type to search for skills".tr,
                    filled: true,
                    fillColor: themedata.isdark
                        ? JobColor.lightblack
                        : JobColor.appgray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),

                /// 🔹 Dropdown list (filtered + add option)
                if (controller.filteredSkills.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.filteredSkills.map((skill) {
                        final isAddOption = skill.startsWith("Add + ");
                        final actualSkill = isAddOption
                            ? skill.replaceFirst("Add + ", "")
                            : skill;

                        return ListTile(
                          leading: isAddOption
                              ? Icon(Icons.add, color: JobColor.appcolor)
                              : Icon(Icons.star_border,
                              color: JobColor.appcolor),
                          title: Text(
                            actualSkill,
                            style: TextStyle(
                              fontWeight: isAddOption
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isAddOption
                                  ? JobColor.appcolor
                                  : Colors.black,
                            ),
                          ),
                          onTap: () => _onAddSkill(actualSkill),
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: 12),

                /// 🔹 Suggested skills
                Wrap(
                  spacing: 8,
                  children: controller.suggestedSkills.map((e) {
                    return ActionChip(
                      label: Text(e),
                      onPressed: () => _onAddSkill(e),
                    );
                  }).toList(),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
