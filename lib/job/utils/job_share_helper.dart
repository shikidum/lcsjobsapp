import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class JobShareHelper {
  /// Generate formatted job message from job data
  static String generateJobMessage({
    required Map<String, dynamic> job,
    required String companyUrl,
  }) {
    final role = job['role'] ?? 'N/A';
    final minSalary = job['min_salary'] ?? '0';
    final maxSalary = job['max_salary'] ?? '0';
    final category = job['category'] ?? 'N/A';
    final company = job['company_name'] ?? 'N/A';
    final locality = job['locality'] ?? '';
    final city = job['city'] ?? '';
    final state = job['state'] ?? '';

    // Build location string
    String location = '';
    if (locality.isNotEmpty) location += locality;
    if (city.isNotEmpty) location += location.isEmpty ? city : ', $city';
    if (state.isNotEmpty) location += location.isEmpty ? state : ', $state';
    if (location.isEmpty) location = 'Location not specified';

    return '''
Check this job out!

📋 Post: $role
💰 Salary: Rs. $minSalary - Rs. $maxSalary /month
🏢 Industry: $company
📍 Location: $location

To apply for this job, click here:
$companyUrl
''';
  }

  /// Share job with image from settings
  static Future<void> shareJobWithCompanyImage({
    required BuildContext context,
    required Map<String, dynamic> job,
    required String imageUrl,
    required String companyUrl,
  }) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Generate message
      final message = generateJobMessage(job: job, companyUrl: companyUrl);

      if (imageUrl.isEmpty) {
        // Close loading and share text only
        Navigator.pop(context);
        // await Share.share(
        //   message,
        //   subject: 'Job Opportunity: ${job['role']}',
        // );
        await SharePlus.instance.share(
            ShareParams(text: message)
        );
        return;
      }

      // Download image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode != 200) {
        // Close loading and share text only on error
        Navigator.pop(context);
        await Share.share(
          message,
          subject: 'Job Opportunity: ${job['role']}',
        );
        Get.snackbar(
          'Note',
          'Sharing without image',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
        return;
      }

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/job_share_$timestamp.jpg');
      await file.writeAsBytes(response.bodyBytes);
      // Close loading dialog
      Navigator.pop(context);
      // Share with image
      // await Share.shareXFiles(
      //   [XFile(file.path)],
      //   text: message,
      //   subject: 'Job Opportunity: ${job['role']}',
      // );

      final params = ShareParams(
        text: message,
        files: [XFile(file.path)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }

      // Share.shareFiles(['${tempDir.path}/job_share_$timestamp.jpg'], text: message);

      // Cleanup after delay
      Future.delayed(const Duration(seconds: 5), () {
        if (file.existsSync()) {
          file.delete();
        }
      });

    } catch (e) {
      debugPrint('Share error: $e');

      // Close loading if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Fallback to text-only share
      try {
        final message = generateJobMessage(job: job, companyUrl: companyUrl);
        await Share.share(
          message,
          subject: 'Job Opportunity: ${job['role']}',
        );
      } catch (fallbackError) {
        Get.snackbar(
          'Share Failed',
          'Could not share job details',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }
}