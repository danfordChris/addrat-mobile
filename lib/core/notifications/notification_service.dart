import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await NotificationService.showLocalNotification(
    title: message.notification?.title ?? '',
    body: message.notification?.body ?? '',
    payload: message.data['type'] as String?,
  );
}

class NotificationService {
  NotificationService._();

  static final _fcm = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static const _channelId = 'pesa_lending_channel';

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _local.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
  }

  static Future<bool> requestPermissions() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (kDebugMode) debugPrint('FCM permission: ${settings.authorizationStatus}');
    return granted;
  }

  static void handleForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    showLocalNotification(
      title: n.title ?? '',
      body: n.body ?? '',
      payload: message.data['type'] as String?,
    );
  }

  static Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      _channelId,
      'Pesa Lending',
      channelDescription: 'Loan and KYC updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails(presentAlert: true, presentSound: true);
    await _local.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  static Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);

  static Future<void> subscribeToDefaultTopics() async {
    await Future.wait([
      subscribeToTopic('loan_updates'),
      subscribeToTopic('kyc_updates'),
      subscribeToTopic('repayment_reminders'),
    ]);
  }

  static Future<String?> getToken() => _fcm.getToken();
}
