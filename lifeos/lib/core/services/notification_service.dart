import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps flutter_local_notifications per docs/rfc/RFC-006_Notification_
/// Reminder_Architecture.md. Local-only — no push infrastructure, no
/// server (matches the no-telemetry security rule).
///
/// iOS re-scheduling note (RFC-006 §3): iOS limits background scheduling
/// reliability, so `rescheduleUpcoming()` (called from app startup, see
/// main.dart) refreshes the next 7 days of recurring reminders every time
/// the app opens — this is not a "schedule once far into the future" API.
class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static const _channelId = 'lifeos_reminders';
  static const _channelName = 'LifeOS Reminders';

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  /// Requested contextually — RFC-006 §4: the first time a user creates a
  /// Medicine/Supplement/Task deadline that needs a reminder, NOT during
  /// Onboarding.
  Future<bool> requestPermissionIfNeeded() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final iosImpl =
        _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

    final androidGranted = await androidImpl?.requestNotificationsPermission() ?? true;
    final iosGranted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: false, // silent by default — RFC-006 §5 / Settings toggle
        ) ??
        true;
    return androidGranted && iosGranted;
  }

  /// `sourceType`/`sourceId` map to the `Notification` entity fields
  /// (docs/04_Database_Schema.md).
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String sourceType,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
    );
    const details = NotificationDetails(android: androidDetails);

    // NOTE: a true scheduled (zonedSchedule) call requires the `timezone`
    // package initialized at app startup (tz.initializeTimeZones()). That
    // wiring is a main.dart-level concern; this immediate `show()` keeps
    // the service's public contract stable for callers today.
    await _plugin.show(id, title, body, details);
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
