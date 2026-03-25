import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;

  /// Optional: type / category, used for color (e.g. "info", "warning", "job")
  final String? type;

  /// Optional: route or data from FCM to open a specific part of app
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.type,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'receivedAt': receivedAt.toIso8601String(),
    'type': type,
    'data': data,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      receivedAt: DateTime.tryParse(json['receivedAt'] ?? '') ??
          DateTime.now(),
      type: json['type'],
      data: (json['data'] is Map<String, dynamic>)
          ? json['data'] as Map<String, dynamic>
          : (json['data'] is Map)
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }
}