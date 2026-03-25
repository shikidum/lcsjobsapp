import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_auth_controller/job_onboarding_controller.dart';

class AssetSelectionSheet extends StatelessWidget {
  final JobOnboardingController controller;
  AssetSelectionSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final List<String> options = controller.allAssets;

    final selectedTemp = [...controller.selectedAssets];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Select Your Assets", style: urbanistBold.copyWith(fontSize: 18)),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((asset) {
              final isSelected = selectedTemp.contains(asset);
              return FilterChip(
                label: Text(asset),
                selected: isSelected,
                selectedColor: JobColor.appcolor.withOpacity(0.2),
                checkmarkColor: JobColor.appcolor,
                onSelected: (val) {
                  if (val) {
                    selectedTemp.add(asset);
                  } else {
                    selectedTemp.remove(asset);
                  }
                  Get.snackbar("Error",selectedTemp.toString());
                  // force rebuild
                  (context as Element).markNeedsBuild();
                },
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: JobColor.appcolor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: () {
              controller.selectedAssets.value = selectedTemp;
              Navigator.pop(context);
            },
            child: Text("Submit", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
