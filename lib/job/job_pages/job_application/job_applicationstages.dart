import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../job_theme/job_themecontroller.dart';

class JobApplicationStages extends StatefulWidget {
  final Map<String, dynamic> application;

  const JobApplicationStages({
    Key? key,
    required this.application,
  }) : super(key: key);

  @override
  State<JobApplicationStages> createState() => _JobApplicationStagesState();
}

class _JobApplicationStagesState extends State<JobApplicationStages> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());

  Map get job => (widget.application["job"] ?? {}) as Map<dynamic, dynamic>;
  String get status => (widget.application["status"] ?? "applied") as String;

  String _statusLabel(String status) {
    switch (status) {
      case "Applied":
        return "Application Sent";
      case "under_review":
        return "Under Review";
      case "Shortlisted":
        return "Shortlisted";
      case "Interview Aligned":
        return "Interview Aligned";
      case "Rejected":
        return "Application Rejected";
      case "Hired":
        return "Hired";
      case "Joined":
        return "Joined";
      case "Not Interested":
        return "Not Interested";
      case "No Response":
        return "No Response";
      default:
        return "Application Sent";
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case "applied":
        return const Color(0x1A246BFD);
      case "under_review":
      case "shortlisted":
      case "interview_scheduled":
        return const Color(0x1AFF9800);
      case "rejected":
        return const Color(0x1AF75555);
      case "hired":
        return const Color(0x1A4CAF50);
      default:
        return const Color(0x1A246BFD);
    }
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case "applied":
        return const Color(0xff246BFD);
      case "under_review":
      case "shortlisted":
      case "interview_scheduled":
        return const Color(0xffFACC15);
      case "rejected":
        return const Color(0xffF75555);
      case "hired":
        return const Color(0xff07BD74);
      default:
        return const Color(0xff246BFD);
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final dt = DateTime.parse(iso);
      return "${dt.day.toString().padLeft(2, '0')}-"
          "${dt.month.toString().padLeft(2, '0')}-"
          "${dt.year}";
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    final role = job["role"] ?? "N/A";
    final company = job["company_name"] ?? "N/A";
    final city = job["city"] ?? "";
    final locality = job["locality"] ?? "";
    final minSalary = job["min_salary"]?.toString() ?? "";
    final maxSalary = job["max_salary"]?.toString() ?? "";
    final category = job["category"] ?? "";
    final experienceType = job["experience_type"] ?? "";
    final workTimings = job["work_timings"] ?? "";
    final postedOn = job["posted_on"]?.toString();
    final createdAt = widget.application["created_at"]?.toString();
    final updatedAt = widget.application["updated_at"]?.toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Application_Stages".tr,
          style: urbanistBold.copyWith(fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width / 36,
            vertical: height / 36,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Job Overview Card
              Container(
                width: width / 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: themedata.isdark
                        ? JobColor.borderblack
                        : JobColor.bggray,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: width / 36,
                    vertical: height / 46,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: height / 10,
                        width: height / 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: themedata.isdark
                                ? JobColor.borderblack
                                : JobColor.bggray,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            JobPngimage.logo, // or a generic company icon
                            height: height / 36,
                          ),
                        ),
                      ),
                      SizedBox(height: height / 36),
                      Text(
                        role,
                        style: urbanistSemiBold.copyWith(fontSize: 22),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height / 80),
                      Text(
                        company,
                        style: urbanistMedium.copyWith(
                          fontSize: 18,
                          color: JobColor.appcolor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height / 96),
                      Divider(
                        color: themedata.isdark
                            ? JobColor.borderblack
                            : JobColor.bggray,
                      ),
                      SizedBox(height: height / 96),
                      Text(
                        (locality.isNotEmpty || city.isNotEmpty)
                            ? "$locality, $city"
                            : city,
                        style: urbanistMedium.copyWith(
                          fontSize: 16,
                          color: JobColor.textgray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height / 66),
                      if (minSalary.isNotEmpty || maxSalary.isNotEmpty)
                        Text(
                          "Rs.$minSalary - Rs.$maxSalary /month",
                          style: urbanistSemiBold.copyWith(
                            fontSize: 18,
                            color: JobColor.appcolor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: height / 66),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (category.toString().isNotEmpty)
                            _buildTag(category.toString()),
                          if (experienceType.toString().isNotEmpty)
                            SizedBox(width: width / 26),
                          if (experienceType.toString().isNotEmpty)
                            _buildTag(experienceType.toString()),
                        ],
                      ),
                      SizedBox(height: height / 66),
                      if (workTimings.toString().isNotEmpty)
                        Text(
                          workTimings.toString(),
                          style: urbanistSemiBold.copyWith(
                            fontSize: 14,
                            color: JobColor.textgray,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      SizedBox(height: height / 66),
                      Text(
                        "Posted on: ${_formatDate(postedOn)}",
                        style: urbanistSemiBold.copyWith(
                          fontSize: 12,
                          color: JobColor.textgray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height / 26),

              // 🔹 Application Status
              Text(
                "Your_Application_Status".tr,
                style: urbanistSemiBold.copyWith(fontSize: 18),
              ),
              SizedBox(height: height / 36),
              Container(
                height: height / 15,
                width: width / 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: _statusBgColor(status),
                ),
                child: Center(
                  child: Text(
                    _statusLabel(status).tr,
                    style: urbanistSemiBold.copyWith(
                      fontSize: 16,
                      color: _statusTextColor(status),
                    ),
                  ),
                ),
              ),

              SizedBox(height: height / 26),

              // 🔹 Extra details: when applied / last updated
              Text(
                "Application Details",
                style: urbanistSemiBold.copyWith(fontSize: 18),
              ),
              SizedBox(height: height / 46),
              _detailRow(
                "Applied on",
                _formatDate(createdAt),
              ),
              SizedBox(height: height / 96),
              _detailRow(
                "Last updated",
                _formatDate(updatedAt),
              ),
              SizedBox(height: height / 96),
              _detailRow(
                "Job ID",
                job["job_code"]?.toString() ?? job["job_id"]?.toString() ?? "-",
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: EdgeInsets.symmetric(
      //     horizontal: width / 36,
      //     vertical: height / 56,
      //   ),
      //   child: InkWell(
      //     splashColor: JobColor.transparent,
      //     highlightColor: JobColor.transparent,
      //     onTap: () {
      //       // You can add actions later based on status
      //     },
      //     child: Container(
      //       height: height / 15,
      //       width: width / 1,
      //       decoration: BoxDecoration(
      //         borderRadius: BorderRadius.circular(50),
      //         color: JobColor.lightblue,
      //       ),
      //       child: Center(
      //         child: Text(
      //           _statusLabel(status),
      //           style: urbanistSemiBold.copyWith(
      //             fontSize: 16,
      //             color: JobColor.appcolor,
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: JobColor.bggray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: urbanistMedium.copyWith(fontSize: 12),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: urbanistRegular.copyWith(
            fontSize: 14,
            color: JobColor.textgray,
          ),
        ),
        Text(
          value,
          style: urbanistSemiBold.copyWith(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
