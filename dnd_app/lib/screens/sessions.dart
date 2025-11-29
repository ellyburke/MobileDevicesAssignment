import 'package:flutter/material.dart';
import 'package:dnd_app/calendarDatabase.dart';
import 'package:dnd_app/userDatabase.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // For handling local notifications
import 'dart:async'; // For countdown functionality
import 'dart:io' show Platform; // For checking the platform (iOS or Android)
import 'package:permission_handler/permission_handler.dart'; // For managing permissions (especially for Android 13+)
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

bool _tzReady = false;

Future<void> _ensureTz() async {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('America/Toronto')); // simple & reliable
  _tzReady = true;
}

class SessionsPage extends StatefulWidget {
  final String? username;
  const SessionsPage({super.key, required this.username});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  //bool _tzReady = false;
  late final String? u = widget.username;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

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

  // Split sessions (passed and upcoming)
  List<CalendarEvent> eventsList = [];
  List<CalendarEvent> pastEvents = [];
  List<CalendarEvent> upcomingEvents = [];


  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    loadEvents();
    // Separate events
    separateEvents();

    _initialization = initializeNotifications();
  }

  Future<void> initializeNotifications() async {
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
  /*
  Future<void> _ensureTz() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Toronto')); // simple & reliable
    _tzReady = true;
  }

   */

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
  }

  Future<void> showNotificationAtDateTime(DateTime date, String time) async {
    _ensureTz();
    final hour = int.parse(time.substring(0, 2));
    final minute = int.parse(time.substring(3, 5));
    print(hour);
    print(minute);
    print(tz.TZDateTime.now(tz.local));
    var scheduled = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
    print(scheduled);
    final now = tz.TZDateTime.now(tz.local);
    if (scheduled.isBefore(now.add(const Duration(seconds: 5)))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    var difference = scheduled.difference(now);
    print(difference);
    print(difference.inSeconds);

    // Delay the notification for 3 seconds
    await Future.delayed(Duration(seconds: difference.inSeconds), () async {
      // Define notification details for Android
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'your_channel_id', // Unique channel ID
            'your_channel_name', // Name of the notification channel
            channelDescription:
                'your channel description', // Description of the channel
            importance: Importance
                .max, // High importance to display the notification immediately
            priority: Priority.high, // High priority to pop-up the notification
          );

      // Combine the notification details into NotificationDetails
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      final int id = ('${date.toIso8601String()} $time').hashCode & 0x7fffffff;

      // Show the notification
      await flutterLocalNotificationsPlugin.show(
        id,
        'It\'s time to play',
        'It\'s time to play DnD', // Body of the notification
        platformChannelSpecifics, // Notification details
        payload:
            'Notification Payload', // Optional payload for notification taps
      );
      /*
      In case we want to delete the session as soon as the user gets the notification
      await CalendarDatabase.instance.deleteEventByDateTime(date, time);
      final refreshedList = CalendarDatabase.instance.getAllEvents();

      setState(() {
        eventsList = refreshedList;
      });
       */
    });
  }

  Future<void> loadEvents() async {
    // Reload events
    final list = await CalendarDatabase.instance.getEventsByUserName(u!);

    setState(() {
      eventsList = list;
      separateEvents();
    });
  }

  void separateEvents(){
    // Separate events from past and upcoming
    for (CalendarEvent event in eventsList){
      // If event is not already in the lists
      if (!pastEvents.contains(event) || !upcomingEvents.contains(event)){
        // Check the date to separate events
        if (daysUntil(event) < 0){
          pastEvents.add(event);
        }
        else{
          upcomingEvents.add(event);
        }
      }
    }
  }

  // Adds new session
  void addSession(CalendarEvent event) async {
    // Add session to the database
    final newEvent = CalendarEvent(
      username: widget.username,
      date: event.date,
      time: event.time,
      attendees: event.attendees,
    );
    await CalendarDatabase.instance.insert(newEvent);

    setState(() {
      loadEvents();
    });
  }

  int daysUntil(CalendarEvent event) {
    final now = DateTime.now();
    final targetDate = event.date;

    return targetDate.difference(now).inDays;
  }

  Future<CalendarEvent?> _openDialog() async {
    final result = await showDialog<CalendarEvent>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return NewSessionDialog(username: u!,);
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire Scaffold in a FutureBuilder
    return FutureBuilder(
      // It listens to the initialization future from initState
      future: _initialization,
      builder: (context, snapshot) {
        // While waiting for initialization to complete, show a loading circle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If there was an error during initialization
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing the app: ${snapshot.error}'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Sessions"),
          ),

          body: Column(
            children: [
              SizedBox(height: 12,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: ElevatedButton(
                  onPressed: () async {
                    // await _requestExactAlarmPermission();
                    // Show a CUSTOM dialog to enter the new session details
                    final event = await _openDialog();

                    // Show snackbars depending on status codes
                    if (event != null) {
                      addSession(event);

                      setState(() {
                        // Refresh list
                        loadEvents();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Session created successfully!"),
                        ),
                      );
                      await showNotificationAtDateTime(event.date, event.time);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Session not created! Please select both a date and a time",
                          ),
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.black),
                      SizedBox(width: 5),
                      Text(
                        "Schedule a new session",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ======================
                        // UPCOMING SESSIONS LIST
                        // ======================
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            "Upcoming Sessions",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (upcomingEvents.isEmpty)
                          Center(
                            child: Text("No upcoming sessions scheduled"),
                          )
                        else
                          ...upcomingEvents.map(_buildEventCard).toList(),

                        const SizedBox(height: 30),

                        // =
                        if (pastEvents.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              "Past Sessions",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 10),

                        // ======================
                        // PAST SESSIONS LIST
                        // ======================
                        ...pastEvents.map(_buildEventCard).toList(),
                      ],
                    ),
                  ),
              )
        ]
          )
        );
      },
    );
  }

  Widget _buildEventCard(CalendarEvent event){

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
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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
                    color: daysUntil(event) < 0 ? Colors.red.shade600 :
                    daysUntil(event) == 0 ? Colors.green.shade600 :
                    Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.15,
                        ),
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    daysUntil(event) == 0 ? 'TODAY' :
                    daysUntil(event) < 0 ? 'PASSED' :
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
                    await CalendarDatabase.instance
                        .deleteEvent(event.id!);
                    // Refresh List
                    setState(() {
                      loadEvents();
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
  }
}

// ==================================
// Dialog Box to create new session
// ==================================

class NewSessionDialog extends StatefulWidget {
  final String? username;
  const NewSessionDialog({super.key, required this.username});

  @override
  State<StatefulWidget> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog> {
  late final String? u = widget.username;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? errorMessage;

  // Controller for attendees and attendee list
  final _attendeeController = TextEditingController();
  final List<String> _attendees = [];

  // To distinct between successfully added attendee or no
  bool valid = false;
  bool notValid = false;

  // To tell user if attendee has already been added
  String? helperText;

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      validateDateTime();
    }
  }

  void _pickTime() async {
    final now = DateTime.now();
    final initialTime = TimeOfDay(hour: now.hour, minute: now.minute);

    final time = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
      validateDateTime();
    }
  }

  void validateDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      if (selectedDateTime.isBefore(DateTime.now())) {
        setState(() {
          errorMessage = "Please select a future date and time";
        });
      } else {
        setState(() {
          errorMessage = null;
        });
      }
    }
  }

  Future<void> checkForAttendee(String attendeeValue) async {
    helperText = null;
    // Access database to see if user is in there
    final result = await UserDatabase.instance.getUserByUsername(attendeeValue);

    setState(() {
      if (result == null){
        notValid = true;
        valid = false;
      }
      else{
        notValid = false;
        valid = true;
      }
    });
  }

  void _addAttendee() async {
    // Only add attendees if they are in the database and have not already been added
    final attendee = _attendeeController.text.trim();

    setState(() {
      if (_attendees.contains(attendee)){
        // If attendee is already added to the list
        helperText = 'Attendee already added';
      }
      else {
        _attendees.add(attendee);
        _attendeeController.clear();
      }
    });
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
            Text(
              "Selected Date: ${_selectedDate?.year ?? 'YYYY'}-"
                  "${_selectedDate?.month ?? 'MM'}-${_selectedDate?.day ?? 'DD'}",
            ),

            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _pickTime,
              child: const Text("Pick Time"),
            ),

            Text("Selected Time: ${_selectedTime?.format(context) ?? 'HH:MM'}"),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _attendeeController,
                    decoration: InputDecoration(
                      labelText: 'Add Attendee By Username',
                      hintText: 'ex. user123',
                      border: const OutlineInputBorder(),
                      errorText: notValid ? 'User not found' : null,
                      helperText: helperText,
                      helperStyle: TextStyle(color: Colors.green.shade400),
                      suffixIcon: valid ? Icon(Icons.check, color: Colors.green,) :
                          notValid ? Icon(Icons.close, color: Colors.red,) : null
                    ),
                    onChanged: (value){
                      // Check the database if the user exists, show icon to indicate
                      checkForAttendee(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: valid ? _addAttendee : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text("Added Attendees: ${_attendees.join(', ')}"),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null), // exit code
                  child: const Text("Exit"),
                ),
                TextButton(
                  onPressed: () async {
                    if (_selectedTime == null ||
                        _selectedDate == null ||
                        errorMessage != null) {
                      return;
                    } else {
                      final lastAttendee = _attendeeController.text.trim();
                      if (lastAttendee.isNotEmpty) {
                        _attendees.add(lastAttendee);
                      }

                      final timeStr =
                          '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
                      print(timeStr);
                      final event = CalendarEvent(
                        username: u,
                        date: _selectedDate!,
                        time: timeStr,
                        attendees: _attendees,
                      );

                      // Go back first so your SessionsPage can insert & refresh
                      Navigator.pop(context, event);
                    }
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
