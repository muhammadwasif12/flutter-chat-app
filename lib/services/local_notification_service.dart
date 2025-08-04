import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Show local notification
  static Future<void> showChatNotification({
    required String username,
    required String message,
    required String senderId,
  }) async {
    // Current user ko notification nahi bhejni
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == senderId) {
      return; // Don't show notification for own messages
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch % 100000, // Unique ID
        username,
        message,
        platformDetails,
        payload: 'chat_message',
      );
      print("✅ Local notification sent: $username - $message");
    } catch (e) {
      print("❌ Error sending local notification: $e");
    }
  }

  // Request permissions (for iOS mainly)
  static Future<bool> requestPermissions() async {
    final bool? result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }
}