import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lcsjobs/job/job_gloabelclass/job_color.dart';
import '../../job_gloabelclass/job_fontstyle.dart';
import '../../utils/job_home_controller.dart';
import '../job_theme/job_themecontroller.dart';

class JobContactInfo extends StatefulWidget {
  const JobContactInfo({Key? key}) : super(key: key);

  @override
  State<JobContactInfo> createState() => _JobContactInfoState();
}

class _JobContactInfoState extends State<JobContactInfo> {
  dynamic size;
  double height = 0.00;
  double width = 0.00;
  final themedata = Get.put(JobThemecontroler());
  final controller = Get.put(JobHomeController());
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact_Information".tr,style: urbanistBold.copyWith(fontSize: 22 )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width/36,vertical: height/36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Address (Optional)",style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/66,),
              TextField(
                style: urbanistSemiBold.copyWith(fontSize: 16),
                controller: controller.AddressController,
                decoration: InputDecoration(
                  hintStyle: urbanistRegular.copyWith(fontSize: 16,color:JobColor.textgray,),
                  hintText: "Address".tr,
                 fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                  filled: true,
                  prefixIcon:Icon(Icons.location_on,size: height/36,color: JobColor.textgray,),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: JobColor.appcolor)
                  ),
                ),
              ),
              SizedBox(height: height/46,),
              Text("Phone Number (You Can't Change This)",style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/66,),
              IntlPhoneField(
                flagsButtonPadding: const EdgeInsets.all(8),
                dropdownIconPosition: IconPosition.trailing,
                style: urbanistSemiBold.copyWith(fontSize: 16),
                keyboardType: TextInputType.number,
                dropdownTextStyle: urbanistSemiBold.copyWith(fontSize: 16,color: themedata.isdark?JobColor.white:JobColor.textgray,),
                disableLengthCheck: true,
                controller: controller.PhoneNoController,
                readOnly: true,
                decoration:  InputDecoration(
                  hintText: "00000000000",
                  fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                  filled: true,
                  hintStyle: urbanistRegular,
                  enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide(color: JobColor.appcolor)
                  ),
                ),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  Get.snackbar("Error", "You Can't Change your Phone Number. If Needed Please Contact Customer Care");
                },
              ),
              SizedBox(height: height/46,),
              Text("Email".tr,style: urbanistMedium.copyWith(fontSize: 16 )),
              SizedBox(height: height/66,),
              TextField(
                style: urbanistSemiBold.copyWith(fontSize: 16),
                controller: controller.emailController,
                decoration: InputDecoration(
                  hintStyle: urbanistRegular.copyWith(fontSize: 16,color:JobColor.textgray,),
                  hintText: "andrew_ainsley@yourdomain.com".tr,
                 fillColor: themedata.isdark?JobColor.lightblack:JobColor.appgray,
                  filled: true,
                  prefixIcon:Icon(Icons.email,size: height/36,color: JobColor.textgray,),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: JobColor.appcolor)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: width / 36, vertical: height / 56),
        child: Obx(() => InkWell(
          splashColor: JobColor.transparent,
          highlightColor: JobColor.transparent,
          onTap: controller.isContactUpdating.value
              ? null
              : () {
            controller.updateContactInfo();
          },
          child: Container(
            height: height / 15,
            width: width / 1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: controller.isContactUpdating.value
                  ? JobColor.appcolor.withOpacity(0.6)
                  : JobColor.appcolor,
            ),
            child: Center(
              child: controller.isContactUpdating.value
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                "Save".tr,
                style: urbanistSemiBold.copyWith(
                  fontSize: 16,
                  color: JobColor.white,
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
