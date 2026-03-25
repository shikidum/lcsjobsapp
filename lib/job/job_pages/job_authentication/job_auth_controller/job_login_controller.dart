import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:lcsjobs/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../utils/Constants.dart';

class JobLoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final DatabaseReference subsRef = FirebaseDatabase.instance.ref('subscriptions');
  final DatabaseReference userRef = FirebaseDatabase.instance.ref('candidate');

  final storage = GetStorage();

  var phoneNumber = ''.obs;
  var otpCode = ''.obs;
  var verificationId = ''.obs;
  var isLoading = false.obs;
  var isOtpSent = false.obs;

  var enteredOtp = ''.obs;
  var generatedOtp = ''.obs;

  final TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> saveFcmTokenForCandidate(String candidateId) async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (especially important on iOS, harmless on Android)
      await messaging.requestPermission();

      final token = await messaging.getToken();
      if (token == null) {
        print("⚠️ FCM token is null, not saving.");
        return;
      }

      // Save to Realtime Database under candidate/{id}
      await database.child('candidate').child(candidateId).update({
        'fcm_token': token,
        'fcm_updated_at': DateTime.now().toIso8601String(),
      });

      // Optionally save locally
      storage.write('fcm_token', token);

      print("✅ FCM token saved for candidate $candidateId: $token");
    } catch (e) {
      print("🔴 Failed to save FCM token: $e");
    }
  }

  void onLoginSuccess(BuildContext context) async {
    try {
      isLoading.value = true;
      final phone = phoneNumber.value;
      final candidateRef = database.child("candidate");

      bool found = false;
      String? existingKey;
      Map<String, dynamic>? userData;

      final snapshot = await candidateRef.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          if (value['phone'] == phone) {
            found = true;
            existingKey = key;
            userData = Map<String, dynamic>.from(value);
          }
        });
      }

      // Save basic info
      storage.write("phone", phone);
      storage.write("otpverified", true);

      if (found) {
        storage.write("candidate_id", existingKey);
        // 🔹 Save FCM token for this candidate
        await saveFcmTokenForCandidate(existingKey!);
        if (userData?['profile_completed'] == true) {
          storage.write('is_logged_in', true);
          await saveCandidateDataToLocal(userData!); // ⬅️ SAVE EVERYTHING LOCALLY
          Get.offAllNamed("/dashboard");
        } else {
          Get.offAllNamed("/register"); // Incomplete profile
        }
      } else {

        final settingsRef = database.child('company_settings/last_candidate_code');
        // Read the last job code (default 1000 if not set)
        final snapshot = await settingsRef.get();
        int lastcandidatecode = 2000;
        if (snapshot.exists && snapshot.value != null) {
          if (snapshot.value is int) {
            lastcandidatecode = snapshot.value as int;
          } else if (snapshot.value is String) {
            lastcandidatecode = int.tryParse(snapshot.value as String) ?? 1000;
          }
        }
        // Increment
        final newCandidateCode = lastcandidatecode + 1;
        // Update counter in Firebase
        await settingsRef.set(newCandidateCode);

        final newKey = candidateRef.push().key;
        await candidateRef.child(newKey!).set({
          'phone': phone,
          'code': newCandidateCode,
          'created_at': DateTime.now().toIso8601String(),
          'profile_completed': false,
        });
        storage.write("candidate_id", newKey);
        await saveFcmTokenForCandidate(newKey);
        Get.offAllNamed("/register");
      }
    } catch (e) {
      Get.snackbar("Login Error", "Something went wrong while logging in");
      print("🔴 Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
    storage.write("desired_category", data['desired_category']);
    storage.write("desired_role", data['desired_role']);
    storage.write("skills", data['skills'] ?? []);

    // Step 5
    storage.write("preferred_city", data['preferred_city']);
    storage.write("preferred_locality", data['preferred_locality']);
    storage.write("assets", data['assets'] ?? []);
    storage.write("languages", data['languages'] ?? []);
    storage.write("resume_path", data['resume_path'] ?? '');
    storage.write("resume_url", data['resume_url'] ?? '');
    storage.write("address", data['address'] ?? '');
    storage.write("summery", data['summery'] ?? '');

    storage.write("subscription_status", data?['subscription_status'] ?? 'inactive');
    storage.write("applied_jobs", data?['applied_jobs'] ?? []);
    // 🔹 Optional: cache fcm_token from DB if present
    if (data['fcm_token'] != null) {
      storage.write('fcm_token', data['fcm_token']);
    }
    // Optional flag
    storage.write("profile_completed", true);
  }

  void logout() async {
    storage.erase();
    Get.offAllNamed("/login");
  }

  void sendOtp(String number, BuildContext context) async {
    final trimmed = number.trim();
    // optional validation
    if (trimmed.length != 10) {
      Get.snackbar("Invalid Number", "Please enter a valid 10-digit phone number.");
      return;
    }

    isLoading.value = true;
    phoneNumber.value = trimmed; // keep same behavior as old flow

    await _auth.verifyPhoneNumber(
      phoneNumber: "+91$trimmed",
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          await _auth.signInWithCredential(credential);
          onLoginSuccess(context);
        } catch (e) {
          Get.snackbar("Error", "Auto verification failed. Please try manually.");
        } finally {
          isLoading.value = false;
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar("Error", e.message ?? "OTP Verification Failed");
        isLoading.value = false;
      },
      codeSent: (String verId, int? resendToken) {
        verificationId.value = verId;
        isOtpSent.value = true;
        isLoading.value = false;
        Get.toNamed("/otp");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId.value = verId;
        isLoading.value = false;
      },
    );
  }

  void verifyOtp(String enteredOtp, BuildContext context) async {
    isLoading.value = true;
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOtp,
      );

      await _auth.signInWithCredential(credential);
      onLoginSuccess(context);
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Invalid OTP", e.message ?? "Please try again");
    } catch (e) {
      Get.snackbar("Error", "Something went wrong. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

// void sendOtp(String number, BuildContext context) async {
  //   isLoading.value = true;
  //   await _auth.verifyPhoneNumber(
  //     phoneNumber: "+91$number",
  //     timeout: const Duration(seconds: 60),
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       await _auth.signInWithCredential(credential);
  //       onLoginSuccess(context);
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       Get.snackbar("Error", e.message ?? "OTP Verification Failed");
  //       isLoading.value = false;
  //     },
  //     codeSent: (String verId, int? resendToken) {
  //       verificationId.value = verId;
  //       isOtpSent.value = true;
  //       isLoading.value = false;
  //       Get.toNamed("/otp"); // or push to your OTP screen
  //     },
  //     codeAutoRetrievalTimeout: (String verId) {
  //       verificationId.value = verId;
  //       isLoading.value = false;
  //     },
  //   );
  // }
  //
  // void verifyOtp(String enteredOtp, BuildContext context) async {
  //   try {
  //     isLoading.value = true;
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId.value,
  //       smsCode: enteredOtp,
  //     );
  //
  //     await _auth.signInWithCredential(credential);
  //       onLoginSuccess(context);
  //
  //   } catch (e) {
  //     Get.snackbar("Invalid OTP", "Please try again");
  //     isLoading.value = false;
  //   }
  // }

  // void _onLoginSuccess(BuildContext context) {
  //   final user = _auth.currentUser;
  //   if (user != null) {
  //   storage.write("user_phone", user.phoneNumber);
  //   storage.write("is_logged_in", true);
  //   storage.write("user_phone", phoneNumber.value);
  //   storage.write("is_logged_in", true);
  //    }
  // }

  // void logout() async {
  //   await _auth.signOut();
  //   storage.erase();
  //   Get.offAllNamed("/login");
  // }
}
