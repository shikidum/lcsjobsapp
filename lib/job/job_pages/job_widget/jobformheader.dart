import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../job_theme/job_themecontroller.dart';

class JobFormHeader extends StatelessWidget {
  final int currentStep; // 1, 2, or 3
  final Color fillColor;

  JobFormHeader({
    required this.currentStep,
    required this.fillColor,
  });

  Widget _buildStep(String label, int stepNumber, bool isFilled) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isFilled ? fillColor : Colors.grey[200],
          border: Border.all(color: JobColor.bggray,),
          borderRadius: stepNumber == 1
              ? BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))
              : stepNumber == 3
              ? BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6))
              : BorderRadius.zero,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isFilled ? FontWeight.bold : FontWeight.normal,
            color: isFilled ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$currentStep/3",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        SizedBox(height: 4),
        Text(
          "POST JOB",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildStep("Job Details", 1, currentStep >= 1),
            _buildStep("Job Descriptions", 2, currentStep >= 2),
            _buildStep("Company Details", 3, currentStep >= 3),
          ],
        ),
      ],
    );
  }
}
