// Sessions screen

import 'package:flutter/material.dart';
import 'package:dnd_app/calendarDatabase.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For handling local notifications
import 'dart:async'; // For countdown functionality
import 'dart:io' show Platform; // For checking the platform (iOS or Android)
import 'package:permission_handler/permission_handler.dart'; // For managing permissions (especially for Android 13+)
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late Future<List<CalendarEvent>> eventsList = CalendarDatabase.instance
      .getAllEvents();

  final Map<int, String> _monthsMap = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'May',
    6: 'Jun',
    7: 'Jul',
    8: 'Aug',
    9: 'Sep',
    10: 'Oct',
    11: 'Nov',
    12: 'Dec',
  };

  // Adds new session
  void addSession(CalendarEvent event) async {
    // Add session to the database
    final newEvent = CalendarEvent(
      date: event.date,
      time: event.time,
      attendees: event.attendees,
    );
    await CalendarDatabase.instance.insert(newEvent);
    final refreshedList = CalendarDatabase.instance.getAllEvents();

    setState(() {
      eventsList = refreshedList;
    });
  }

  int daysUntil(CalendarEvent event) {
    final now = DateTime.now();
    final targetDate = event.date;

    return targetDate.difference(now).inDays;
  }

  Future<int> _openDialog() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NewSessionDialog();
      },
    );

    // NOTE: return int as a status code for snackbars
    if (result != null && result != 0) {
      // Result was valid, so we create a new session in the database
      addSession(result);
      return 1;
    }
    // If user exits
    else if (result == 0) {
      return 0;
    }
    // If no date or time
    else {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sessions"),
        actions: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Icon(Icons.add, color: Colors.black),
                SizedBox(width: 5),
                Text("Add availability", style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: () async {
                // Show a CUSTOM dialog to enter the new session details
                final status = await _openDialog();

                // Show snackbars depending on status codes
                if (status == 1) {
                  setState(() {
                    // Refresh list
                    eventsList = CalendarDatabase.instance.getAllEvents();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session created successfully!"),
                    ),
                  );
                } else {
                  if (status == -1) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Session not created! Please select both a date and a time",
                        ),
                      ),
                    );
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.black),
                  SizedBox(width: 5),
                  Text(
                    "Create a new session",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),

          FutureBuilder(
            future: eventsList,
            builder: (context, snapshot) {
              // While waiting for connection
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              // If error
              if (snapshot.hasError) {
                return Center(child: Text("Error has occured"));
              }

              // If there are no events in the database, return
              if (!snapshot.hasData) {
                return Center(child: Text("No events in the database:("));
              }

              // To make the data a list for itemCount
              final events = snapshot.data!;

              return Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    // Display each character one at a time
                    final event = events[index];
                    return Card(
                      elevation: 4,
                      shadowColor: Colors.black26,
                      color: Colors.grey.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Session ${event.id}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'in ${daysUntil(event)} '
                                    '${daysUntil(event) == 1 ? 'day' : 'days'}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 10),

                            // Date
                            Text(
                              "${_monthsMap[event.date.month]} ${event.date.day}, ${event.date.year}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),

                            SizedBox(height: 4),

                            // Time
                            Text(
                              "🕒  Time: ${event.time}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade700,
                              ),
                            ),

                            // Attendees
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "👥  Attendees: ${event.attendees.join(', ')}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    // Delete event
                                    await CalendarDatabase.instance.deleteEvent(
                                      event.id!,
                                    );

                                    // Refresh List
                                    setState(() {
                                      eventsList = CalendarDatabase.instance
                                          .getAllEvents();
                                    });
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ==================================
// Dialog Box to create new session
// ==================================

class NewSessionDialog extends StatefulWidget {
  const NewSessionDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  bool _tzReady = false;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Controller for attendees and attendee list
  final _attendeeController = TextEditingController();
  List<String> _attendees = [];

  Future<void> _ensureTz() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Toronto')); // simple & reliable
    _tzReady = true;
  }

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones();

    // Initialize the notifications plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android-specific initialization settings for the notification plugin
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialization settings for all platforms (only Android here)
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Initialize the plugin with settings and define behavior when the notification is tapped
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            onSelectNotification(
              notificationResponse.payload,
            ); // Handle tap on notification
          },
    );

    // Ask runtime permission & fire a quick test notification
    _postInitNotificationSetup();

    // (Optional) also use permission_handler; safe to keep or remove
    if (Platform.isAndroid) {
      _requestNotificationPermission();
    }
  }

  // Request permission for notifications on Android 13+
  Future<void> _requestNotificationPermission() async {
    if (!Platform.isAndroid) return;
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        // ignore or log
      }
    }
  }

  // Handle tap on notification
  Future<void> onSelectNotification(String? payload) async {
    if (payload != null) {
      // print('Notification payload: $payload');
    }
  }

  // Ask plugin for runtime permission and show a test notification
  Future<void> _postInitNotificationSetup() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Android 13+ runtime permission (safe if null)
    await androidPlugin?.requestNotificationsPermission();

    // Immediate test notification so you can see it pop
    await flutterLocalNotificationsPlugin.show(
      9999,
      'Test',
      'If you see this, notifications are working',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: 'Daily notifications at specific times',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  // Build the TZ time for the schedule
  tz.TZDateTime getDate(DateTime date, String time) {
    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(3, 5));
    var scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

    // Guard: if in the past, nudge forward 1 minute for testing
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now)) {
      scheduled = now.add(const Duration(minutes: 1));
    }
    return scheduled;
  }

  // One-time schedule (inexact for now—works without exact-alarm toggle)
  Future<void> scheduleDailyNotification(DateTime date, String time) async {
    await _ensureTz();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'daily_channel_id',
          'Daily Notifications',
          channelDescription: 'Daily notifications at specific times',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Unique ID so events don’t overwrite each other
    final int id = ('${date.toIso8601String()} $time').hashCode & 0x7fffffff;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'It\'s time to play',
      'It\'s time to play DnD',
      getDate(date, time),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // one-time: do NOT set matchDateTimeComponents
    );
  }

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _addAttendee() {
    final attendee = _attendeeController.text.trim();
    if (attendee.isNotEmpty) {
      setState(() {
        _attendees.add(attendee);
        _attendeeController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "New Session",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _pickDate,
              child: const Text("Pick Date"),
            ),
            Text("Selected Date: ${_selectedDate}"),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _pickTime,
              child: const Text("Pick Time"),
            ),
            Text("Selected Time: ${_selectedTime}"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _attendeeController,
                    decoration: const InputDecoration(
                      labelText: 'Add Attendee',
                      hintText: 'ex. John',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addAttendee,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text("Added Attendees: ${_attendees.join(', ')}"),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 0), // exit code
                  child: const Text("Exit"),
                ),
                TextButton(
                  onPressed: () {
                    if (_selectedTime == null || _selectedDate == null) {
                      Navigator.pop(context, null);
                    } else {
                      final timeStr =
                          _selectedTime!.hour.toString().padLeft(2, '0') +
                          ':' +
                          _selectedTime!.minute.toString().padLeft(2, '0');

                      final event = CalendarEvent(
                        date: _selectedDate!,
                        time: timeStr,
                        attendees: _attendees,
                      );

                      // Go back first so your SessionsPage can insert & refresh
                      Navigator.pop(context, event);

                      // Then schedule the one-time notification
                      scheduleDailyNotification(_selectedDate!, timeStr);
                    }

                    // Reset for next open
                    _selectedDate = null;
                    _selectedTime = null;
                    _attendees = [];
                  },
                  child: const Text("Save Session"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
