import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_pages/job_theme/job_themecontroller.dart';
import 'package:lcsjobs/job/job_pages/job_widget/formuiwidget.dart';
import 'package:lcsjobs/job/utils/job_home_controller.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../utils/job_search_controller.dart';

class JobFilter extends StatefulWidget {
  const JobFilter({Key? key}) : super(key: key);

  @override
  State<JobFilter> createState() => _JobFilterState();
}

class _JobFilterState extends State<JobFilter> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final themedata = Get.put(JobThemecontroler());
  final JobSearchController searchController = Get.find<JobSearchController>();
  final JobHomeController homeController = Get.find<JobHomeController>();

  int isselected = 0;

  RangeValues _currentRangeValues = const RangeValues(0, 200000);
  int selectedExperienceIndex = 0;

  /// New filters
  String selectedQualification = '';
  String selectedGender = '';
  List<String> selectedSkills = [];

  /// Sections
  final List<String> type = [
    "Location",
    "Salary",
    "Experience",
    "Category",
    "Qualification",
    "Gender",
    "Skill",
  ];

  final List<String> experienceOptions = [
    "Any",
    "Fresher",
    "Experienced Only",
    "Fresher or Experienced",
  ];

  final List<String> qualificationOptions = [
    "Any",
    "10th Pass",
    "12th Pass",
    "Graduate",
    "Graduate / Post Graduate",
  ];

  final List<String> genderOptions = [
    "Any",
    "Male",
    "Female",
    "Both",
  ];

  @override
  void initState() {
    super.initState();

    _currentRangeValues = RangeValues(
      searchController.filterMinSalary.value.toDouble(),
      searchController.filterMaxSalary.value.toDouble(),
    );

    final exp = searchController.filterExperienceType.value;
    if (exp == "Fresher") {
      selectedExperienceIndex = 1;
    } else if (exp == "Experienced Only") {
      selectedExperienceIndex = 2;
    } else if (exp == "Fresher or Experienced") {
      selectedExperienceIndex = 3;
    }

    selectedQualification = searchController.filterQualification.value;
    selectedGender = searchController.filterGender.value;
    selectedSkills = List.from(searchController.filterSkills);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          splashColor: JobColor.transparent,
          highlightColor: JobColor.transparent,
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, size: 22),
        ),
        title: Text(
          "Filter Options".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / 36,
            vertical: height / 36,
          ),
          child: ListView.builder(
            itemCount: type.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  InkWell(
                    splashColor: JobColor.transparent,
                    highlightColor: JobColor.transparent,
                    onTap: () {
                      setState(() => isselected = index);
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: height / 66),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: JobColor.bggray),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: width / 26,
                          vertical: height / 46,
                        ),
                        child: Row(
                          children: [
                            Text(
                              type[index],
                              style: urbanistBold.copyWith(fontSize: 20),
                            ),
                            const Spacer(),
                            Icon(
                              isselected == index
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down_rounded,
                              color: JobColor.appcolor,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// LOCATION & SALARY
                  if (index == 0 && isselected == index)
                    _box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("City",
                              style: urbanistSemiBold.copyWith(fontSize: 14)),
                          Obx(() => DropdownButtonFormField<String>(
                            value: homeController.selectedCity.value.isEmpty
                                ? null
                                : homeController.selectedCity.value,
                            items: homeController.cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city['slug'],      // 🔥 slug stored
                                child: Text(city['name']!), // 🔥 name shown
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              homeController.filterselectedCity.value = value;
                              homeController.filterselectedLocality.value = '';
                              homeController.fetchLocalities(value);
                            },
                            decoration: InputDecoration(
                              hintText: "Select city".tr,
                              hintStyle: urbanistRegular.copyWith(
                                fontSize: 14,
                                color: JobColor.textgray,
                              ),
                              filled: true,
                              fillColor: themedata.isdark
                                  ? JobColor.lightblack
                                  : JobColor.appgray,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: JobColor.appcolor),
                              ),
                            ),
                          )),
                          SizedBox(height: height / 26),
                          // Locality
                          Text(
                            "Locality",
                            style: urbanistSemiBold.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: height / 96),
                          Obx(() => DropdownButtonFormField<String>(
                            value: homeController.filterselectedLocality.value.isEmpty
                                ? null
                                : homeController.filterselectedLocality.value,
                            items: homeController.localities.map((loc) {
                              return DropdownMenuItem(
                                value: loc,
                                child: Text(loc),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              homeController.filterselectedLocality.value = value;
                            },
                            decoration: InputDecoration(
                              hintText: "Select locality".tr,
                              hintStyle: urbanistRegular.copyWith(
                                fontSize: 14,
                                color: JobColor.textgray,
                              ),
                              filled: true,
                              fillColor: themedata.isdark
                                  ? JobColor.lightblack
                                  : JobColor.appgray,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: JobColor.appcolor),
                              ),
                            ),
                          )),
                          SizedBox(height: height / 26),
                        ],
                      ),
                    ),

                  if (index == 1 && isselected == index)
                    _box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Salary range (Rs)",
                              style: urbanistSemiBold.copyWith(fontSize: 14)),
                          RangeSlider(
                            values: _currentRangeValues,
                            min: 0,
                            max: 200000,
                            activeColor: JobColor.appcolor,
                            onChanged: (v) =>
                                setState(() => _currentRangeValues = v),
                          ),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Min: ₹${_currentRangeValues.start.round()}"),
                              Text("Max: ₹${_currentRangeValues.end.round()}"),
                            ],
                          )
                        ],
                      ),
                    ),

                  /// EXPERIENCE
                  if (index == 2 && isselected == index)
                    _box(
                      ListView.separated(
                        itemCount: experienceOptions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) => InkWell(
                          onTap: () =>
                              setState(() => selectedExperienceIndex = i),
                          child: Row(
                            children: [
                              Icon(
                                selectedExperienceIndex == i
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: JobColor.appcolor,
                              ),
                              SizedBox(width: width / 36),
                              Text(experienceOptions[i],
                                  style: urbanistSemiBold.copyWith(
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                        separatorBuilder: (_, __) =>
                            SizedBox(height: height / 36),
                      ),
                    ),

                  /// CATEGORY
                  if (index == 3 && isselected == index)
                    _box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category
                          Text(
                            "Job Category",
                            style: urbanistSemiBold.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: height / 96),
                          Obx(() => DropdownButtonFormField<String>(
                            value: homeController.filterselectedCategorySlug.value.isEmpty
                                ? null
                                : homeController.filterselectedCategorySlug.value,
                            items: homeController.categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['slug'], // internal value
                                child: Text(category['name']!), // UI label
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              homeController.filterselectedCategorySlug.value = value;
                              homeController.filterselectedCategoryName.value =
                              homeController.categories
                                  .firstWhere((e) => e['slug'] == value)['name']!;

                              homeController.fetchRoles(value);
                            },
                            decoration:
                            Formuiwidget.inputDecoration("Select a Category", themedata),
                          )),
                          SizedBox(height: height / 26),

                          // Role (optional)
                          Text(
                            "Job Role (optional)",
                            style: urbanistSemiBold.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: height / 96),
                          Obx(() => DropdownButtonFormField<String>(
                            value: homeController.selectedRole.value.isEmpty
                                ? null
                                : homeController.selectedRole.value,
                            items: homeController.roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              homeController.filterselectedRole.value = value;
                            },
                            decoration:
                            Formuiwidget.inputDecoration("Select Role", themedata),
                          )),
                        ],
                      ),
                    ),

                  /// ADDITIONAL FILTERS
                  if (index == 4 && isselected == index)
                    _box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Qualification",
                              style: urbanistSemiBold.copyWith(fontSize: 14)),
                          DropdownButtonFormField(
                            value: selectedQualification.isEmpty
                                ? null
                                : selectedQualification,
                            items: qualificationOptions
                                .map((q) => DropdownMenuItem(
                                value: q, child: Text(q)))
                                .toList(),
                            onChanged: (v) {
                              setState(() => selectedQualification =
                              v == "Any" ? '' : v!);
                            },
                          ),
                          SizedBox(height: height / 26),
                        ],
                      ),
                    ),
                  if (index == 5 && isselected == index)
                    _box(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Gender",
                              style: urbanistSemiBold.copyWith(fontSize: 14)),
                          DropdownButtonFormField(
                            value: selectedGender.isEmpty
                                ? null
                                : selectedGender,
                            items: genderOptions
                                .map((g) => DropdownMenuItem(
                                value: g, child: Text(g)))
                                .toList(),
                            onChanged: (v) {
                              setState(() =>
                              selectedGender = v == "Any" ? '' : v!);
                            },
                          ),
                          SizedBox(height: height / 26),
                        ],
                      ),
                    ),
              if (index == 6 && isselected == index)
              _box(
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              SizedBox(height: height / 26),
              Text(
              "Skills",
              style: urbanistSemiBold.copyWith(fontSize: 14),
              ),
              Wrap(
              spacing: 8,
              children: homeController.allSkills.map((skill) {
              final selected = selectedSkills.contains(skill);
              return FilterChip(
              label: Text(skill),
              selected: selected,
              onSelected: (val) {
              setState(() {
              val
              ? selectedSkills.add(skill)
                  : selectedSkills.remove(skill);
              });
              },
              );
              }).toList(),
              ),
              ],
              ),
              ),
              ],
              );
            },
          ),
        ),
      ),

      /// BOTTOM BAR
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width / 36,
          vertical: height / 36,
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _reset,
              child: _btn("Reset", JobColor.lightblue, JobColor.appcolor),
            ),
            const Spacer(),
            InkWell(
              onTap: _apply,
              child: _btn("Apply", JobColor.appcolor, JobColor.white),
            ),
          ],
        ),
      ),
    );
  }

  /// Helpers (using your existing design)
  Widget _box(Widget child) => Container(
    margin: EdgeInsets.only(bottom: height / 36),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: JobColor.bggray),
    ),
    padding: EdgeInsets.all(width / 36),
    child: child,
  );

  Widget _btn(String text, Color bg, Color fg) => Container(
    height: height / 15,
    width: width / 2.2,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: bg,
    ),
    child: Center(
      child: Text(text,
          style:
          urbanistSemiBold.copyWith(fontSize: 16, color: fg)),
    ),
  );

  void _reset() {
    setState(() {
      _currentRangeValues = const RangeValues(0, 200000);
      selectedExperienceIndex = 0;
      selectedQualification = '';
      selectedGender = '';
      selectedSkills.clear();
    });
    searchController.resetFilters();
    searchController.refreshCurrentSearch();
  }

  void _apply() {
    searchController.filterMinSalary.value =
        _currentRangeValues.start.round();
    searchController.filterMaxSalary.value =
        _currentRangeValues.end.round();

    searchController.filterExperienceType.value =
    selectedExperienceIndex == 0
        ? ''
        : experienceOptions[selectedExperienceIndex];

    searchController.filterQualification.value = selectedQualification;
    searchController.filterGender.value = selectedGender;
    searchController.filterSkills.assignAll(selectedSkills);

    searchController.refreshCurrentSearch();
    Navigator.pop(context);
  }
}
