import 'package:get/get.dart';
import 'package:lcsjobs/job/job_pages/job_application/job_applicationstages.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_accountsetup/jobotheroption.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_signup.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_accountsetup/job_education.dart';
import 'package:lcsjobs/job/job_pages/job_home/job_notification.dart';
import 'package:lcsjobs/job/utils/app_notification.dart';

import '../job_pages/job_application/job_application.dart';
import '../job_pages/job_authentication/job_accountsetup/job_experience.dart';
import '../job_pages/job_authentication/job_accountsetup/job_fillprofile.dart';
import '../job_pages/job_authentication/job_accountsetup/job_pref.dart';
import '../job_pages/job_authentication/job_loginoption.dart';
import '../job_pages/job_authentication/job_onboarding.dart';
import '../job_pages/job_authentication/job_otpverification.dart';
import '../job_pages/job_authentication/job_splash.dart';
import '../job_pages/job_home/job_dashboard.dart';
import '../job_pages/job_home/job_subscription_screen.dart';
import '../job_pages/job_post/jobpostpart2screen.dart';
import '../job_pages/job_post/jobpostpart3screen.dart';
import '../job_pages/job_post/jobpostscreen.dart';
// adjust as per your folder

class AppPages {
  static const initial = '/splash';

  static final routes = [
    GetPage(name: '/splash', page: () => const JobSplash()),
    GetPage(name: '/login', page: () => const JobLoginoption()),
    GetPage(name: '/otp', page: () => const JobOtpverification()),
    GetPage(name: '/onboarding', page: () => const JobOnboarding()),
    GetPage(name: '/register', page: () => const JobFillProfile()),
    GetPage(name: '/register2', page: () => const JobEducation()),
    GetPage(name: '/register3', page: () => const JobExperience()),
    GetPage(name: '/register4', page: () => const JobPreferences()),
    GetPage(name: '/register5', page: () => const JobOtherOptions()),
    GetPage(name: '/dashboard', page: () => JobDashboard("0")),
    GetPage(name: '/myapplication', page: () => JobDashboard("2")),
    GetPage(name: '/jobpost', page: () => JobPostScreen()),
    GetPage(name: '/jobpost2', page: () => JobPostPart2Screen()),
    GetPage(name: '/jobpost3', page: () => JobPostPart3Screen()),
    GetPage(name: '/subscriptions', page: () => JobSubscriptionScreen()),
  GetPage(name: '/alerts', page: () => JobNotification()),
    // Add more pages here...
  ];

}
