import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../job_gloabelclass/job_icons.dart';
import '../job_theme/job_themecontroller.dart';

class JobResume extends StatefulWidget {
  const JobResume({Key? key}) : super(key: key);

  @override
  State<JobResume> createState() => _JobResumeState();
}

class _JobResumeState extends State<JobResume> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;

  final themedata = Get.put(JobThemecontroler());
  final storage = GetStorage();
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  String? resumeName;      // what we show (from resume_path)
  String? resumeUrl;       // download url (from resume_url)
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    // load existing values from local storage
    resumeName = storage.read("resume_path"); // you save this in _saveCandidateDataToLocal
    resumeUrl = storage.read("resume_url");
  }

  Future<void> _pickAndUploadResume() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final fileData = result.files.single;
      if (fileData.path == null) return;

      final candidateId = storage.read("candidate_id");
      if (candidateId == null || candidateId.toString().isEmpty) {
        Get.snackbar("Error", "Candidate ID not found. Please login again.");
        return;
      }

      final File file = File(fileData.path!);

      setState(() {
        isUploading = true;
      });

      // storage path where file will live
      final storagePath =
          "resumes/$candidateId/${DateTime.now().millisecondsSinceEpoch}_${fileData.name}";
      final ref = firebaseStorage.ref().child(storagePath);

      final uploadTask = ref.putFile(file);
      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();

      // update state
      setState(() {
        resumeName = fileData.name; // show file name in UI
        resumeUrl = downloadUrl;
        isUploading = false;
      });

      // save locally
      storage.write("resume_path", resumeName ?? '');
      storage.write("resume_url", resumeUrl ?? '');

      // save to DB
      await database.child("candidate/$candidateId").update({
        "resume_path": resumeName ?? '',
        "resume_url": resumeUrl ?? '',
      });

      Get.snackbar("Success", "Resume uploaded successfully");
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print("Error in _pickAndUploadResume: $e");
      Get.snackbar("Error", "Failed to upload resume, please try again");
    }
  }

  Future<void> _removeResume() async {
    final candidateId = storage.read("candidate_id");

    setState(() {
      resumeName = null;
      resumeUrl = null;
    });

    storage.remove("resume_path");
    storage.remove("resume_url");

    if (candidateId != null && candidateId.toString().isNotEmpty) {
      try {
        await database.child("candidate/$candidateId").update({
          "resume_path": "",
          "resume_url": "",
        });
      } catch (e) {
        print("Error clearing resume in DB: $e");
      }
    }
  }

  Future<void> _saveAndExit() async {
    // if you want to ensure DB & storage always in sync, you can re-save here,
    // but since we already save on upload & remove, this is mostly just a "back"
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;

    final bool hasResume = resumeName != null && resumeName!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CV_Resume".tr,
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
              Text(
                "Upload CV/Resume".tr,
                style: urbanistMedium.copyWith(fontSize: 16),
              ),
              SizedBox(height: height / 66),

              // 🔹 Upload box (click to pick)
              InkWell(
                splashColor: JobColor.transparent,
                highlightColor: JobColor.transparent,
                onTap: isUploading ? null : _pickAndUploadResume,
                child: Container(
                  width: width / 1,
                  height: height / 6,
                  decoration: BoxDecoration(
                    color: themedata.isdark
                        ? JobColor.lightblack
                        : JobColor.appgray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: isUploading
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            const AlwaysStoppedAnimation(
                                JobColor.appcolor),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Uploading...".tr,
                          style: urbanistRegular.copyWith(
                            fontSize: 14,
                            color: JobColor.textgray,
                          ),
                        ),
                      ],
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          JobPngimage.uploadfile,
                          height: height / 26,
                        ),
                        SizedBox(height: height / 36),
                        Text(
                          hasResume
                              ? (resumeName ?? "Browse_File".tr)
                              : "Browse_File".tr,
                          style: urbanistSemiBold.copyWith(
                            fontSize: 14,
                            color: JobColor.textgray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: height / 36),

              // 🔹 Existing resume card (if any)
              if (hasResume)
                Container(
                  width: width / 1,
                  decoration: BoxDecoration(
                    color: const Color(0x1AF75555),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: width / 36,
                      vertical: height / 66,
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          JobPngimage.pdf,
                          height: height / 15,
                          fit: BoxFit.fitHeight,
                        ),
                        SizedBox(width: width / 36),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resumeName ?? '',
                                style: urbanistSemiBold.copyWith(
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "Uploaded".tr,
                                style: urbanistMedium.copyWith(
                                  fontSize: 12,
                                  color: JobColor.textgray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: _removeResume,
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: JobColor.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width / 36,
          vertical: height / 56,
        ),
        child: InkWell(
          splashColor: JobColor.transparent,
          highlightColor: JobColor.transparent,
          onTap: isUploading ? null : _saveAndExit,
          child: Container(
            height: height / 15,
            width: width / 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: isUploading ? Colors.grey : JobColor.appcolor,
            ),
            child: Center(
              child: Text(
                isUploading ? "Uploading...".tr : "Save".tr,
                style: urbanistSemiBold.copyWith(
                  fontSize: 16,
                  color: JobColor.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
