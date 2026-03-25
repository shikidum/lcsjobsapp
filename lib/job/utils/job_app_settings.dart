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
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';


class JobAppController extends GetxController {
  final database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
    'https://lcsjobs-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  final storage = GetStorage(); // 🔐 local storage

  // app settings reactive map
  var appsettings = <String, dynamic>{}.obs;

  // loading state for settings fetch
  var isLoadingSettings = false.obs;

  // generic loading indicator used by other long ops
  var isLoadingMore = false.obs;

  // storage key
  static const _kSettingsKey = 'company_settings';

  @override
  void onInit() {
    super.onInit();
    // Load settings from local storage immediately on init
    loadSettingsFromLocal();
    // Then fetch fresh data from Firebase
    fetchSettings();
  }

  T getSettingFromLocal<T>(String key, T defaultValue) {
    final raw = storage.read(_kSettingsKey);
    if (raw == null || raw is! Map) return defaultValue;

    final dynamic val = raw[key];
    if (val == null) return defaultValue;

    try {
      return val as T;
    } catch (e) {
      // convert common types
      if (T == int) {
        if (val is String) return int.tryParse(val) as T? ?? defaultValue;
        if (val is num) return val.toInt() as T;
      } else if (T == double) {
        if (val is String) return double.tryParse(val) as T? ?? defaultValue;
        if (val is num) return val.toDouble() as T;
      } else if (T == bool) {
        if (val is String) {
          final lower = val.toLowerCase();
          if (lower == 'true' || lower == '1') return true as T;
          if (lower == 'false' || lower == '0') return false as T;
        }
        if (val is num) return (val != 0) as T;
      }
      return defaultValue;
    }
  }

  Future<void> fetchSettings() async {
    try {
      isLoadingSettings.value = true;

      final snapshot = await database.child('company_settings').get();

      if (snapshot.exists && snapshot.value != null) {
        final raw = snapshot.value as Map<dynamic, dynamic>;

        // Convert to Map<String, dynamic>
        final Map<String, dynamic> data = {};
        raw.forEach((k, v) {
          data[k.toString()] = v;
        });

        // Update reactive map
        appsettings.value = {...data};

        // Persist to local storage
        await storage.write(_kSettingsKey, data);

        if (data['razorpay_key'] != null) {
          await storage.write('razorpay_key', data['razorpay_key']);
        }

        debugPrint('Company settings fetched and saved locally.');
      } else {
        // No remote settings -> load from local
        _loadFromLocal();
      }
    } catch (e, st) {
      debugPrint('fetchSettings error: $e\n$st');
      // Fallback to local on error
      _loadFromLocal();
    } finally {
      isLoadingSettings.value = false;
    }
  }

  // ==================== LOAD FROM LOCAL ====================
  void loadSettingsFromLocal() {
    final raw = storage.read(_kSettingsKey);
    if (raw == null) {
      debugPrint('No settings in local storage');
      return;
    }

    final Map<String, dynamic> local = {};
    try {
      if (raw is Map) {
        raw.forEach((k, v) => local[k.toString()] = v);
        appsettings.value = {...local};
        debugPrint('Settings loaded from local storage');
      } else {
        debugPrint('Local settings not a Map: ${raw.runtimeType}');
      }
    } catch (e) {
      debugPrint('loadSettingsFromLocal parse error: $e');
    }
  }

  // Private helper for loading from local
  void _loadFromLocal() {
    final local = storage.read(_kSettingsKey);
    if (local != null && local is Map) {
      final Map<String, dynamic> localMap = {};
      local.forEach((k, v) {
        localMap[k.toString()] = v;
      });
      appsettings.value = {...localMap};
      debugPrint('Loaded settings from local storage.');
    } else {
      appsettings.value = {};
      debugPrint('No company settings found (remote or local).');
    }
  }

  // ==================== GENERIC GETTER ====================
  T getSetting<T>(String key, T defaultValue) {
    final v = appsettings[key];
    if (v == null) return defaultValue;

    try {
      return v as T;
    } catch (e) {
      // Type conversion for common types
      if (T == int) {
        if (v is String) return int.tryParse(v) as T? ?? defaultValue;
        if (v is num) return v.toInt() as T;
      } else if (T == double) {
        if (v is String) return double.tryParse(v) as T? ?? defaultValue;
        if (v is num) return v.toDouble() as T;
      } else if (T == bool) {
        if (v is String) {
          final lower = v.toLowerCase();
          if (lower == 'true' || lower == '1') return true as T;
          if (lower == 'false' || lower == '0') return false as T;
        }
        if (v is num) return (v != 0) as T;
      }
      return defaultValue;
    }
  }

  // ==================== SPECIFIC GETTERS ====================
  String get companyName => getSetting<String>('company_name', '');
  String get address => getSetting<String>('address', '');
  String get phone1 => getSetting<String>('phone1', '');
  String get phone2 => getSetting<String>('phone2', '');
  String get whatsapp => getSetting<String>('whatsapp', '');
  String get email => getSetting<String>('email', '');
  String get gstNumber => getSetting<String>('gst_number', '');
  String get panNumber => getSetting<String>('pan_number', '');
  String get tanNumber => getSetting<String>('tan_number', '');
  String get canNumber => getSetting<String>('can_number', '');
  String get timezone => getSetting<String>('timezone', 'Asia/Kolkata');
  String get currency => getSetting<String>('currency', 'INR');
  String get razorpayKey => getSetting<String>('razorpay_key', '');

  // Sharing-specific getters
  String get sharingMessage => getSetting<String>('sharing', '');
  String get companyFileUrl => getSetting<String>('company_file_url', '');
  String get companyBannerUrl => getSetting<String>('company_banner_url', '');

  int? get freeApplyLimit {
    final raw = appsettings['free_apply_limit'];
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is String) {
      if (raw.trim() == '') return null;
      return int.tryParse(raw);
    }
    if (raw is double) return raw.toInt();
    return null;
  }

  // ==================== SHARE FUNCTIONALITY ====================

  /// Share company info with custom message and image
  Future<void> shareCompanyInfo({
    String? customMessage,
    String? customImageUrl,
  }) async {
    try {
      // Use custom values or defaults from settings
      final message =
          customMessage ??
              (sharingMessage.isNotEmpty
                  ? sharingMessage
                  : getSettingFromLocal<String>('sharing', ''));
      final imageUrl = customImageUrl ?? companyFileUrl;

      // Validate
      if (message.isEmpty) {
        Get.snackbar(
          'Error',
          'No sharing message configured',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (imageUrl.isEmpty) {
        // Share text only if no image URL
        // await Share.share(message);
        await SharePlus.instance.share(
            ShareParams(text: message)
        );
        return;
      }

      // Share with image
      await _shareWithImage(imageUrl: imageUrl, message: message);

    } catch (e) {
      debugPrint("Error in shareCompanyInfo: $e");
      Get.snackbar(
        'Share Failed',
        'Could not share at this time',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Share job or any content with image
  Future<void> shareJobWithImage({
    required String imageUrl,
    required String message,
    String? subject,
  }) async {
    try {
      await _shareWithImage(
        imageUrl: imageUrl,
        message: message,
        subject: subject ?? "New Job Opportunity",
      );
    } catch (e) {
      debugPrint("Error in shareJobWithImage: $e");
      Get.snackbar(
        'Share Failed',
        'Could not share job at this time',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Private method to handle image download and sharing
  Future<void> _shareWithImage({
    required String imageUrl,
    required String message,
    String? subject,
  }) async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Download image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load image from $imageUrl');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create unique file name to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/share_image_$timestamp.jpg');

      // Write image to file
      await file.writeAsBytes(response.bodyBytes);

      // Close loading dialog
      Get.back();
print("Sharing Message"+message);
      // Share
      // await Share.shareXFiles(
      //   [XFile(file.path)],
      //   text: message,
      //   subject: subject ?? companyName,
      // );

      // await Share.shareFiles(
      //   [file.path],
      //   text: message,
      // );

      final params = ShareParams(
        text: message,
        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }

      // Clean up file after a delay (optional)
      Future.delayed(const Duration(seconds: 5), () {
        if (file.existsSync()) {
          file.delete();
        }
      });

    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      rethrow;
    }
  }

  /// Quick share using default company settings
  Future<void> shareReferral() async {
    await shareCompanyInfo();
  }


  Future<Map<String, dynamic>> canCandidateApply(String candidateId) async {
    try {
      // quick guard
      if (candidateId.trim().isEmpty) {
        return {'allowed': false, 'remaining': 0, 'reason': 'no_candidate'};
      }

      // fetch candidate and subscription flag
      final candSnap = await database.child('candidate/$candidateId').get();
      final candidate = (candSnap.exists && candSnap.value != null)
          ? Map<String, dynamic>.from(candSnap.value as Map)
          : null;

      final isSubscribed = (candidate != null &&
          (candidate['is_subscribed'] == true ||
              candidate['is_subscribed'] == 'true'))
          ? true
          : false;

      // if subscribed -> allowed unlimited
      if (isSubscribed) {
        return {'allowed': true, 'remaining': null, 'reason': 'subscribed'};
      }

      // free limit from settings
      final limit = freeApplyLimit; // int? or null (null = unlimited)
      if (limit == null) {
        // unlimited free applies
        return {'allowed': true, 'remaining': null, 'reason': 'unlimited'};
      }

      // count previous applications from candidate_applications/{candidateId}
      final appsSnap =
      await database.child('candidate_applications/$candidateId').get();
      int appliedCount = 0;
      if (appsSnap.exists && appsSnap.value != null) {
        final raw = appsSnap.value;
        if (raw is Map) {
          appliedCount = raw.length;
        } else if (raw is List) {
          appliedCount = raw.where((e) => e != null).length;
        }
      }

      final remaining = limit - appliedCount;
      final allowed = remaining > 0;

      return {
        'allowed': allowed,
        'remaining': remaining < 0 ? 0 : remaining,
        'reason': allowed ? 'ok' : 'limit_reached'
      };
    } catch (e, st) {
      debugPrint('canCandidateApply error: $e\n$st');
      // in case of error, be conservative: disallow
      return {'allowed': false, 'remaining': 0, 'reason': 'error'};
    }
  }

  /// Optionally expose a helper to force refresh and return current settings
  Future<Map<String, dynamic>> refreshSettings() async {
    await fetchSettings();
    return appsettings;
  }
}
