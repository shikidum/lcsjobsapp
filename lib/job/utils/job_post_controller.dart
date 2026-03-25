import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../job_pages/job_authentication/job_loginoption.dart';

class JobPostController extends GetxController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  final storage = GetStorage(); // 🔐 local storage
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

  var salaryError = ''.obs;
  var bonusError = ''.obs;
  var staffError = ''.obs;

  var bonus = false.obs;
  final minSalaryController = TextEditingController();
  final maxSalaryController = TextEditingController();
  final bonusAmountController = TextEditingController();
  final bonusTypeController = TextEditingController();
  final staffCountController = TextEditingController();

/// Step 2
  var experienceType = ''.obs;
  var minExperienceOptions = ['Fresher', '6 months', '1 year', '2 years', '3 years', '5 years'];
  var maxExperienceOptions = ['1 year', '2 years', '3 years', '5 years','more than 5 years'];
  var selectedMinExp = ''.obs;
  var selectedMaxExp = ''.obs;

  var qualificationOptions = ['10th pass', '12th pass or above', 'Graduate / Post Graduate'];
  var selectedQualification = ''.obs;

  var selectedGender = 'Both'.obs;
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
  final CompanyAddressController = TextEditingController();
  var JopRepeat = ''.obs;

  var JobRepeatOptions = ['Once in a Year', 'Once in a few Months', 'Once or Twice every Month', 'Hiring New People Everyday'];

  var companyNameError = ''.obs;
  var contactPersonError = ''.obs;
  var EmailIdError = ''.obs;
  var PhoneNoError = ''.obs;
  var CompanyAddressError = ''.obs;
  var JopRepeatError = ''.obs;

  void resetForm() {
    // Optional: clear all fields if needed
  }

  var isSubmitting = false.obs;
 // var enteredOtp = ''.obs;
  var generatedOtp = ''.obs;

  @override
  void onInit() {
    fetchCategories();
    fetchCities();
    super.onInit();
    _loadSavedValues(); // Load previously saved data when controller is initialized
    _loadStepTwoValues();
  }

  final RxString verificationId = ''.obs;
  final RxString enteredOtp = ''.obs;

  Future<void> sendOtpToPhone(String phoneNumber) async {
    final trimmed = phoneNumber.trim();

    if (trimmed.length != 10) {
      Get.snackbar("Invalid Number", "Please enter a valid 10-digit phone number.");
      isSubmitting.value = false; // important if you set it before
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$trimmed',
      timeout: const Duration(seconds: 60),

      verificationCompleted: (PhoneAuthCredential credential) async {
        // For this flow, we don't want auto-complete login.
        // You can either ignore this OR treat it as "verified" silently.
        try {
          await _auth.signInWithCredential(credential);
          // Optional: immediately sign out so it doesn’t affect your main login state
          await _auth.signOut();
          // You could set a flag like isOtpVerified.value = true if needed.
        } catch (_) {}
      },

      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message ?? "OTP sending failed");
        isSubmitting.value = false;
      },

      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        // We don’t change isSubmitting here – we handle it in the UI after verify/cancel.
      },

      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
      },
    );
  }

  /// Returns true if OTP is correct, false otherwise
  Future<bool> verifyOtp(String enteredOtp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOtp,
      );

      await _auth.signInWithCredential(credential);
      // Immediately sign out so this doesn't act as an app login
      await _auth.signOut();

      return true;
    } catch (e) {
      return false;
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
  void _loadSavedValues() {
    // Dropdowns
    selectedCategoryName.value = storage.read('job_category') ?? '';
    selectedCategorySlug.value = storage.read('job_category_slug') ?? '';
    selectedRole.value = storage.read('job_role') ?? '';
    selectedCity.value = storage.read('job_city') ?? '';
    selectedLocality.value = storage.read('job_locality') ?? '';

    // Trigger dependent dropdown fetches
    if (selectedCategoryName.value.isNotEmpty) fetchRoles(selectedCategorySlug.value);
    if (selectedCity.value.isNotEmpty) fetchLocalities(selectedCity.value);

    // Salary and staff count fields
    minSalaryController.text = storage.read('salary_min') ?? '';
    maxSalaryController.text = storage.read('salary_max') ?? '';
    staffCountController.text = storage.read('staff_count') ?? '';

    // Bonus values
    bonus.value = storage.read('bonus_enabled') ?? false;

    if (bonus.value) {
      bonusAmountController.text = storage.read('bonus_amount') ?? '';
      bonusTypeController.text = storage.read('bonus_type') ?? '';
    } else {
      bonusAmountController.clear();
      bonusTypeController.clear();
    }
  }
  void _loadStepTwoValues() {
    experienceType.value = storage.read('experience_type') ?? '';
    selectedMinExp.value = storage.read('min_experience') ?? '';
    selectedMaxExp.value = storage.read('max_experience') ?? '';
    selectedQualification.value = storage.read('qualification') ?? '';
    selectedGender.value = storage.read('gender') ?? 'Both';
    selectedEnglishSkill.value = storage.read('english_skill') ?? '';
    selectedSkills.value = List<String>.from(storage.read('skills') ?? []);
    callDistance.value = storage.read('call_distance') ?? '';
    isWorkFromHome.value = storage.read('work_from_home') ?? false;
    securityDeposit.value = storage.read('security_deposit') ?? false;
    selectedCallDays.value = storage.read('call_days') ?? '';
    jobRoleController.text = storage.read('job_role_description') ?? '';
    timingsController.text = storage.read('work_timings') ?? '09:30 am - 6:30pm | Monday to Saturday';
    interviewTimingsController.text = storage.read('interview_timings') ?? '11:00 am - 4:00pm | Monday to Saturday';
  }

  void saveCurrentStepLocally() {
    // Dropdown fields
    storage.write('job_category', selectedCategoryName.value);
    storage.write('job_category_slug', selectedCategorySlug.value);
    storage.write('job_role', selectedRole.value);
    storage.write('job_city', selectedCity.value);
    storage.write('job_locality', selectedLocality.value);

    // Text input fields
    storage.write('salary_min', minSalaryController.text.trim());
    storage.write('salary_max', maxSalaryController.text.trim());
    storage.write('staff_count', staffCountController.text.trim());

    // Bonus
    storage.write('bonus_enabled', bonus.value);

    if (bonus.value) {
      storage.write('bonus_amount', bonusAmountController.text.trim());
      storage.write('bonus_type', bonusTypeController.text.trim());
    } else {
      storage.remove('bonus_amount');
      storage.remove('bonus_type');
    }
  }
  void saveStepTwoData() {
    storage.write('experience_type', experienceType.value);
    storage.write('min_experience', selectedMinExp.value);
    storage.write('max_experience', selectedMaxExp.value);
    storage.write('qualification', selectedQualification.value);
    storage.write('gender', selectedGender.value);
    storage.write('english_skill', selectedEnglishSkill.value);
    storage.write('skills', selectedSkills.toList());
    storage.write('call_distance', callDistance.value);
    storage.write('work_from_home', isWorkFromHome.value);
    storage.write('security_deposit', securityDeposit.value);
    storage.write('call_days', selectedCallDays.value);
    storage.write('job_role_description', jobRoleController.text.trim());
    storage.write('work_timings', timingsController.text.trim());
    storage.write('interview_timings', interviewTimingsController.text.trim());
  }

  void clearAllSavedJobData() {
    // Step 1
    storage.remove('job_category');
    storage.remove('job_category_slug');
    storage.remove('job_role');
    storage.remove('job_city');
    storage.remove('job_locality');
    storage.remove('salary_min');
    storage.remove('salary_max');
    storage.remove('staff_count');
    storage.remove('bonus_enabled');
    storage.remove('bonus_amount');
    storage.remove('bonus_type');

    // Step 2
    storage.remove('experience_type');
    storage.remove('min_experience');
    storage.remove('max_experience');
    storage.remove('qualification');
    storage.remove('gender');
    storage.remove('english_skill');
    storage.remove('skills');
    storage.remove('call_distance');
    storage.remove('work_from_home');
    storage.remove('security_deposit');
    storage.remove('call_days');
    storage.remove('job_role_description');
    storage.remove('work_timings');
    storage.remove('interview_timings');

    // Step 3
    storage.remove('company_name');
    storage.remove('contact_person');
    storage.remove('email');
    storage.remove('phone');
    storage.remove('address');
    storage.remove('job_repeat');

    // Extra
    storage.remove('job_title');
    storage.remove('job_experience');
    storage.remove('job_salary');
    storage.remove('job_description');
    // Navigate to JobLoginOptionScreen after clearing
    Get.offAll(() => JobLoginoption());
  }

  // Future<void> submitJobPost() async {
  //   final settingsRef = database.child('company_settings/last_job_code');
  //   // Read the last job code (default 1000 if not set)
  //   final snapshot = await settingsRef.get();
  //   int lastJobCode = 1000;
  //   if (snapshot.exists && snapshot.value != null) {
  //     if (snapshot.value is int) {
  //       lastJobCode = snapshot.value as int;
  //     } else if (snapshot.value is String) {
  //       lastJobCode = int.tryParse(snapshot.value as String) ?? 1000;
  //     }
  //   }
  //   // Increment
  //   final newJobCode = lastJobCode + 1;
  //   // Update counter in Firebase
  //   await settingsRef.set(newJobCode);
  //
  //   try {
  //     final String jobId = database.child('jobs').push().key!;
  //     final jobData = {
  //       'job_id': jobId,
  //       'job_code': newJobCode,
  //       'category': selectedCategoryName.value,
  //       'role': selectedRole.value,
  //       'city': selectedCity.value,
  //       'locality': selectedLocality.value,
  //       'min_salary': minSalaryController.text.trim(),
  //       'max_salary': maxSalaryController.text.trim(),
  //       'staff_count': staffCountController.text.trim(),
  //       'bonus_enabled': bonus.value,
  //       'bonus_amount': bonusAmountController.text.trim(),
  //       'bonus_type': bonusTypeController.text.trim(),
  //       'experience_type': experienceType.value,
  //       'min_experience': selectedMinExp.value,
  //       'max_experience': selectedMaxExp.value,
  //       'qualification': selectedQualification.value,
  //       'gender': selectedGender.value,
  //       'english_skill': selectedEnglishSkill.value,
  //       'skills': selectedSkills.toList(),
  //       'call_distance': callDistance.value,
  //       'work_from_home': isWorkFromHome.value,
  //       'security_deposit': securityDeposit.value,
  //       'call_days': selectedCallDays.value,
  //       'job_role_description': jobRoleController.text.trim(),
  //       'work_timings': timingsController.text.trim(),
  //       'interview_timings': interviewTimingsController.text.trim(),
  //       'company_name': CompanyController.text.trim(),
  //       'contact_person': ContactPersonController.text.trim(),
  //       'email': EmailIdController.text.trim(),
  //       'phone': PhoneNoController.text.trim(),
  //       'address': CompanyAddressController.text.trim(),
  //       'job_repeat': JopRepeat.value,
  //       'job_status':'Open',
  //       'isapproved':false,
  //       'posted_on': DateTime.now().toIso8601String(),
  //     };
  //     // Save to Firebase
  //     await database.child('jobs').child(jobId).set(jobData);
  //     // Build HTML email with job details
  //     final emailBody = """
  //     <h2>Thanks for posting your job with LCS Jobs!</h2>
  //     <p>Here are your job details:</p>
  //     <table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; font-family: Arial, sans-serif; font-size: 14px;">
  //       <tr><th align="left">Category</th><td>${selectedCategoryName.value}</td></tr>
  //       <tr><th align="left">Role</th><td>${selectedRole.value}</td></tr>
  //       <tr><th align="left">City</th><td>${selectedCity.value}</td></tr>
  //       <tr><th align="left">Locality</th><td>${selectedLocality.value}</td></tr>
  //       <tr><th align="left">Salary</th><td>${minSalaryController.text.trim()} - ${maxSalaryController.text.trim()}</td></tr>
  //       <tr><th align="left">Bonus</th><td>${bonus.value ? "${bonusAmountController.text.trim()} (${bonusTypeController.text.trim()})" : "No Bonus"}</td></tr>
  //       <tr><th align="left">Staff Count</th><td>${staffCountController.text.trim()}</td></tr>
  //       <tr><th align="left">Experience</th><td>${experienceType.value} (${selectedMinExp.value} - ${selectedMaxExp.value})</td></tr>
  //       <tr><th align="left">Qualification</th><td>${selectedQualification.value}</td></tr>
  //       <tr><th align="left">Gender</th><td>${selectedGender.value}</td></tr>
  //       <tr><th align="left">English</th><td>${selectedEnglishSkill.value}</td></tr>
  //       <tr><th align="left">Skills</th><td>${selectedSkills.join(', ')}</td></tr>
  //       <tr><th align="left">Work From Home</th><td>${isWorkFromHome.value ? "Yes" : "No"}</td></tr>
  //       <tr><th align="left">Security Deposit</th><td>${securityDeposit.value ? "Yes" : "No"}</td></tr>
  //       <tr><th align="left">Call Days</th><td>${selectedCallDays.value}</td></tr>
  //       <tr><th align="left">Timings</th><td>${timingsController.text.trim()}</td></tr>
  //       <tr><th align="left">Interview Timing</th><td>${interviewTimingsController.text.trim()}</td></tr>
  //       <tr><th align="left">Company Name</th><td>${CompanyController.text.trim()}</td></tr>
  //       <tr><th align="left">Contact Person</th><td>${ContactPersonController.text.trim()}</td></tr>
  //       <tr><th align="left">Phone</th><td>${PhoneNoController.text.trim()}</td></tr>
  //       <tr><th align="left">Address</th><td>${CompanyAddressController.text.trim()}</td></tr>
  //       <tr><th align="left">Repeat Hiring</th><td>${JopRepeat.value}</td></tr>
  //     </table>
  //     <br><p>We will review and publish your job shortly.</p>
  //     <p>Thanks,<br><b>LCS Jobs</b> Team</p>
  //   """;
  //
  //     // Send email
  //     await sendJobEmail(
  //       toEmail: EmailIdController.text.trim(),
  //       subject: "Your Job Post Has Been Received - LCS Jobs",
  //       body: emailBody,
  //         jobid:jobId
  //     );
  //
  //     Get.snackbar("Success", "Job posted successfully & confirmation email sent.",
  //         backgroundColor: Colors.green, colorText: Colors.white);
  //     clearAllSavedJobData();
  //   } catch (e) {
  //     Get.snackbar("Error", "Something went wrong: $e");
  //   }
  // }
  Future<void> submitJobPost() async {

    final settingsRef = database.child('company_settings/last_job_code');

    final snapshot = await settingsRef.get();

    int lastJobCode = 1000;

    if (snapshot.exists && snapshot.value != null) {
      if (snapshot.value is int) {
        lastJobCode = snapshot.value as int;
      } else if (snapshot.value is String) {
        lastJobCode = int.tryParse(snapshot.value as String) ?? 1000;
      }
    }

    final newJobCode = lastJobCode + 1;

    await settingsRef.set(newJobCode);

    try {

      final String jobId = database.child('jobs').push().key!;

      final category = selectedCategoryName.value.trim().toLowerCase();
      final city = selectedCity.value.trim().toLowerCase();

      /// 🔹 Build index key (same format as your index database)
      final indexKey = "${category}_${city}";

      final jobData = {
        'job_id': jobId,
        'job_code': newJobCode,
        'category': selectedCategoryName.value,
        'role': selectedRole.value,
        'city': selectedCity.value,
        'locality': selectedLocality.value,
        'min_salary': minSalaryController.text.trim(),
        'max_salary': maxSalaryController.text.trim(),
        'staff_count': staffCountController.text.trim(),
        'bonus_enabled': bonus.value,
        'bonus_amount': bonusAmountController.text.trim(),
        'bonus_type': bonusTypeController.text.trim(),
        'experience_type': experienceType.value,
        'min_experience': selectedMinExp.value,
        'max_experience': selectedMaxExp.value,
        'qualification': selectedQualification.value,
        'gender': selectedGender.value,
        'english_skill': selectedEnglishSkill.value,
        'skills': selectedSkills.toList(),
        'call_distance': callDistance.value,
        'work_from_home': isWorkFromHome.value,
        'security_deposit': securityDeposit.value,
        'call_days': selectedCallDays.value,
        'job_role_description': jobRoleController.text.trim(),
        'work_timings': timingsController.text.trim(),
        'interview_timings': interviewTimingsController.text.trim(),
        'company_name': CompanyController.text.trim(),
        'contact_person': ContactPersonController.text.trim(),
        'email': EmailIdController.text.trim(),
        'phone': PhoneNoController.text.trim(),
        'address': CompanyAddressController.text.trim(),
        'job_repeat': JopRepeat.value,
        'job_status': 'Open',
        'isapproved': false,
        'posted_on': DateTime.now().toIso8601String(),
      };

      /// 🔹 MULTI PATH UPDATE (best Firebase practice)

      Map<String, dynamic> updates = {};

      updates["jobs/$jobId"] = jobData;

      /// 🔹 create job index
      updates["job_index/$indexKey/$jobId"] = true;

      await database.update(updates);

      /// 🔹 EMAIL

      final emailBody = """
<h2>Thanks for posting your job with LCS Jobs!</h2>
<p>Here are your job details:</p>

<table border="1" cellpadding="8" cellspacing="0" style="border-collapse: collapse; font-family: Arial; font-size:14px;">

<tr><th align="left">Category</th><td>${selectedCategoryName.value}</td></tr>
<tr><th align="left">Role</th><td>${selectedRole.value}</td></tr>
<tr><th align="left">City</th><td>${selectedCity.value}</td></tr>
<tr><th align="left">Locality</th><td>${selectedLocality.value}</td></tr>

<tr><th align="left">Salary</th>
<td>${minSalaryController.text.trim()} - ${maxSalaryController.text.trim()}</td></tr>

<tr><th align="left">Bonus</th>
<td>${bonus.value ? "${bonusAmountController.text.trim()} (${bonusTypeController.text.trim()})" : "No Bonus"}</td></tr>

<tr><th align="left">Staff Count</th>
<td>${staffCountController.text.trim()}</td></tr>

<tr><th align="left">Experience</th>
<td>${experienceType.value} (${selectedMinExp.value} - ${selectedMaxExp.value})</td></tr>

<tr><th align="left">Qualification</th>
<td>${selectedQualification.value}</td></tr>

<tr><th align="left">Gender</th>
<td>${selectedGender.value}</td></tr>

<tr><th align="left">English</th>
<td>${selectedEnglishSkill.value}</td></tr>

<tr><th align="left">Skills</th>
<td>${selectedSkills.join(', ')}</td></tr>

<tr><th align="left">Work From Home</th>
<td>${isWorkFromHome.value ? "Yes" : "No"}</td></tr>

<tr><th align="left">Security Deposit</th>
<td>${securityDeposit.value ? "Yes" : "No"}</td></tr>

<tr><th align="left">Call Days</th>
<td>${selectedCallDays.value}</td></tr>

<tr><th align="left">Timings</th>
<td>${timingsController.text.trim()}</td></tr>

<tr><th align="left">Interview Timing</th>
<td>${interviewTimingsController.text.trim()}</td></tr>

<tr><th align="left">Company Name</th>
<td>${CompanyController.text.trim()}</td></tr>

<tr><th align="left">Contact Person</th>
<td>${ContactPersonController.text.trim()}</td></tr>

<tr><th align="left">Phone</th>
<td>${PhoneNoController.text.trim()}</td></tr>

<tr><th align="left">Address</th>
<td>${CompanyAddressController.text.trim()}</td></tr>

<tr><th align="left">Repeat Hiring</th>
<td>${JopRepeat.value}</td></tr>

</table>

<br>
<p>We will review and publish your job shortly.</p>

<p>Thanks,<br><b>LCS Jobs</b> Team</p>
""";

      await sendJobEmail(
        toEmail: EmailIdController.text.trim(),
        subject: "Your Job Post Has Been Received - LCS Jobs",
        body: emailBody,
        jobid: jobId,
      );

      Get.snackbar(
        "Success",
        "Job posted successfully & confirmation email sent.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      clearAllSavedJobData();

    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    }
  }
  Future<void> sendJobEmail({
    required String toEmail,
    required String subject,
    required String body,
    required String jobid,
  }) async
  {
    final url = Uri.parse("https://panel.laxmiconsultancyservices.com/send_job_email.php");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "toEmail": toEmail,
          "subject": subject,
          "body": body,
          "jobid": jobid,
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Email sent: ${response.body}");
      } else {
        print("❌ Failed: ${response.body}");
      }
    } catch (e) {
      print("Error sending email: $e");
    }
  }

}
