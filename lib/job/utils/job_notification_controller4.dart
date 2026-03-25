import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lcsjobs/job/utils/app_notification.dart';

class NotificationController extends GetxController {
  static const String storageKey = 'notifications';
  final box = GetStorage();

  RxList<AppNotification> notifications = <AppNotification>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFromStorage();
  }

  void loadFromStorage() {
    final List<dynamic> rawList = box.read(storageKey) ?? [];
    notifications.value = rawList
        .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  void addNotification(AppNotification notification) {
    notifications.insert(0, notification);
    saveToStorage();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    saveToStorage();
  }

  void clearAll() {
    notifications.clear();
    box.remove(storageKey);
  }

  void saveToStorage() {
    final data = notifications.map((e) => e.toJson()).toList();
    box.write(storageKey, data);
  }
}