import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcsjobs/job/job_pages/job_authentication/job_splash.dart';
import 'package:lcsjobs/job/utils/app_notification.dart';
import 'package:lcsjobs/job/utils/job_notification_controller4.dart';
import 'package:lcsjobs/job/utils/notification_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'job/job_pages/job_theme/job_theme.dart';
import 'job/job_pages/job_theme/job_themecontroller.dart';
import 'job/job_pages/job_translation/stringtranslation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'job/routes/app_pages.dart';
import 'job/store/AppStore.dart';
import 'job/utils/Constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lcsjobs/job/utils/job_notification_controller4.dart';

AppStore appStore = AppStore();
late SharedPreferences sharedPref;

/// 🔹 TOP-LEVEL: background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Must initialize Firebase & GetStorage in background isolate
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  final box = GetStorage();
  final List<dynamic> rawList = box.read(NotificationController.storageKey) ?? [];
  final notifMap = {
    'id': message.messageId ??
        DateTime.now().millisecondsSinceEpoch.toString(),
    'title': message.notification?.title ?? '',
    'body': message.notification?.body ?? '',
    'receivedAt': DateTime.now().toIso8601String(),
  };
  rawList.insert(0, notifMap);
  box.write(NotificationController.storageKey, rawList);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await GetStorage.init();
  print('Initializing Firebase...');
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // 🔹 Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 🔹 Request notification permissions (mainly for iOS, but safe)
  await FirebaseMessaging.instance.requestPermission();

  // Optional: get FCM token for this device (for your backend)
  final token = await FirebaseMessaging.instance.getToken();
  print('🔥 FCM Token: $token');


  sharedPref = await SharedPreferences.getInstance();

  await appStore.setLoggedIn(sharedPref.getBool(IS_LOGGED_IN) ?? false, isInitializing: true);

  // 🔹 Put NotificationController early so whole app can use it
  Get.put(NotificationController(), permanent: true);

  // 🔹 Foreground message listener
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   final notification = message.notification;
  //   if (notification != null) {
  //     final controller = Get.find<NotificationController>();
  //     controller.addNotification(
  //       AppNotification(
  //         id: message.messageId ??
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //         title: notification.title ?? '',
  //         body: notification.body ?? '',
  //         receivedAt: DateTime.now(),
  //         type: message.data['type'],
  //         data: message.data.isEmpty ? null : message.data,
  //       ),
  //     );
  //
  //     // Optional: show an in-app banner/snackbar
  //     Get.snackbar(
  //       notification.title ?? "New Alert",
  //       notification.body ?? "",
  //       snackPosition: SnackPosition.TOP,
  //     );
  //   }
  // });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('onMessage (foreground) data: ${message.data}');
    final notification = message.notification;
    if (notification != null) {
      final controller = Get.find<NotificationController>();

      final appNotif = AppNotification(
        id: message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: notification.title ?? '',
        body: notification.body ?? '',
        receivedAt: DateTime.now(),
        type: message.data['type'],
        data: message.data.isEmpty ? null : message.data,
      );

      controller.addNotification(appNotif);

      Get.snackbar(
        appNotif.title,
        appNotif.body,
        snackPosition: SnackPosition.TOP,
        onTap: (_) {
          NotificationNavigation.open(appNotif);;
        },
      );
    }
  });

  // 🔹 When app opened by tapping a notification
  // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //   // e.g., navigate to alert screen
  //   Get.toNamed('/alerts'); // add route if using named routes
  // });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('onMessageOpenedApp data: ${message.data}');
    final appNotif = AppNotification(
      id: message.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      receivedAt: DateTime.now(),
      type: message.data['type'],
      data: message.data.isEmpty ? null : message.data,
    );
    NotificationNavigation.open(appNotif);;
  });

  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    print('getInitialMessage data: ${initialMessage.data}');
    final appNotif = AppNotification(
      id: initialMessage.messageId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: initialMessage.notification?.title ?? '',
      body: initialMessage.notification?.body ?? '',
      receivedAt: DateTime.now(),
      type: initialMessage.data['type'],
      data: initialMessage.data.isEmpty ? null : initialMessage.data,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      NotificationNavigation.open(appNotif);;
    });
  }


  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themedata = Get.put(JobThemecontroler());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themedata.isdark ? JobMythemes.darkTheme : JobMythemes.lightTheme,
      fallbackLocale: const Locale('en', 'US'),
      translations: JobApptranslation(),
      locale: const Locale('en', 'US'),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}