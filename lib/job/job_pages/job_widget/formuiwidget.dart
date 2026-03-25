import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_fontstyle.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_icons.dart';
import 'package:lcsjobs/job/utils/job_post_controller.dart';

import '../job_theme/job_themecontroller.dart';
import '../job_widget/jobformheader.dart';

class Formuiwidget {
  static InputDecoration inputDecoration(String hint, JobThemecontroler themedata) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: JobColor.appcolor)),
    );
  }

  static Widget textField(String hint,
      JobThemecontroler themedata, {
        int lines = 1,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        required TextEditingController controller,
      }) {
    return TextField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: urbanistSemiBold.copyWith(fontSize: 16),
      decoration: inputDecoration(hint, themedata),
    );
  }


  static Widget yesNoButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? JobColor.appcolor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: JobColor.appcolor),
          ),
          alignment: Alignment.center,
          child: Text(text, style: TextStyle(
              color: isSelected ? Colors.white : JobColor.appcolor)),
        ),
      ),
    );
  }

  static Widget dropdownField(String hint, JobThemecontroler themedata,
      List<String> items, RxString selectedValue) {
    return Obx(() =>
        DropdownButtonFormField<String>(
          value: selectedValue.value == '' ? null : selectedValue.value,
          decoration: inputDecoration(hint, themedata),
          isDense: true,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) => selectedValue.value = val!,
        ));
  }

  static Widget navigationButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: JobColor.appcolor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}