import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WorklogNotificationService {
  WorklogNotificationService._();

  static final WorklogNotificationService instance =
      WorklogNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();

    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return result ?? true;
    }

    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }

    return false;
  }

  Future<void> showTestNotification() async {
    await initialize();

    const android = AndroidNotificationDetails(
      'worklog_updates',
      'WORKLOG obavijesti',
      channelDescription: 'Podsjetnici i operativne WORKLOG obavijesti.',
      importance: Importance.high,
      priority: Priority.high,
      visibility: NotificationVisibility.private,
    );
    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(android: android, iOS: ios);

    await _plugin.show(
      id: 4001,
      title: 'WORKLOG',
      body: 'Obavijesti rade ispravno na ovom uređaju.',
      notificationDetails: details,
      payload: 'settings:test-notification',
    );
  }

  Future<void> showJobStarted({
    required String jobTitle,
    required String clientName,
  }) async {
    await initialize();

    const android = AndroidNotificationDetails(
      'worklog_jobs',
      'Terenski poslovi',
      channelDescription: 'Statusi i događaji terenskih poslova.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      visibility: NotificationVisibility.private,
    );
    const details = NotificationDetails(
      android: android,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: 'Posao je pokrenut',
      body: '$jobTitle • $clientName',
      notificationDetails: details,
      payload: 'job:started',
    );
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
