import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../job_gloabelclass/job_color.dart';
import '../job_pages/job_authentication/job_loginoption.dart';

class JobSettingsController extends GetxController {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  final storage = GetStorage(); // 🔐 local storage
  var jobs = <Map<String, dynamic>>[].obs;
  var isLoadingMore = false.obs;
  String? lastJobKey;
  int limit = 10;

  var UserName = ''.obs;
  var UserPhone = ''.obs;
  var UserProfile=''.obs;
// Step 1
  var currentStep=0.obs;
  RxList<Map<String, String>> categories = <Map<String, String>>[].obs;
  RxList<String> roles = <String>[].obs;
  // var cities = <String>[].obs;
  // var localities = <String>[].obs;
  RxList<Map<String, String>> cities = <Map<String, String>>[].obs;
  RxList<String> localities = <String>[].obs;

  RxString selectedCategorySlug = ''.obs;
  RxString selectedCategoryName = ''.obs;
  RxString selectedRole = ''.obs;
  var selectedCity = ''.obs;
  var selectedLocality = ''.obs;
  var selectedworking=''.obs;


  final CollageNameController = TextEditingController();
  final PassingyearController = TextEditingController();
  bool get hasSeenOnboarding => storage.read("has_seen_onboarding") ?? false;

  var highestEducation = ''.obs;
  var selectedCourse = ''.obs;
  var selectedSpecialization=''.obs;

  var EducationError = ''.obs;

  var TwelfthCourseOptions= ['Diploma', 'ITI', 'Others'];
  var CourseSpecializatonOptions= ['Architecture', 'Chemical', 'Civil','Computers','Electronics/Telecommunication','Engineering','Export/Import','Fashion Designing/Other Designing','Graphics/Web Desiging','Hotel Management','Insurance','Management','Mechanical','Tourism','Visual Arts','Vocational Course'];
  final Map<String, List<String>> degreeToSpecializations = {
    'B.Sc.': ['Agriculture', 'Anthropology', 'Biology', 'Chemistry'],
    'B.A.': ['History', 'Psychology', 'Sociology'],
    'B.Com.': ['Finance', 'Accounting', 'Economics'],
    'B.B.A.': ['Management', 'Marketing', 'Human Resources'],
    'Diploma': ['Architecture', 'Mechanical', 'Civil'],
    'Others': [],
  };
  final RxList<String> specializationOptions = <String>[].obs;

  var selectedDegree = ''.obs;
  var selectedDegreeSpecialization = ''.obs;

/// Step 2
  var experienceType = ''.obs;
  var minExperienceOptions = ['Fresher', '6 months', '1 year', '2 years', '3 years', '5 years'];
  var maxExperienceOptions = ['1 year', '2 years', '3 years', '5 years','more than 5 years'];
  var selectedMinExp = ''.obs;
  var selectedMaxExp = ''.obs;

  var qualificationOptions = ['10th pass', '12th pass or above', 'Graduate / Post Graduate'];
  var selectedQualification = ''.obs;


  var englishSkills = ['No English','Basic English', 'Good english', 'fluent english'];
  var selectedEnglishSkill = ''.obs;

  var selectedSkills = <String>[].obs;
  var suggestedSkills = ["Basic Excel", "Email", "Computer", "Sales", "Marketing"].obs;
  var skillsSearchController = TextEditingController();
  var filteredSkills = <String>[].obs;

  var callDistanceOptions = ['Nearby area', 'Anywhere in City'];
  var callDistance = ''.obs;

  var isWorkFromHome = false.obs;
  var securityDeposit = false.obs;
  var callAvailabilityOptions = ['Everyday', 'Monday to Friday', 'Monday to Saturday'];
  var selectedCallDays = ''.obs;

  var jobRoleController = TextEditingController();
  var timingsController = TextEditingController(text: "09:30 am - 6:30pm | Monday to Saturday");
  var interviewTimingsController = TextEditingController(text: "11:00 am - 4:00pm | Monday to Saturday");

  /// Step 3

  final CompanyController = TextEditingController();
  final ContactPersonController = TextEditingController();
  final EmailIdController = TextEditingController();
  final PhoneNoController = TextEditingController();
  final AddressController = TextEditingController();
  final SummeryController = TextEditingController();
  var JopRepeat = ''.obs;

  var JobRepeatOptions = ['Once in a Year', 'Once in a few Months', 'Once or Twice every Month', 'Hiring New People Everyday'];
  var ExpYearsOptions= ['6 Months','1 Years','2 Years','3 Years','4 Years','5 Years','6 Years','7 Years','8 Years','9 Years','10 Years','11 Years','12 Years','13 Years','14 Years','15 Years','16 Years','17 Years','18 Years','19 Years','20 Years','21 Years','22 Years','23 Years','24 Years','25 Years','26 Years','27 Years','28 Years','29 Years','30 Years'];

  var ExperienceError = ''.obs;
  var SelectExpError = ''.obs;
  var selectcatError = ''.obs;
  var selectroleError = ''.obs;
  var companynameError = ''.obs;
  var workingError = ''.obs;
  var salaryError = ''.obs;

  var companyNameError = ''.obs;
  var contactPersonError = ''.obs;
  var EmailIdError = ''.obs;
  var PhoneNoError = ''.obs;
  var AddressError = ''.obs;
  var JopRepeatError = ''.obs;

  void resetForm() {
    // Optional: clear all fields if needed
  }

  void _loadStepTwoValues() {
    highestEducation.value = storage.read('highestEducation') ?? '';
    highestEducation.value = storage.read('highestEducation') ?? '';
    selectedSpecialization.value = storage.read('selectedSpecialization') ?? '';
    selectedDegree.value = storage.read('selectedDegree') ?? '';
    selectedDegreeSpecialization.value = storage.read('selectedDegreeSpecialization') ?? '';
    CollageNameController.text = storage.read('CollageName') ?? '';
    PassingyearController.text = storage.read('Passingyear') ?? '';

  }
  void onDegreeChanged(String degree) {
    selectedDegree.value = degree;
    specializationOptions.value = degreeToSpecializations[degree] ?? [];
    selectedSpecialization.value = ''; // reset selected specialization
  }
  var isSubmitting = false.obs;
  var enteredOtp = ''.obs;
  var generatedOtp = ''.obs;

  var profilePicUrl = ''.obs;
  var isProfilePicUploading = false.obs;
  var pickedImagePath = ''.obs;

  Future<void> openTerms() async {
    await FlutterWebBrowser.openWebPage(
      url: "https://laxmiconsultancyservices.com/terms_of_services/",
      customTabsOptions: const CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        showTitle: true,
        toolbarColor: JobColor.appcolor,
      ),
      safariVCOptions: const SafariViewControllerOptions(
        preferredBarTintColor: JobColor.appcolor,
        preferredControlTintColor: Colors.white,
      ),
    );
  }

  void _loadSavedstep1Values() {
    // Salary and staff count fields
    fullNameController.text = storage.read('profile_name') ?? '';
    ageController.text = storage.read('age') ?? '';
    emailController.text = storage.read('email') ?? '';
    selectedGender.value=storage.read('gender')??'';
    AddressController.text=storage.read('address') ?? '';
    PhoneNoController.text=UserPhone.toString()?? '';
    SummeryController.text=storage.read('summery') ?? '';
    jobRoleController.text=storage.read('selectedRole') ?? '';
    CompanyController.text=storage.read('CompanyName') ?? '';
    selectedworking.value=storage.read('selectedWorkingStatus')??'false';
  }
  var selectedexperience =''.obs;
  var selectedExperience=''.obs;
  void _loadStepThreeValues() {
    selectedexperience.value = storage.read('selectedexperience') ?? '';
    selectedExperience.value = storage.read('selectedExperienceYears') ?? '';
    selectedCategoryName.value = storage.read('selectedCategoryName') ?? '';
    selectedCategorySlug.value = storage.read('selectedCategorySlug') ?? '';
    selectedRole.value = storage.read('selectedRole') ?? '';
    CompanyController.text = storage.read('CompanyName') ?? '';
    selectedworking.value = storage.read('selectedWorkingStatus') ?? '';
    CurrentSalaryController.text = storage.read('CurrentSalary') ?? '';
    if (selectedCategoryName.value.isNotEmpty) fetchRoles(selectedCategorySlug.value);
  }
  final CurrentSalaryController = TextEditingController();
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  var selectedGender = ''.obs;
  var NameError = ''.obs;
  var AgeError = ''.obs;
  var genderError = ''.obs;
  var emailError = ''.obs;

  Future<void> saveCandidateDataToLocal(Map<String, dynamic> data) async {
    // Step 1
    storage.write("profile_name", data['profile_name']);
    storage.write("age", data['age']);
    storage.write("gender", data['gender']);
    storage.write("email", data['email']);
    storage.write("profile_pic_url", data['profile_pic_url'] ?? '');

    // Step 2
    storage.write("highestEducation", data['highest_education']);
    storage.write("selectedCourse", data['course']);
    storage.write("selectedSpecialization", data['specialization']);
    storage.write("selectedDegree", data['degree']);
    storage.write("selectedDegreeSpecialization", data['degree_specialization']);
    storage.write("CollageName", data['college_name']);
    storage.write("Passingyear", data['passing_year']);

    // Step 3
    storage.write("selectedexperience", data['experience_type']);
    storage.write("selectedExperienceYears", data['experience_years']);
    storage.write("selectedCategory", data['current_category']);
    storage.write("selectedRole", data['current_role']);
    storage.write("CompanyName", data['company_name']);
    storage.write("selectedWorkingStatus", data['working_status']);
    storage.write("CurrentSalary", data['current_salary']);

    // Step 4
    storage.write("selectedCategory", data['desired_category']);
    storage.write("selectedDesiredRole", data['desired_role']);
    storage.write("skills", data['skills'] ?? []);

    // Step 5
    storage.write("preferred_city", data['preferred_city']);
    storage.write("preferred_locality", data['preferred_locality']);
    storage.write("assets", data['assets'] ?? []);
    storage.write("languages", data['languages'] ?? []);
    storage.write("resume_path", data['resume_path'] ?? '');
    storage.write("resume_url", data['resume_url'] ?? '');

    // Optional flag
    storage.write("profile_completed", true);
  }

  @override
  void onInit() {
    fetchCategories();
    fetchCities();
    loadInitialJobs();
    loadSavedValues();
    _loadSavedstep1Values();
    _loadStepTwoValues();
    super.onInit();
  }
  void loadSavedValues() {
    // Dropdowns
    UserName.value = GetStorage().read('profile_name') ?? '';
    UserPhone.value = GetStorage().read('phone') ?? '';
    UserProfile.value = GetStorage().read('profile_pic_url') ?? '';
    selectedCategoryName.value = storage.read('job_category') ?? '';
    selectedCategorySlug.value = storage.read('job_category_slug') ?? '';
    selectedRole.value = storage.read('job_role') ?? '';
    selectedCity.value = storage.read('job_city') ?? '';
    selectedLocality.value = storage.read('job_locality') ?? '';

    // Trigger dependent dropdown fetches
    if (selectedCategoryName.value.isNotEmpty) fetchRoles(selectedCategorySlug.value);
    if (selectedCity.value.isNotEmpty) fetchLocalities(selectedCity.value);

  }
  Future<void> loadInitialJobs() async {
    final snapshot = await database.child("jobs")
        .orderByKey()
        .limitToLast(limit)
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final sortedJobs = data.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)); // latest first

      jobs.value = sortedJobs.map((e) => {
        "key": e.key,
        ...Map<String, dynamic>.from(e.value)
      }).toList();

      lastJobKey = sortedJobs.last.key;
    }
  }

  Future<void> loadMoreJobs() async {
    if (isLoadingMore.value || lastJobKey == null) return;
    isLoadingMore.value = true;

    final snapshot = await database.child("jobs")
        .orderByKey()
        .endBefore(lastJobKey)
        .limitToLast(limit)
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final newJobs = data.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));

      if (newJobs.isNotEmpty) {
        lastJobKey = newJobs.last.key;
        jobs.addAll(newJobs.map((e) => {
          "key": e.key,
          ...Map<String, dynamic>.from(e.value)
        }));
      }
    }

    isLoadingMore.value = false;
  }


  void fetchCategories() async {
    final snapshot = await database.child('job_categories').get();

    if (!snapshot.exists || snapshot.value == null) {
      categories.clear();
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    categories.value = data.entries.map((entry) {
      return {
        "slug": entry.key, // firebase key
        "name": entry.value['name'].toString(), // display name
      };
    }).toList()
      ..sort((a, b) => a['name']!.compareTo(b['name']!));

    print(categories);
  }
  void fetchRoles(String categorySlug) async {
    final snapshot =
    await database.child('job_categories/$categorySlug/roles').get();

    if (!snapshot.exists || snapshot.value == null) {
      roles.clear();
      return;
    }

    final data = snapshot.value;

    if (data is List) {
      roles.value = data.map((e) => e.toString()).toList()..sort();
    } else if (data is Map) {
      roles.value = data.values.map((e) => e.toString()).toList()..sort();
    } else {
      roles.clear();
    }

    selectedRole.value = ''; // reset role on category change
  }
  void fetchCities() async {
    final snapshot = await database.child('cities').get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      cities.value = data.entries.map((entry) {
        final cityData = entry.value as Map;

        return {
          "name": cityData['name']?.toString() ?? '',
          "slug": entry.key.toString(), // 🔥 slug from key
        };
      }).toList();
    }
  }
  void fetchLocalities(String city) async {
    final snapshot = await database.child('cities/$city/localities').get();
    if (snapshot.exists) {
      final data = snapshot.value;

      if (data is List) {
        localities.value = data.whereType<String>().toList();
      } else if (data is Map) {
        localities.value = data.values.map((e) => e.toString()).toList();
      } else {
        localities.clear();
      }
    } else {
      localities.clear(); // No roles found
    }
  }
  void filterSkills(String query) {
    if (query.isEmpty) {
      filteredSkills.clear();
      return;
    }

    final matches = allSkills
        .where((skill) => skill.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Always show the current query as 'Add +' option (if not already selected)
    if (!selectedSkills.contains(query) && !matches.contains(query)) {
      matches.insert(0, 'Add + $query');
    }

    filteredSkills.value = matches;
  }
  void addSkill(String skill) {
    if (!selectedSkills.contains(skill)) {
      selectedSkills.add(skill);
    }
    skillsSearchController.clear();
    filteredSkills.clear();
  }
  List<String> allSkills = ["Computer", "Accounting Standards", "Tally", "SAP", "Accreditation", "Email", "Excel"];



  void saveCurrentStepLocally() {
  }

  Future<void> uploadProfilePic(File imageFile) async {
    try {
      final candidateId = storage.read("candidate_id");

      if (candidateId == null) {
        Get.snackbar("Error", "Candidate ID not found.");
        return;
      }
      final fileName = 'profile_pic_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures/$candidateId/$fileName');

      isProfilePicUploading.value = true;
      await ref.putFile(imageFile);

      final url = await ref.getDownloadURL();
      profilePicUrl.value = url;
      storage.write('profile_pic_url', url);
    } catch (e) {
      print("🔥 Profile picture upload error: $e");
      Get.snackbar("Upload Error", "Could not upload profile picture.");
    } finally {
      isProfilePicUploading.value = false;
    }
  }

}
