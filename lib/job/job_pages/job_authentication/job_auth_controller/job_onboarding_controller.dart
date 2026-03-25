import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

import 'job_login_controller.dart';

class JobOnboardingController extends GetxController {
  final storage = GetStorage();
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();


  @override
  void onInit() {
    fetchCategories();
    fetchCities();
    super.onInit();
    _loadSavedstep1Values(); // Load previously saved data when controller is initialized
    _loadStepTwoValues();
    _loadStepThreeValues();
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
  void _loadSavedstep1Values() {
    // Salary and staff count fields
    fullNameController.text = storage.read('profile_name') ?? '';
    ageController.text = storage.read('age') ?? '';
    emailController.text = storage.read('email') ?? '';
    selectedGender.value=storage.read('gender')??'';

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
    print("Step 3 data saved");
  }

  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  var selectedGender = ''.obs;
  var NameError = ''.obs;
  var AgeError = ''.obs;
  var genderError = ''.obs;
  var emailError = ''.obs;

  var profilePicUrl = ''.obs;
  var isProfilePicUploading = false.obs;
  var pickedImagePath = ''.obs;

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
  //// step 2
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

  ///step 3
  var selectedexperience =''.obs;
  var selectedExperience=''.obs;
  RxString selectedCategorySlug = ''.obs;
  RxString selectedCategoryName = ''.obs;
  RxString selectedRole = ''.obs;
  var selectedworking=''.obs;
  final CompanyController = TextEditingController();
  final CurrentSalaryController = TextEditingController();
  RxList<Map<String, String>> categories = <Map<String, String>>[].obs;
  RxList<Map<String, String>> selectedcategories = <Map<String, String>>[].obs;
  RxList<String> roles = <String>[].obs;

  var ExperienceError = ''.obs;
  var SelectExpError = ''.obs;
  var selectcatError = ''.obs;
  var selectroleError = ''.obs;
  var companynameError = ''.obs;
  var workingError = ''.obs;
  var salaryError = ''.obs;

  var ExpYearsOptions= ['Fresher','6 Months','1 Years','2 Years','3 Years','4 Years','5 Years','6 Years','7 Years','8 Years','9 Years','10 Years','11 Years','12 Years','13 Years','14 Years','15 Years','16 Years','17 Years','18 Years','19 Years','20 Years','21 Years','22 Years','23 Years','24 Years','25 Years','26 Years','27 Years','28 Years','29 Years','30 Years'];
    /// Step 4
  RxString selectedDesiredCategorySlug = ''.obs;
  RxString selectedDesiredCategoryName = ''.obs;
  RxString selectedDesiredRole = ''.obs;
  var selectedSkills = <String>[].obs;
  var skillsSearchController = TextEditingController();
  var filteredSkills = <String>[].obs;

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
  var suggestedSkills = ["Computer", "Accounting Standards", "Tally", "SAP", "Accreditation", "Email", "Excel"].obs;

  var englishSkills = ['No English','Basic English', 'Good english', 'fluent english'];
  var selectedEnglishSkill = ''.obs;
//// Step 5
  var selectedCity = ''.obs;
  var selectedLocality = ''.obs;
  // var cities = <String>[].obs;
  RxList<Map<String, String>> cities = <Map<String, String>>[].obs;
  RxList<String> localities = <String>[].obs;

  var resumePath = ''.obs;
  var isResumeSkipped = true.obs;

  var selectedAssets = <String>[].obs;
  var assetsSearchController = TextEditingController();
  var filteredAssets = <String>[].obs;

  void filterAssets(String query) {
    if (query.isEmpty) {
      filteredAssets.clear();
      return;
    }
    final matches = allAssets
        .where((asset) => asset.toLowerCase().contains(query.toLowerCase()))
        .toList();
    // Always show the current query as 'Add +' option (if not already selected)
    if (!selectedAssets.contains(query) && !matches.contains(query)) {
      matches.insert(0, 'Add + $query');
    }

    filteredAssets.value = matches;
  }
  void addAssets(String asset) {
    if (!selectedAssets.contains(asset)) {
      selectedAssets.add(asset);
    }
    assetsSearchController.clear();
    filteredAssets.clear();
  }
  List<String> allAssets = ["Bike", "Pan Card", "Laptop", "Driving Licence", "Heavy Vehicle Driving Licence", "e-bike/yulu", "Aadhar Card"];


  var selectedLanguages = <String>[].obs;
  var languagesSearchController = TextEditingController();
  var filteredLanguages = <String>[].obs;

  void filterLanguages(String query) {
    if (query.isEmpty) {
      filteredLanguages.clear();
      return;
    }

    final matches = allLanguages
        .where((language) => language.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Always show the current query as 'Add +' option (if not already selected)
    if (!selectedLanguages.contains(query) && !matches.contains(query)) {
      matches.insert(0, 'Add + $query');
    }

    filteredLanguages.value = matches;
  }
  void addLanguages(String language) {
    if (!selectedLanguages.contains(language)) {
      selectedLanguages.add(language);
    }
    languagesSearchController.clear();
    filteredLanguages.clear();
  }
  List<String> allLanguages = ["Hindi", "English", "Punjabi", "Kannada", "Marathi", "Bangla", "Kashmiri"];
  var resumeDownloadUrl = ''.obs;
  var isUploading=false.obs;
  Future<String?> uploadResumeToFirebase(File file) async {
    try {
      final fileName = p.basename(file.path);
      final candidateId = storage.read("candidate_id");

      if (candidateId == null) {
        Get.snackbar("Error", "Candidate ID not found. Please log in again.");
        return null;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('resumes/$candidateId/$fileName');

      final uploadTask = ref.putFile(file);

      isUploading.value = true;

      // Wait for completion and monitor progress
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      resumeDownloadUrl.value = downloadUrl;
      storage.write('resume_url', downloadUrl);

      return downloadUrl;
    } catch (e) {
      print("🔥 Resume upload error: $e");
      Get.snackbar("Upload Error", "Resume could not be uploaded.");
      return null;
    } finally {
      isUploading.value = false;
    }
  }


  // void fetchCities() async {
  //   final snapshot = await database.child('cities').get();
  //   if (snapshot.exists) {
  //     cities.value = (snapshot.value as Map).keys.map((e) => e.toString()).toList();
  //     print(categories.value);
  //   }
  // }

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
  void onDegreeChanged(String degree) {
    selectedDegree.value = degree;
    specializationOptions.value = degreeToSpecializations[degree] ?? [];
    selectedSpecialization.value = ''; // reset selected specialization
  }



  void save1stStepLocally() {
    // Dropdown fields
    storage.write('profile_name', fullNameController.text.trim());
    storage.write('age', ageController.text.trim());
    storage.write('gender', selectedGender.value);
    storage.write('email', emailController.text.trim());
  }

  void save2stStepLocally() {
    // Dropdown fields
    storage.write('highestEducation', highestEducation.value);
    storage.write('selectedCourse', selectedCourse.value);
    storage.write('selectedSpecialization', selectedSpecialization.value);
    storage.write('selectedDegree', selectedDegree.value);
    storage.write('selectedDegreeSpecialization', selectedDegreeSpecialization.value);

    storage.write('CollageName', CollageNameController.text.trim());
    storage.write('Passingyear', PassingyearController.text.trim());
  }

  void save3rdStepLocally() {
    storage.write('selectedexperience', selectedexperience.value);
    storage.write('selectedExperienceYears', selectedExperience.value);
    storage.write('selectedCategoryName', selectedCategoryName.value);
    storage.write('selectedCategorySlug', selectedCategorySlug.value);
    storage.write('selectedRole', selectedRole.value);
    storage.write('CompanyName', CompanyController.text.trim());
    storage.write('selectedWorkingStatus', selectedworking.value);
    storage.write('CurrentSalary', CurrentSalaryController.text.trim());
    selectedcategories.clear();
    selectedcategories.add({
      "slug": selectedCategorySlug.value, // firebase key
      "name": selectedCategoryName.value, // display name
    });
  }

  void save4thStepLocally() {
    storage.write('desired_category', selectedDesiredCategoryName.value);
    storage.write('desired_role', selectedDesiredRole.value);
    storage.write('skills', selectedSkills.toList()); // store as List
  }

  void save5thStepLocally() {
    storage.write('preferred_city', selectedCity.value);
    storage.write('preferred_locality', selectedLocality.value);
    // Optional Fields
    storage.write('assets', selectedAssets.toList());
    storage.write('languages', selectedLanguages.toList());
    if (!isResumeSkipped.value && resumePath.value.isNotEmpty) {
      storage.write('resume_path', resumePath.value);
    } else {
      storage.remove('resume_path'); // Remove if skipped
    }

  }
  Future<void> SubmitProfile() async {
    final String? candidateId = storage.read("candidate_id");
    if (candidateId == null) {
      Get.snackbar("Error", "Candidate ID not found. Please login again.");
      return;
    }

    final candidateRef = database.child("candidate").child(candidateId);

    final candidateData = {
      // Step 1
      'profile_name': storage.read('profile_name'),
      'age': storage.read('age'),
      'gender': storage.read('gender'),
      'email': storage.read('email'),
      'profile_pic_url': storage.read('profile_pic_url') ?? '',
      // Step 2
      'highest_education': storage.read('highestEducation'),
      'course': storage.read('selectedCourse'),
      'specialization': storage.read('selectedSpecialization'),
      'degree': storage.read('selectedDegree'),
      'degree_specialization': storage.read('selectedDegreeSpecialization'),
      'college_name': storage.read('CollageName'),
      'passing_year': storage.read('Passingyear'),

      // Step 3
      'experience_type': storage.read('selectedexperience'),
      'experience_years': storage.read('selectedExperienceYears'),
      'current_category': storage.read('selectedCategoryName'),
      'current_role': storage.read('selectedRole'),
      'company_name': storage.read('CompanyName'),
      'working_status': storage.read('selectedWorkingStatus'),
      'current_salary': storage.read('CurrentSalary'),

      // Step 4
      'desired_category': storage.read('desired_category'),
      'desired_role': storage.read('desired_role'),
      'skills': storage.read('skills') ?? [],

      // Step 5 (final)
      'preferred_city': storage.read('preferred_city'),
      'preferred_locality': storage.read('preferred_locality'),
      'assets': storage.read('assets') ?? [],
      'languages': storage.read('languages') ?? [],
      'resume_path': storage.read('resume_path') ?? '',
      'resume_url': storage.read('resume_url') ?? '',
      // Final flags
      'profile_completed': true,
      'updated_on': DateTime.now().toIso8601String()
    };

    try {
      await candidateRef.update(candidateData).then((value) {
        storage.write('is_logged_in', true);
        Get.snackbar("Success", "Your profile has been submitted successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed("/dashboard");
      });
    } catch (e) {
      print("🔥 Firebase Update Error: $e");
      Get.snackbar("Error", "Could not save profile. Try again later.");
    }
  }


}
