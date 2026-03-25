import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../job_pages/job_authentication/job_loginoption.dart';
import 'job_app_settings.dart';

class JobHomeController extends GetxController {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  final JobAppController jobappcontroller = Get.put(JobAppController());
  final storage = GetStorage(); // 🔐 local storage
  var jobs = <Map<String, dynamic>>[].obs;
  var job = <String, dynamic>{}.obs;
  final applicationsWithJobs = <Map<String, dynamic>>[].obs;
  var isLoadingMore = false.obs;
  var isUploading = false.obs;
  var isProfileUpdating=false.obs;
  String? lastPostedOn;
  String? lastJobKey;
  int limit = 10;
  final ScrollController scrollController = ScrollController();
  final ScrollController homescrollController = ScrollController();
  var UserName = ''.obs;
  var UserPhone = ''.obs;
  var UserProfile=''.obs;
// Step 1
  var currentStep=0.obs;
  RxList<Map<String, String>> categories = <Map<String, String>>[].obs;
  RxList<String> roles = <String>[].obs;
  // var cities = <String>[].obs;
  RxList<Map<String, String>> cities = <Map<String, String>>[].obs;
  RxList<String> localities = <String>[].obs;
  //var localities = <String>[].obs;

  RxString filterselectedCategorySlug = ''.obs;
  RxString filterselectedCategoryName = ''.obs;
  RxString filterselectedRole = ''.obs;

  var filterselectedCity = ''.obs;
  var filterselectedLocality = ''.obs;
  var filterselectedworking=''.obs;


  RxString selectedCategorySlug = ''.obs;
  RxString selectedCategoryName = ''.obs;
  RxString selectedRole = ''.obs;
  var selectedCity = ''.obs;
  var selectedLocality = ''.obs;
  var selectedworking=''.obs;

  final matchedJobs = <Map<String, dynamic>>[].obs;
  String? lastMatchedJobKey;

  final CollageNameController = TextEditingController();
  final PassingyearController = TextEditingController();
  bool get hasSeenOnboarding => storage.read("has_seen_onboarding") ?? false;

  var highestEducation = ''.obs;
  var selectedCourse = ''.obs;
  var selectedSpecialization=''.obs;

  RxBool isContactUpdating = false.obs;
  RxBool isSummaryUpdating = false.obs;
  RxBool isEducationUpdating = false.obs;

  var EducationError = ''.obs;

  RxString educationError = ''.obs;
  RxString courseError = ''.obs;
  RxString specializationError = ''.obs;
  RxString degreeError = ''.obs;
  RxString collegeNameError = ''.obs;
  RxString passingYearError = ''.obs;

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
  RxBool isWorkExperienceUpdating = false.obs;
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
  var ExpYearsOptions= ['Fresher','6 Months','1 Years','2 Years','3 Years','4 Years','5 Years','6 Years','7 Years','8 Years','9 Years','10 Years','11 Years','12 Years','13 Years','14 Years','15 Years','16 Years','17 Years','18 Years','19 Years','20 Years','21 Years','22 Years','23 Years','24 Years','25 Years','26 Years','27 Years','28 Years','29 Years','30 Years'];

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

  var subscription_status=''.obs;
  var applied_jobs = <String>[].obs;

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
  var selectedexperience =''.obs;
  var selectedExperience=''.obs;

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

  final subscriptionPlanId = ''.obs;
  final subscriptionStartDate = Rx<DateTime?>(null);
  final subscriptionEndDate = Rx<DateTime?>(null);
  final isSubscriptionValid = false.obs;

  // Reactive state
  final isLoadingProfile = false.obs;
  final isSyncing = false.obs;
  final profileData = <String, dynamic>{}.obs;


  @override
  void onInit() {
    jobappcontroller.fetchSettings();
    fetchCategories();
    fetchCities();
    syncUserData(showLoading: false);
    loadSavedValues();
    _loadSavedstep1Values();
    _loadStepTwoValues();
    _loadStepThreeValues();
    loadInitialJobs();
    loadInitialMatchedJobs();
    loadUserApplications();
    super.onInit();
    scrollController.addListener(() {
      print("SCROLL: ${scrollController.position.pixels}");
      print("MAX: ${scrollController.position.maxScrollExtent}");

      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        print("BOTTOM REACHED");
        loadMoreJobs();
      }
    });
    homescrollController.addListener(() {
      print("SCROLL: ${homescrollController.position.pixels}");
      print("MAX: ${homescrollController.position.maxScrollExtent}");

      if (homescrollController.position.pixels >=
          homescrollController.position.maxScrollExtent - 200) {
        print("BOTTOM REACHED");
        loadMoreMatchedJobs();
      }
    });
  }

  Future<void> loadUserApplications() async {
    try {
      // 🔹 Get candidate ID from storage (adjust key if different)
      final candidateId = storage.read("candidate_id");
      if (candidateId == null || candidateId.toString().isEmpty) {
        applicationsWithJobs.value = [];
        return;
      }

      // 🔹 Fetch all applications for this candidate
      final appsSnap = await database
          .child("applications")
          .orderByChild("candidate_id")
          .equalTo(candidateId)
          .get();

      if (!appsSnap.exists || appsSnap.value == null) {
        applicationsWithJobs.value = [];
        return;
      }

      final appsMap = Map<String, dynamic>.from(appsSnap.value as Map);

      // Sort applications by created_at (newest first)
      final appEntries = appsMap.entries.toList()
        ..sort((a, b) {
          final aCreated = (a.value["created_at"] ?? "") as String;
          final bCreated = (b.value["created_at"] ?? "") as String;
          return bCreated.compareTo(aCreated);
        });

      final List<Map<String, dynamic>> result = [];

      // 🔹 For each application, fetch its job
      for (final e in appEntries) {
        final app = Map<String, dynamic>.from(e.value as Map);
        final jobId = app["job_id"] as String?;

        if (jobId == null || jobId.isEmpty) continue;

        final jobSnap = await database.child("jobs/$jobId").get();
        if (!jobSnap.exists || jobSnap.value == null) continue;

        final job = Map<String, dynamic>.from(jobSnap.value as Map);

        result.add({
          "application_id": e.key,
          ...app,       // candidate_id, job_id, status, created_at, updated_at
          "job": job,   // full job data
        });
      }

      applicationsWithJobs.value = result;
    } catch (e) {
      print("Error loading applications: $e");
    }
  }
  void loadSavedValues() {
    try {
    final candidateId = storage.read('candidate_id');
    if (candidateId == null) return;

    final expiryStr = storage.read('plan_end_date');
    if (expiryStr != null && expiryStr.isNotEmpty) {
      subscriptionEndDate.value = DateTime.tryParse(expiryStr);
    }
    _checkSubscriptionValidity();

    storage.write("subscription_status", isSubscriptionValid.value ? 'active' : 'inactive');
    subscription_status.value = storage.read("subscription_status") ?? 'inactive';

    // Trigger dependent dropdown fetches
    if (selectedCategoryName.value.isNotEmpty) fetchRoles(selectedCategorySlug.value);
    if (selectedCity.value.isNotEmpty) fetchLocalities(selectedCity.value);

    var ddata = storage.read('applied_jobs') ?? '';
    if (ddata is List) {
      applied_jobs.value = ddata.whereType<String>().toList();
    } else if (ddata is Map) {
      applied_jobs.value = ddata.values.map((e) => e.toString()).toList();
    } else {
      applied_jobs.clear();
    }

    // Dropdowns
    UserName.value = GetStorage().read('profile_name') ?? '';
    UserPhone.value = GetStorage().read('phone') ?? '';
    UserProfile.value = GetStorage().read('profile_pic_url') ?? '';
    selectedCategoryName.value = storage.read('job_category') ?? '';
    selectedCategorySlug.value = storage.read('job_category_slug') ?? '';
    selectedRole.value = storage.read('job_role') ?? '';
    selectedCity.value = storage.read('job_city') ?? '';
    selectedLocality.value = storage.read('job_locality') ?? '';
    } catch (e) {
      debugPrint('⚠️ Error loading local data: $e');
    }
  }
  void _checkSubscriptionValidity() {
    if (subscriptionEndDate.value == null) {
      isSubscriptionValid.value = false; // Active with no expiry = lifetime?
      return;
    }
    if (subscriptionPlanId.isEmpty) {
      isSubscriptionValid.value = false;
      return;
    }
    isSubscriptionValid.value = subscriptionEndDate.value!.isAfter(DateTime.now());
  }

  Future<void> updateEducation() async {
    // Clear previous errors
    educationError.value = '';
    courseError.value = '';
    specializationError.value = '';
    degreeError.value = '';
    collegeNameError.value = '';
    passingYearError.value = '';

    final String highest = highestEducation.value.trim();

    if (highest.isEmpty) {
      educationError.value = 'Please select your educational attainment';
      Get.snackbar('Validation', 'Please select your educational attainment');
      return;
    }

    // Prepare values
    String course = '';
    String specialization = '';
    String degree = '';
    String degreeSpecialization = '';
    String collegeName = '';
    String passingYear = '';

    bool hasError = false;

    // CASE 1: Less Than Tenth / Tenth
    if (highest == 'Less Than Tenth' || highest == 'Tenth') {
      // nothing else required, keep everything else blank

    }
    // CASE 2: Twelfth and Above
    else if (highest == 'Twelfth and Above') {
      course = selectedCourse.value.trim();
      if (course.isEmpty) {
        courseError.value = 'Please select course';
        hasError = true;
      }

      // Only require specialization if not "Others"
      if (course != 'Others') {
        specialization = selectedSpecialization.value.trim();
        if (specialization.isEmpty) {
          specializationError.value = 'Please select branch / field of study';
          hasError = true;
        }
      }
    }
    // CASE 3: Graduate and Above
    else if (highest == 'Graduate and Above') {
      degree = selectedDegree.value.trim();
      if (degree.isEmpty) {
        degreeError.value = 'Please select degree';
        hasError = true;
      }

      if (degree != 'Others') {
        degreeSpecialization = selectedSpecialization.value.trim();
        if (degreeSpecialization.isEmpty) {
          specializationError.value = 'Please select branch / field of study';
          hasError = true;
        }
      }

      collegeName = CollageNameController.text.trim();
      if (collegeName.isEmpty) {
        collegeNameError.value = 'Please enter college name';
        hasError = true;
      }

      passingYear = PassingyearController.text.trim();
      if (passingYear.isEmpty) {
        passingYearError.value = 'Please enter passing year';
        hasError = true;
      } else {
        final year = int.tryParse(passingYear);
        final currentYear = DateTime.now().year;
        if (year == null || passingYear.length != 4 || year < 1950 || year > currentYear + 5) {
          passingYearError.value = 'Please enter a valid passing year';
          hasError = true;
        }
      }
    }

    if (hasError) {
      Get.snackbar('Validation', 'Please correct highlighted education fields');
      return;
    }

    try {
      isEducationUpdating.value = true;

      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final Map<String, dynamic> updateMap = {
        'highest_education': highest,
        'course': course,
        'specialization': specialization,
        'degree': degree,
        'degree_specialization': degreeSpecialization,
        'college_name': collegeName,
        'passing_year': passingYear,
        'updated_on': DateTime.now().toIso8601String(),
      };

      // Adjust node name if your root is different
      await database.child('candidate').child(candidateId).update(updateMap);

      // Sync to local storage (aligned to _saveCandidateDataToLocal)
      storage.write('highestEducation', highest);
      storage.write('selectedCourse', course);
      storage.write('selectedSpecialization', specialization);
      storage.write('selectedDegree', degree);
      storage.write('selectedDegreeSpecialization', degreeSpecialization);
      storage.write('CollageName', collegeName);
      storage.write('Passingyear', passingYear);

      Get.snackbar('Success', 'Education updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating education: $e');
      Get.snackbar('Error', 'Failed to update education');
    } finally {
      isEducationUpdating.value = false;
    }
  }

  Future<void> loadInitialJobs() async {
    final storedCity = storage.read("preferred_city");
    final preferredCity = (storedCity ?? "").toString().trim().toLowerCase();

    final snapshot = await database
        .child("jobs")
        .orderByKey()
        .limitToLast(limit)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      jobs.value = [];
      lastJobKey = null;
      return;
    }

    final data = snapshot.value as Map<dynamic, dynamic>;

    List<Map<String, dynamic>> allJobs = data.entries.map((e) {
      return {
        "key": e.key,
        ...Map<String, dynamic>.from(e.value as Map),
      };
    }).toList();

    // sort newest first
    allJobs.sort((a, b) => (b["key"] as String)
        .compareTo(a["key"] as String));

    var filtered =
    allJobs.where((job) => job["isapproved"] == true).toList();

    if (preferredCity.isNotEmpty) {
      filtered = filtered.where((job) =>
      (job["city"] ?? "")
          .toString()
          .trim()
          .toLowerCase() ==
          preferredCity).toList();
    }

    jobs.value = filtered;

    if (filtered.isNotEmpty) {
      lastJobKey = filtered.last["key"];
    }
  }
  // Future<void> loadMoreJobs() async {
  //   if (isLoadingMore.value || lastJobKey == null) return;
  //   isLoadingMore.value = true;
  //
  //   // 🔹 Read candidate's preferred city from local storage
  //   final storedCity = storage.read("preferred_city");
  //   final preferredCity = (storedCity ?? "").toString().trim().toLowerCase();
  //
  //   // Get older jobs by key (like before), then filter + sort by posted_on
  //   final snapshot = await database
  //       .child("jobs")
  //       .orderByKey()
  //       .endBefore(lastJobKey)  // older than the last loaded key
  //       .limitToLast(limit * 5) // buffer for filtering
  //       .get();
  //
  //   if (snapshot.exists && snapshot.value != null) {
  //     final data = snapshot.value as Map<dynamic, dynamic>;
  //
  //     List<Map<String, dynamic>> allJobs = data.entries.map((e) {
  //       return {
  //         "key": e.key,
  //         ...Map<String, dynamic>.from(e.value as Map),
  //       };
  //     }).toList();
  //
  //     // 🔹 Filter approved + city
  //     var filtered = allJobs.where((job) => job["isapproved"] == true).toList();
  //
  //     if (preferredCity.isNotEmpty) {
  //       filtered = filtered
  //           .where((job) =>
  //       (job["city"] ?? "").toString().trim().toLowerCase() ==
  //           preferredCity)
  //           .toList();
  //     }
  //
  //     // 🔹 Sort by posted_on (newest first within this batch)
  //     filtered.sort((a, b) {
  //       final pa = (a["posted_on"] ?? "") as String;
  //       final pb = (b["posted_on"] ?? "") as String;
  //       return pb.compareTo(pa);
  //     });
  //
  //     // 🔹 Only take as many as UI page size
  //     filtered = filtered.take(limit).toList();
  //
  //     if (filtered.isNotEmpty) {
  //       lastJobKey = filtered.last["key"] as String;
  //
  //       jobs.addAll(filtered);
  //     }
  //   }
  //
  //   isLoadingMore.value = false;
  // }
  Future<void> loadMoreJobs() async {
    if (isLoadingMore.value || lastJobKey == null) return;

    isLoadingMore.value = true;

    print("LOAD MORE CALLED");

    try {
      final snapshot = await database
          .child("jobs")
          .orderByKey()
          .endAt(lastJobKey) // ✅ SAFE (NOT endBefore)
          .limitToLast(limit + 1) // +1 to remove duplicate
          .get();

      if (snapshot.exists && snapshot.value != null) {
        final data = snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> allJobs = data.entries.map((e) {
          return {
            "key": e.key,
            ...Map<String, dynamic>.from(e.value as Map),
          };
        }).toList();

        // Sort newest first
        allJobs.sort((a, b) =>
            (b["key"] as String).compareTo(a["key"] as String));

        // 🔥 REMOVE DUPLICATE (first item will be previous lastKey)
        allJobs.removeWhere((job) => job["key"] == lastJobKey);

        var filtered =
        allJobs.where((job) => job["isapproved"] == true).toList();

        var newItems = filtered.take(limit).toList();

        if (newItems.isNotEmpty) {
          lastJobKey = newItems.last["key"];
          jobs.addAll(newItems);
        }
      }
    } catch (e) {
      print("Pagination error: $e");
    }

    isLoadingMore.value = false;
  }
  bool containsFlexible(String source, String target) {
    source = source.toLowerCase().trim();
    target = target.toLowerCase().trim();
    if (source.isEmpty || target.isEmpty) return false;
    return source.contains(target) || target.contains(source);
  }
  // Future<void> loadInitialMatchedJobs() async {
  //   // 🔹 Candidate data from local storage
  //   var desiredCategory = (storage.read("desired_category") ?? "").toString().trim().toLowerCase();
  //   if (desiredCategory.isEmpty) {
  //     desiredCategory = (storage.read("desired_category") ?? "")
  //         .toString().trim()
  //         .toLowerCase();
  //   }
  //   final preferredCity = (storage.read("preferred_city") ?? "").toString().trim().toLowerCase();
  //   final preferredLocality = (storage.read("preferred_locality") ?? "").toString().trim().toLowerCase();
  //   final candidateGender = (storage.read("gender") ?? "").toString().trim();
  //   //final candidateYears = _parseYears(storage.read("selectedExperienceYears"));
  //
  //   if (desiredCategory.isEmpty || preferredCity.isEmpty) {
  //     print('Candidate category or city not set in storage');
  //     matchedJobs.value = [];
  //     lastMatchedJobKey = null;
  //     return;
  //   }
  //
  //   final snapshot = await database
  //       .child("jobs")
  //       .orderByKey()
  //       .limitToLast(limit)
  //       .get();
  //
  //   if (!snapshot.exists || snapshot.value == null) {
  //     print('No jobs found');
  //     matchedJobs.value = [];
  //     lastMatchedJobKey = null;
  //     return;
  //   }
  //
  //   final data = snapshot.value as Map<dynamic, dynamic>;
  //
  //   List<Map<String, dynamic>> allJobs = data.entries.map((e) {
  //     return {
  //       "key": e.key,
  //       ...Map<String, dynamic>.from(e.value as Map),
  //     };
  //   }).toList();
  //
  //   // sort newest first
  //   allJobs.sort((a, b) => (b["key"] as String)
  //       .compareTo(a["key"] as String));
  //
  //   var filtered = allJobs
  //       .where((job) => job["isapproved"] == true)
  //   // Flexible Category
  //       .where((job) {
  //     final jobCategory =
  //     (job["category"] ?? "").toString();
  //     return containsFlexible(jobCategory, desiredCategory);
  //   })
  //
  //   // Flexible City
  //       .where((job) {
  //     final jobCity =
  //     (job["city"] ?? "").toString();
  //     return containsFlexible(jobCity, preferredCity);
  //   })
  //
  //   // Gender Flexible
  //       .where((job) {
  //     final jobGender =
  //     (job["gender"] ?? "").toString().toLowerCase();
  //     final candGender = candidateGender.toLowerCase();
  //
  //     if (jobGender.isEmpty ||
  //         jobGender == "any" ||
  //         jobGender == "both") return true;
  //
  //     if (candGender.isEmpty) return true;
  //
  //     return jobGender == candGender;
  //   })
  //
  //   // Experience Range
  //   //     .where((job) {
  //   //   final minExp = _parseYears(job["min_experience"]);
  //   //   final maxExp = _parseYears(job["max_experience"]);
  //   //
  //   //   if (candidateYears == null) return true;
  //   //
  //   //   if (minExp != null && candidateYears < minExp) return false;
  //   //   if (maxExp != null && candidateYears > maxExp) return false;
  //   //
  //   //   return true;
  //   // })
  //
  //       .toList();
  //   // 🔹 Keep only limit
  //   filtered = filtered.take(limit).toList();
  //
  //   matchedJobs.value = filtered;
  //
  //   if (filtered.isNotEmpty) {
  //     lastMatchedJobKey = filtered.last["key"] as String;
  //   } else {
  //     lastMatchedJobKey = null;
  //   }
  // }
  Future<void> loadInitialMatchedJobs() async {

    var desiredCategory =
    (storage.read("desired_category") ?? "").toString().trim().toLowerCase();

    final preferredCity =
    (storage.read("preferred_city") ?? "").toString().trim().toLowerCase();

    final preferredLocality =
    (storage.read("preferred_locality") ?? "").toString().trim().toLowerCase();

    final candidateGender =
    (storage.read("gender") ?? "").toString().trim().toLowerCase();

    if (desiredCategory.isEmpty || preferredCity.isEmpty) {
      matchedJobs.value = [];
      lastMatchedJobKey = null;
      return;
    }

    final indexKey = "${desiredCategory}_${preferredCity}";

    final snapshot = await database
        .child("job_index")
        .child(indexKey)
        .limitToFirst(limit)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      matchedJobs.value = [];
      lastMatchedJobKey = null;
      return;
    }

    final ids = Map<String, dynamic>.from(snapshot.value as Map);

    List<Map<String, dynamic>> jobs = [];

    for (var jobId in ids.keys) {

      final jobSnap = await database.child("jobs/$jobId").get();

      if (!jobSnap.exists) continue;

      final job = Map<String, dynamic>.from(jobSnap.value as Map);

      if (job["isapproved"] != true) continue;

      final jobGender = (job["gender"] ?? "").toString().toLowerCase();

      if (jobGender.isNotEmpty &&
          jobGender != "any" &&
          jobGender != "both" &&
          candidateGender.isNotEmpty &&
          jobGender != candidateGender) {
        continue;
      }

      jobs.add({
        "key": jobId,
        ...job,
      });
    }

    matchedJobs.value = jobs;

    if (jobs.isNotEmpty) {
      lastMatchedJobKey = jobs.last["key"];
    } else {
      lastMatchedJobKey = null;
    }
  }
  // Future<void> loadMoreMatchedJobs() async {
  //   if (isLoadingMore.value || lastMatchedJobKey == null) return;
  //   isLoadingMore.value = true;
  //
  //   // 🔹 Candidate data again
  //   final desiredCategory =
  //   (storage.read("selectedCategory") ?? "").toString().trim().toLowerCase();
  //   final preferredCity =
  //   (storage.read("preferred_city") ?? "").toString().trim().toLowerCase();
  //   final candidateGender =
  //   (storage.read("gender") ?? "").toString().trim();
  //   final candidateYears =
  //   _parseYears(storage.read("selectedExperienceYears"));
  //
  //   final snapshot = await database
  //       .child("jobs")
  //       .orderByKey()
  //       .endBefore(lastMatchedJobKey)
  //       .limitToLast(limit * 5) // buffer for filtering
  //       .get();
  //
  //   if (snapshot.exists && snapshot.value != null) {
  //     final data = snapshot.value as Map<dynamic, dynamic>;
  //
  //     List<Map<String, dynamic>> allJobs = data.entries.map((e) {
  //       return {
  //         "key": e.key,
  //         ...Map<String, dynamic>.from(e.value as Map),
  //       };
  //     }).toList();
  //
  //     var filtered = allJobs
  //         .where((job) => job["isapproved"] == true)
  //         .where((job) =>
  //     (job["category"] ?? "").toString().trim().toLowerCase() ==
  //         desiredCategory)
  //         .where((job) =>
  //     (job["city"] ?? "").toString().trim().toLowerCase() ==
  //         preferredCity)
  //         .where((job) {
  //       final jobGender = (job["gender"] ?? "").toString().trim();
  //       if (jobGender.isEmpty || jobGender == "Any") return true;
  //       if (candidateGender.isEmpty) return true;
  //       return jobGender == candidateGender;
  //     })
  //         .where((job) {
  //       final minExp = _parseYears(job["min_experience"]);
  //       if (candidateYears == null || minExp == null) return true;
  //       return candidateYears >= minExp;
  //     })
  //         .toList();
  //
  //     // sort by posted_on
  //     filtered.sort((a, b) {
  //       final pa = (a["posted_on"] ?? "") as String;
  //       final pb = (b["posted_on"] ?? "") as String;
  //       return pb.compareTo(pa);
  //     });
  //
  //     filtered = filtered.take(limit).toList();
  //
  //     if (filtered.isNotEmpty) {
  //       lastMatchedJobKey = filtered.last["key"] as String;
  //       matchedJobs.addAll(filtered);
  //     } else {
  //       lastMatchedJobKey = null;
  //     }
  //   }
  //   isLoadingMore.value = false;
  // }
  Future<void> loadMoreMatchedJobs() async {

    if (isLoadingMore.value || lastMatchedJobKey == null) return;

    isLoadingMore.value = true;

    final desiredCategory =
    (storage.read("desired_category") ?? "").toString().trim().toLowerCase();

    final preferredCity =
    (storage.read("preferred_city") ?? "").toString().trim().toLowerCase();

    final candidateGender =
    (storage.read("gender") ?? "").toString().trim().toLowerCase();

    final indexKey = "${desiredCategory}_${preferredCity}";

    final snapshot = await database
        .child("job_index")
        .child(indexKey)
        .orderByKey()
        .startAfter(lastMatchedJobKey)
        .limitToFirst(limit)
        .get();

    if (!snapshot.exists || snapshot.value == null) {
      lastMatchedJobKey = null;
      isLoadingMore.value = false;
      return;
    }

    final ids = Map<String, dynamic>.from(snapshot.value as Map);

    List<Map<String, dynamic>> jobs = [];

    for (var jobId in ids.keys) {

      final jobSnap = await database.child("jobs/$jobId").get();

      if (!jobSnap.exists) continue;

      final job = Map<String, dynamic>.from(jobSnap.value as Map);

      if (job["isapproved"] != true) continue;

      final jobGender = (job["gender"] ?? "").toString().toLowerCase();

      if (jobGender.isNotEmpty &&
          jobGender != "any" &&
          jobGender != "both" &&
          candidateGender.isNotEmpty &&
          jobGender != candidateGender) {
        continue;
      }

      jobs.add({
        "key": jobId,
        ...job,
      });
    }

    if (jobs.isNotEmpty) {
      lastMatchedJobKey = jobs.last["key"];
      matchedJobs.addAll(jobs);
    } else {
      lastMatchedJobKey = null;
    }

    isLoadingMore.value = false;
  }
  int? _parseYears(dynamic value) {
    if (value == null) return null;
    final str = value.toString().toLowerCase();  // "3 years", "more than 5 years", "23 Years"
    final match = RegExp(r'(\d+)').firstMatch(str);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  Future<void> loadJobDetails(String jobId) async {
    final snapshot = await database.child("jobs/$jobId").get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      job.value = {
        "key": jobId,
        ...data,
      };
    } else {
      // Handle case when job doesn't exist
      job.value = {};
      print("Job with ID $jobId not found.");
    }

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

  Future<void> updateBasicProfile() async {
    final name = fullNameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Validation', 'Please enter your full name');
      return;
    }

    if (selectedGender.value.isEmpty) {
      genderError.value = 'Please select gender';
      return;
    } else {
      genderError.value = '';
    }

    final prefcity = selectedCity.value.isEmpty
        ? storage.read("preferred_city")
        : selectedCity.value;

    final prefloc = selectedLocality.value.isEmpty
        ? storage.read("preferred_locality")
        : selectedLocality.value;

    try {
      isProfileUpdating.value = true;

      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final updateMap = {
        'profile_name': name,
        'gender': selectedGender.value,
        'profile_pic_url': profilePicUrl.value,
        'preferred_city': prefcity,
        'preferred_locality': prefloc,
      };

      await database
          .child('candidate')
          .child(candidateId)
          .update(updateMap);

      // ✅ Update local storage
      storage.write('profile_name', name);
      storage.write('gender', selectedGender.value);
      storage.write('profile_pic_url', profilePicUrl.value);
      storage.write('preferred_city', prefcity);
      storage.write('preferred_locality', prefloc);

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isProfileUpdating.value = false;
    }
  }
  Future<void> updateJobCategory() async {
    try {
      isProfileUpdating.value = true;

      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      // 🔹 Final Category (name)
      final String finalCategory =
      selectedCategoryName.value.isNotEmpty
          ? selectedCategoryName.value
          : (storage.read("desired_category") ?? "");

      // 🔹 Final Role (name)
      final String finalRole =
      selectedRole.value.isNotEmpty
          ? selectedRole.value
          : (storage.read("desired_role") ?? "");

      if (finalCategory.isEmpty) {
        Get.snackbar('Validation', 'Please select category');
        return;
      }

      if (finalRole.isEmpty) {
        Get.snackbar('Validation', 'Please select role');
        return;
      }

      final Map<String, dynamic> updateMap = {
        'desired_category': finalCategory,
        'desired_role': finalRole,
      };

      // 🔹 Update in Realtime Database
      await database
          .child('candidate')
          .child(candidateId)
          .update(updateMap);

      // 🔹 Update local storage
      storage.write('desired_category', finalCategory);
      storage.write('desired_role', finalRole);

      Get.snackbar('Success', 'Category & Role updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating category & role: $e');
      Get.snackbar('Error', 'Failed to update');
    } finally {
      isProfileUpdating.value = false;
    }
  }


  Future<void> updateContactInfo() async {
    final String address = AddressController.text.trim();
    final String email = emailController.text.trim();

    // Basic email validation
    if (email.isEmpty) {
      Get.snackbar('Validation', 'Please enter your email');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('Validation', 'Please enter a valid email address');
      return;
    }

    try {
      isContactUpdating.value = true;

      // Get candidate/user id from storage
      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final Map<String, dynamic> updateMap = {
        'email': email,
        'address': address, // address is optional, can be empty string
      };

      // Update in Firebase Realtime Database
      await database.child('candidate').child(candidateId).update(updateMap);

      // Update local storage for these fields
      storage.write('email', email);
      storage.write('address', address);

      Get.snackbar('Success', 'Contact information updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating contact info: $e');
      Get.snackbar('Error', 'Failed to update contact information');
    } finally {
      isContactUpdating.value = false;
    }
  }

  //=========================AI Codes=========================
// ==================== SYNC USER DATA WITH SERVER ====================
  Future<void> syncUserData({bool showLoading = false}) async {
    try {
      if (showLoading) {
        isSyncing.value = true;
      }

      final candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        debugPrint('⚠️ No candidate_id found, skipping sync');
        return;
      }

      debugPrint('🔄 Syncing data for candidate: $candidateId');

      final candidateRef = database.child('candidate/$candidateId');
      final snapshot = await candidateRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        // Profile not found on server - force logout
        await _handleProfileNotFound();
        return;
      }

      final serverData = Map<String, dynamic>.from(snapshot.value as Map);
      profileData.value = serverData;

      // Validate profile status (check if is_active field exists)
      final isActive = serverData['is_active'] ?? true;
      if (!isActive) {
        await _handleInactiveProfile();
        return;
      }

      // Check if profile is complete
      final profileCompleted = serverData['profile_completed'] ?? false;
      if (!profileCompleted) {
        await _handleIncompleteProfile();
        return;
      }

      // Sync subscription data
      await _syncSubscriptionData(serverData);

      // Sync applied jobs
      await _syncAppliedJobs(serverData);

      // Save all data locally
      await _saveCandidateDataToLocal(serverData);

      debugPrint('✅ Data sync completed successfully');

    } catch (e, st) {
      debugPrint('❌ Sync error: $e\n$st');
      Get.snackbar(
        'Sync Error',
        'Could not sync your data. Using offline data.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (showLoading) {
        isSyncing.value = false;
      }
    }
  }

  // ==================== SUBSCRIPTION VALIDATION ====================
  Future<void> _syncSubscriptionData(Map<String, dynamic> serverData) async {
    try {
      // Subscription is stored as nested object
      final subscription = serverData['subscription'];

      if (subscription == null || subscription is! Map) {
        // No subscription found
        subscriptionPlanId.value = '';
        subscriptionStartDate.value = null;
        subscriptionEndDate.value = null;
        isSubscriptionValid.value = false;

        storage.remove('subscription_plan_id');
        storage.remove('subscription_start_date');
        storage.remove('subscription_end_date');

        debugPrint('⚠️ No subscription found');
        return;
      }

      final subMap = Map<String, dynamic>.from(subscription);
      final planId = subMap['plan_id'] ?? '';
      final startDateStr = subMap['start_date'] ?? '';
      final endDateStr = subMap['end_date'] ?? '';

      subscriptionPlanId.value = planId;
      storage.write('subscription_plan_id', planId);

      if (startDateStr.isNotEmpty) {
        final startDate = DateTime.tryParse(startDateStr);
        subscriptionStartDate.value = startDate;
        storage.write('subscription_start_date', startDateStr);
      }

      if (endDateStr.isNotEmpty) {
        final endDate = DateTime.tryParse(endDateStr);
        subscriptionEndDate.value = endDate;
        storage.write('subscription_end_date', endDateStr);

        // Check if subscription is expired
        if (endDate != null && endDate.isBefore(DateTime.now())) {
          await _handleExpiredSubscription();
        }
      }

      _checkSubscriptionValidity();
      storage.write("subscription_status", isSubscriptionValid.value ? "active" : "inactive");
      subscription_status.value = storage.read("subscription_status") ?? "inactive";
      debugPrint('✅ Subscription synced: $planId, expires: $endDateStr');
    } catch (e) {
      debugPrint('⚠️ Error syncing subscription: $e');
    }
  }


  Future<void> _handleExpiredSubscription() async {
    try {
      final candidateId = storage.read('candidate_id');
      if (candidateId == null) return;

      // Remove subscription object from server
      await database.child('candidate/$candidateId/subscription').remove();

      subscriptionPlanId.value = '';
      subscriptionStartDate.value = null;
      subscriptionEndDate.value = null;
      isSubscriptionValid.value = false;

      storage.remove('subscription_plan_id');
      storage.remove('subscription_start_date');
      storage.remove('subscription_end_date');

      Get.snackbar(
        'Subscription Expired',
        'Your subscription has expired. Renew to continue enjoying premium benefits.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/subscriptions'),
          child: const Text('Renew', style: TextStyle(color: Colors.white)),
        ),
      );

      debugPrint('⚠️ Subscription expired, removed from profile');
    } catch (e) {
      debugPrint('❌ Error handling expired subscription: $e');
    }
  }

  // ==================== APPLIED JOBS SYNC ====================
  Future<void> _syncAppliedJobs(Map<String, dynamic> serverData) async {
    try {
      final serverJobs = serverData['applied_jobs'];
      List<String> jobsList = [];

      if (serverJobs != null) {
        if (serverJobs is List) {
          jobsList = serverJobs.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
        } else if (serverJobs is Map) {
          jobsList = serverJobs.values.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
        }
      }

      // Compare with local
      final localJobs = storage.read('applied_jobs') as List? ?? [];
      final localJobsList = localJobs.map((e) => e.toString()).toList();

      // If server has different jobs, update local
      if (jobsList.length != localJobsList.length ||
          !_listsAreEqual(jobsList, localJobsList)) {
        applied_jobs.value = jobsList;
        storage.write('applied_jobs', jobsList);
        debugPrint('✅ Applied jobs synced: ${jobsList.length} jobs');
      }
    } catch (e) {
      debugPrint('⚠️ Error syncing applied jobs: $e');
    }
  }

  bool _listsAreEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    final set1 = Set.from(list1);
    final set2 = Set.from(list2);
    return set1.difference(set2).isEmpty && set2.difference(set1).isEmpty;
  }

  // ==================== PROFILE STATUS HANDLERS ====================
  Future<void> _handleProfileNotFound() async {
    debugPrint('❌ Profile not found on server - forcing logout');

    Get.defaultDialog(
      title: 'Account Not Found',
      middleText: 'Your account could not be found. Please login again.',
      barrierDismissible: false,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          _performLogout();
        },
        child: const Text('Login Again'),
      ),
    );
  }

  Future<void> _handleInactiveProfile() async {
    debugPrint('⚠️ Profile is inactive');

    Get.defaultDialog(
      title: 'Account Inactive',
      middleText: 'Your account has been deactivated. Please contact support for assistance.',
      barrierDismissible: false,
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          _performLogout();
        },
        child: const Text('Contact Support'),
      ),
      cancel: TextButton(
        onPressed: () {
          Get.back();
          _performLogout();
        },
        child: const Text('Logout'),
      ),
    );
  }

  Future<void> _handleIncompleteProfile() async {
    debugPrint('⚠️ Profile incomplete - redirecting to registration');

    Get.snackbar(
      'Complete Your Profile',
      'Please complete your profile to continue',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );

    await Future.delayed(const Duration(seconds: 1));
    Get.offAllNamed('/register');
  }

  // ==================== LOGOUT ====================
  Future<void> _performLogout() async {
    try {
      // Clear all user data
      storage.remove('candidate_id');
      storage.remove('phone');
      storage.remove('otpverified');
      storage.remove('is_logged_in');
      storage.remove('profile_completed');
      storage.remove('subscription_plan_id');
      storage.remove('subscription_start_date');
      storage.remove('subscription_end_date');
      storage.remove('applied_jobs');

      // Clear profile fields
      final profileKeys = [
        'profile_name', 'age', 'gender', 'email', 'profile_pic_url',
        'highestEducation', 'selectedCourse', 'selectedSpecialization',
        'selectedDegree', 'selectedDegreeSpecialization', 'CollageName',
        'Passingyear', 'selectedexperience', 'selectedExperienceYears',
        'selectedCategoryName', 'selectedRole', 'CompanyName', 'selectedWorkingStatus',
        'CurrentSalary', 'selectedDesiredRole', 'skills', 'preferred_city',
        'preferred_locality', 'assets', 'languages', 'resume_path',
        'resume_url', 'address', 'summery', 'desired_role'
      ];

      for (final key in profileKeys) {
        storage.remove(key);
      }

      // Reset reactive variables
      profileData.clear();
      applied_jobs.clear();
      subscriptionPlanId.value = '';
      subscriptionStartDate.value = null;
      subscriptionEndDate.value = null;
      isSubscriptionValid.value = false;

      debugPrint('✅ Logout completed');
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      Get.offAllNamed('/login');
    }
  }

  // ==================== SAVE DATA LOCALLY ====================
  Future<void> _saveCandidateDataToLocal(Map<String, dynamic> data) async {
    try {
      // Basic Info
      storage.write("profile_name", data['profile_name'] ?? '');
      storage.write("age", data['age'] ?? '');
      storage.write("gender", data['gender'] ?? '');
      storage.write("email", data['email'] ?? '');
      storage.write("summery", data['summery'] ?? '');
      storage.write("profile_pic_url", data['profile_pic_url'] ?? '');

      // Education
      storage.write("highestEducation", data['highest_education'] ?? '');
      storage.write("selectedCourse", data['course'] ?? '');
      storage.write("selectedSpecialization", data['specialization'] ?? '');
      storage.write("selectedDegree", data['degree'] ?? '');
      storage.write("selectedDegreeSpecialization", data['degree_specialization'] ?? '');
      storage.write("CollageName", data['college_name'] ?? '');
      storage.write("Passingyear", data['passing_year'] ?? '');

      // Experience
      storage.write("selectedexperience", data['experience_type'] ?? '');
      storage.write("selectedExperienceYears", data['experience_years'] ?? '');
      storage.write("selectedCategory", data['current_category'] ?? '');
      storage.write("selectedRole", data['current_role'] ?? '');
      storage.write("CompanyName", data['company_name'] ?? '');
      storage.write("selectedWorkingStatus", data['working_status'] ?? '');
      storage.write("CurrentSalary", data['current_salary'] ?? '');

      // Job Preferences (note: desired_role not desired_category in second occurrence)
      storage.write("selectedDesiredCategory", data['desired_category'] ?? '');
      storage.write("selectedDesiredRole", data['desired_role'] ?? '');
      storage.write("skills", data['skills'] ?? []);

      // Additional Info
      storage.write("preferred_city", data['preferred_city'] ?? '');
      storage.write("preferred_locality", data['preferred_locality'] ?? '');
      storage.write("assets", data['assets'] ?? []);
      storage.write("languages", data['languages'] ?? []);
      storage.write("resume_path", data['resume_path'] ?? '');
      storage.write("resume_url", data['resume_url'] ?? '');
      storage.write("address", data['address'] ?? '');
      storage.write("summery", data['summery'] ?? '');

      // Subscription (nested object)
      final subscription = data['subscription'];
      if (subscription != null && subscription is Map) {
        final subMap = Map<String, dynamic>.from(subscription);
        storage.write("subscription_plan_id", subMap['plan_id'] ?? '');
        storage.write("subscription_start_date", subMap['start_date'] ?? '');
        storage.write("subscription_end_date", subMap['end_date'] ?? '');
      }

      // Applied Jobs
      storage.write("applied_jobs", data['applied_jobs'] ?? []);

      // Profile completion flag
      storage.write("profile_completed", data['profile_completed'] ?? true);

      debugPrint('✅ All data saved locally');
    } catch (e) {
      debugPrint('❌ Error saving data locally: $e');
    }
  }

  Future<void> updateSummary() async {
    final String summary = SummeryController.text.trim();

    // Validation
    if (summary.isEmpty) {
      Get.snackbar('Validation', 'Please add a summary');
      return;
    }

    if (summary.length > 500) {
      Get.snackbar('Validation', 'Summary cannot be more than 500 characters');
      return;
    }

    try {
      isSummaryUpdating.value = true;

      // Get candidate/user id from storage
      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      // Update in Firebase Realtime Database
      await database.child('candidate').child(candidateId).update({
        'summery': summary, // key matches your local save function
      });

      // Update local storage
      storage.write('summery', summary);

      Get.snackbar('Success', 'Summary updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating summary: $e');
      Get.snackbar('Error', 'Failed to update summary');
    } finally {
      isSummaryUpdating.value = false;
    }
  }

  Future<void> updateWorkExperience() async {
    // Reset previous errors
    SelectExpError.value = '';
    ExperienceError.value = '';
    selectcatError.value = '';
    selectroleError.value = '';
    companynameError.value = '';
    workingError.value = '';
    salaryError.value = '';

    // 1) Basic selection (experience Yes/No)
    if (selectedexperience.value.isEmpty) {
      SelectExpError.value = 'Please select if you have work experience';
      Get.snackbar('Validation', 'Please select if you have work experience');
      return;
    }

    // If user selects "No", simply clear experience details
    if (selectedexperience.value == 'No') {
      try {
        isWorkExperienceUpdating.value = true;

        final String? candidateId = storage.read('candidate_id');
        if (candidateId == null) {
          Get.snackbar('Error', 'User not logged in');
          return;
        }

        final Map<String, dynamic> updateMap = {
          'experience_type': 'No',
          'experience_years': '',
          'current_category': '',
          'current_role': '',
          'company_name': '',
          'working_status': '',
          'current_salary': '',
          'updated_on': DateTime.now().toIso8601String(),
        };

        await database.child('candidate').child(candidateId).update(updateMap);

        // Local storage sync
        storage.write('experience_type', 'No');
        storage.write('experience_years', '');
        storage.write('current_category', '');
        storage.write('current_role', '');
        storage.write('CompanyName', '');
        storage.write('selectedWorkingStatus', '');
        storage.write('CurrentSalary', '');

        Get.snackbar('Success', 'Work experience updated successfully');
      } catch (e) {
        debugPrint('❌ Error updating work experience: $e');
        Get.snackbar('Error', 'Failed to update work experience');
      } finally {
        isWorkExperienceUpdating.value = false;
      }
      return;
    }

    // 2) If "Yes", validate all fields
    bool hasError = false;

    if (selectedExperience.value.isEmpty) {
      ExperienceError.value = 'Please select total years of experience';
      hasError = true;
    }

    if (selectedCategoryName.value.isEmpty) {
      selectcatError.value = 'Please select job category';
      hasError = true;
    }

    if (selectedRole.value.isEmpty) {
      selectroleError.value = 'Please select job role';
      hasError = true;
    }

    final companyName = CompanyController.text.trim();
    if (companyName.isEmpty) {
      companynameError.value = 'Please enter company name';
      hasError = true;
    }

    if (selectedworking.value.isEmpty) {
      workingError.value = 'Please select working status';
      hasError = true;
    }

    final salary = CurrentSalaryController.text.trim();
    if (salary.isEmpty) {
      salaryError.value = 'Please enter current monthly salary';
      hasError = true;
    }

    if (hasError) {
      Get.snackbar('Validation', 'Please fill all required work experience fields');
      return;
    }

    // 3) Save to Firebase
    try {
      isWorkExperienceUpdating.value = true;

      final String? candidateId = storage.read('candidate_id');
      if (candidateId == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      final Map<String, dynamic> updateMap = {
        'experience_type': 'Yes',
        'experience_years': selectedExperience.value,
        'current_category': selectedCategoryName.value,
        'current_role': selectedRole.value,
        'company_name': companyName,
        'working_status': selectedworking.value,
        'current_salary': salary,
        'updated_on': DateTime.now().toIso8601String(),
      };

      // Use "candidate" node as per your DB export
      await database.child('candidate').child(candidateId).update(updateMap);

      // Update local storage (keys aligned to your _saveCandidateDataToLocal)
      storage.write('selectedexperience', 'Yes');
      storage.write('selectedExperienceYears', selectedExperience.value);
      storage.write('selectedCategoryName', selectedCategoryName.value);
      storage.write('selectedCategorySlug', selectedCategorySlug.value);
      storage.write('selectedRole', selectedRole.value);
      storage.write('CompanyName', companyName);
      storage.write('selectedWorkingStatus', selectedworking.value);
      storage.write('CurrentSalary', salary);

      Get.snackbar('Success', 'Work experience updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating work experience: $e');
      Get.snackbar('Error', 'Failed to update work experience');
    } finally {
      isWorkExperienceUpdating.value = false;
    }
  }
  // ==================== PUBLIC METHODS ====================

  /// Manual refresh - call this on pull-to-refresh
  Future<void> refreshUserData() async {
    await syncUserData(showLoading: true);
  }

  /// Check if user can apply for jobs (based on subscription and limits)
  bool canApplyForJobs({int? freeLimit}) {
    if (isSubscriptionValid.value) {
      return true; // Subscribed users have unlimited applies
    }

    if (freeLimit == null) {
      return true; // No limit set means unlimited
    }

    return applied_jobs.length < freeLimit;
  }

  /// Get remaining free applications
  int getRemainingFreeApplications(int freeLimit) {
    if (isSubscriptionValid.value) {
      return -1; // Unlimited
    }
    return (freeLimit - applied_jobs.length).clamp(0, freeLimit);
  }

  /// Force logout (can be called from UI)
  Future<void> logout() async {
    await _performLogout();
  }

  /// Update local applied jobs when user applies successfully
  void addAppliedJob(String jobId) {
    if (!applied_jobs.contains(jobId)) {
      applied_jobs.add(jobId);
      storage.write('applied_jobs', applied_jobs);
      debugPrint('✅ Added applied job: $jobId, total: ${applied_jobs.length}');
    }
  }

  // ==================== GETTERS ====================

 // String get subscriptionstatus => isSubscriptionValid.value ? 'active' : 'inactive';
  List<String> get appliedjobs => applied_jobs;
 // bool get is_subscribed => isSubscriptionValid.value;
 // int get applied_jobs_count => applied_jobs.length;
 // String get subscription_plan_id => subscriptionPlanId.value;
 // DateTime? get subscription_end_date => subscriptionEndDate.value;

  // ✅ Corrected getters
  String get subscriptionstatus => storage.read("subscription_status") ?? "inactive";
  bool get is_subscribed => isSubscriptionValid.value;
  int get applied_jobs_count => applied_jobs.length;
  String get subscription_plan_id => subscriptionPlanId.value;
  DateTime? get subscription_end_date => subscriptionEndDate.value;


  // Days remaining in subscription
  int get subscription_days_remaining {
    if (subscriptionEndDate.value == null) return 0;
    final diff = subscriptionEndDate.value!.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }


}
