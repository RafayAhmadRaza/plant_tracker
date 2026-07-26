import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitializd => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    final currentTimeZone = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(currentTimeZone.identifier));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    await _notificationsPlugin.initialize(settings: initSettings);
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'default_channel',
      "Default Channel",
      channelDescription: 'This is default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
  }

  Future<void> showNotification({
    int id = 0,
    String title = 'water your plants!',
    String body = 'Please Remember to water your plants!',
  }) async {
    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'This is the default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    return _notificationsPlugin.show(
      id: id,
      body: body,
      title: title,
      notificationDetails: NotificationDetails(android: details),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    const AndroidNotificationDetails details = AndroidNotificationDetails(
      'default_channel',
      "Default Channel",
      channelDescription: 'This is default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
