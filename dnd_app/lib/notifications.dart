import 'dart:io'; // Import to detect platform (iOS or Android)
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // Import for notifications
import 'package:timezone/timezone.dart'; // Import to handle scheduling notifications

// Class to manage notifications
class Notifications {

  //***************************************************** TEMPLATE
  // Notification channel info (used for Android)
  final channelId = "testNotif";  // Unique ID for the notification channel
  final channelName = "Test Notification"; // Human-readable name for the notification channel
  final channelDescription = "Test Notification Description"; // Description for the channel

  // Initialize the local notifications plugin
  var _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Platform-specific notification details (for Android and iOS)
  NotificationDetails? _platformChannelInfo;

  // ID for notifications, incremented for each new notification
  var _notificationID = 100;

  // Initialization function to set up notification details and request permissions
  Future init() async {

    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }

    if (Platform.isIOS) {
      _requestIOSPermission();  // Request iOS-specific permissions
    }

    // Android-specific initialization settings
    var initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');

    // iOS-specific initialization settings
    var initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) {
        return null;  // Handling notifications received while app is in foreground (iOS)
      },
    );

    // Combine the Android and iOS initialization settings
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin with the settings
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // Handle taps on notifications
    );

    // Define Android notification channel details
    var androidChannelInfo = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
    );

    // Define iOS notification channel details
    var iosChannelInfo = DarwinNotificationDetails();

    // Combine Android and iOS notification details into a single object
    _platformChannelInfo = NotificationDetails(
      android: androidChannelInfo,
      iOS: iosChannelInfo,
    );
  }
  //*******************************************************************


  // Method to immediately send a notification
  void sendNotificationNow(String title, String body, String payload) {
    print(_flutterLocalNotificationsPlugin.toString()); // Debugging info
    _flutterLocalNotificationsPlugin.show(
      _notificationID++,  // Unique notification ID
      title,              // Notification title
      body,               // Notification body text
      _platformChannelInfo, // Platform-specific details (Android/iOS)
      payload: payload,    // Additional data sent with the notification
    );
  }

  // Method to schedule a notification for a later time
  sendNotificationLater(String title, String body, String payload, TZDateTime when) {
    return _flutterLocalNotificationsPlugin.zonedSchedule(
      _notificationID++,  // Unique notification ID
      title,              // Notification title
      body,               // Notification body text
      when,               // When to trigger the notification (a future time)
      _platformChannelInfo!,  // Platform-specific notification details
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,  // Allow notifications even if the device is in idle mode
      payload: payload,             // Additional data sent with the notification
    );
  }

  // Method to fetch pending scheduled notifications (useful for debugging or managing notifications)
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();  // Returns a list of pending notifications
  }

  // Method to handle taps or interactions with notifications
  Future onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    if (notificationResponse != null) {
      print("NotificationResponse::payload = ${notificationResponse.payload}");  // Logs the payload of the notification
    }
  }

  // Request permission to show notifications on iOS devices
  _requestIOSPermission() {
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
      sound: true,   // Request permission to play sound with notifications
      badge: true,   // Request permission to show badge on the app icon
      alert: false,  // Request permission for alerts (banners, etc.)
    );
  }
}

