import 'package:get/get.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_details.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_notification.dart';
import 'package:lcsjobs/job/utils/app_notification.dart';

class NotificationNavigation {
  static void open(AppNotification n) {
    final Map<String, dynamic> data = n.data ?? {};

    // Try multiple key variants
    String? jobId;
    if (data.containsKey('jobId')) jobId = data['jobId']?.toString();
    if ((jobId == null || jobId.isEmpty) && data.containsKey('jobid')) jobId = data['jobid']?.toString();
    if ((jobId == null || jobId.isEmpty) && data.containsKey('job_id')) jobId = data['job_id']?.toString();
    if ((jobId == null || jobId.isEmpty) && data.containsKey('job')) jobId = data['job']?.toString();

    final type = (n.type ?? '').toString().toLowerCase();

    if (type == 'job' && jobId != null && jobId.isNotEmpty) {
      Get.to(() => JobDetails(jobId: jobId!));
      return;
    }

    // fallback always — go to alerts page
    Get.to(() => JobNotification());
  }

}
