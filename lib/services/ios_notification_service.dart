import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:todo_app/model/entities/todo_entity.dart';
import 'package:todo_app/model/enums/todo_status.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Platform-specific settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
            requestCriticalPermission: true,
            defaultPresentAlert: true,
            defaultPresentSound: true,
            defaultPresentBadge: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // Request permissions based on platform
      await _requestPermissions();

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize NotificationService: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
          critical: true,
        );
      }
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      await _handleNotificationTap(payload);
    }
  }

  Future<void> _handleNotificationTap(String todoId) async {
    debugPrint('Handle notification tap for todo: $todoId');
  }

  Future<void> scheduleTodoNotification(TodoEntity todo) async {
    if (!_isInitialized) {
      debugPrint('⚠️ NotificationService not initialized');
      return;
    }

    if (todo.time == null) return;

    // Combine date and time
    final DateTime notificationTime = DateTime(
      todo.date?.year ?? todo.time!.year,
      todo.date?.month ?? todo.time!.month,
      todo.date?.day ?? todo.time!.day,
      todo.time!.hour,
      todo.time!.minute,
    );

    // Don't schedule if time has passed
    if (notificationTime.isBefore(DateTime.now())) {
      debugPrint(
        '⚠️ Cannot schedule notification for past time: $notificationTime',
      );
      return;
    }

    // Platform-specific notification details
    AndroidNotificationDetails? androidNotificationDetails;
    DarwinNotificationDetails? iosNotificationDetails;

    if (defaultTargetPlatform == TargetPlatform.android) {
      androidNotificationDetails = AndroidNotificationDetails(
        'todo_reminder_channel',
        'Todo Reminders',
        channelDescription: 'Notifications for todo reminders',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('alarm_sound'),
        enableVibration: true,
        vibrationPattern: Int64List.fromList(const [0, 1000, 500, 1000]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      iosNotificationDetails = const DarwinNotificationDetails(
        sound: 'alarm_sound.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'todoReminder',
        interruptionLevel: InterruptionLevel.critical,
      );
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        todo.id.hashCode,
        '🔔 Todo Reminder',
        '${todo.title}${todo.notes?.isNotEmpty == true ? '\n${todo.notes}' : ''}',
        tz.TZDateTime.from(notificationTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: todo.id,
      );

      debugPrint(
        '✅ Scheduled notification for "${todo.title}" at $notificationTime',
      );
    } catch (e) {
      debugPrint('❌ Failed to schedule notification: $e');
    }
  }

  Future<void> cancelTodoNotification(String todoId) async {
    if (!_isInitialized) return;

    try {
      await _flutterLocalNotificationsPlugin.cancel(todoId.hashCode);
      debugPrint('🚫 Cancelled notification for todo: $todoId');
    } catch (e) {
      debugPrint('❌ Failed to cancel notification: $e');
    }
  }

  Future<void> updateTodoNotification(TodoEntity todo) async {
    await cancelTodoNotification(todo.id);

    if (todo.time != null && todo.status == TodoStatus.pending) {
      await scheduleTodoNotification(todo);
    }
  }

  // Test notification method
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      return;
    }

    AndroidNotificationDetails? androidDetails;
    DarwinNotificationDetails? iosDetails;

    if (defaultTargetPlatform == TargetPlatform.android) {
      androidDetails = const AndroidNotificationDetails(
        'test_channel',
        'Test Channel',
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
        importance: Importance.high,
        priority: Priority.high,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      iosDetails = const DarwinNotificationDetails(
        sound: 'alarm_sound.wav',
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      );
    }

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.show(
        999,
        '🔔 Test Notification',
        'This is a test notification from Todo App',
        notificationDetails,
      );
    } catch (e) {
      // Handle error silently or add proper error handling
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelAllNotifications() async {
    if (!_isInitialized) return;
    await _flutterLocalNotificationsPlugin.cancelAll();
    debugPrint('🧹 All notifications cancelled');
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImplementation != null) {
        final bool? enabled =
            (await iosImplementation.checkPermissions()) as bool?;
        return enabled ?? false;
      }
    }

    return true; // Android typically allows notifications by default
  }
}
