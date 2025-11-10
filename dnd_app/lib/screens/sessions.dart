// Sessions screen

import 'package:flutter/material.dart';
import 'package:dnd_app/calendarDatabase.dart';
import 'package:flutter/rendering.dart';

// For notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dnd_app/notifications.dart';
import 'package:timezone/timezone.dart'; // Import to handle scheduling notifications

// Time zones
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final Notifications _notifications = Notifications();

class SessionsPage extends StatefulWidget{
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>{

  late Future<List<CalendarEvent>> eventsList = CalendarDatabase.instance.getAllEvents();

  final Map<int, String> _monthsMap = {
    1:'Jan', 2:'Feb', 3:'Mar', 4:'Apr', 5:'May', 6:'Jun', 7:'Jul', 8:'Aug', 
    9:'Sep', 10: 'Oct', 11:'Nov', 12: 'Dec'
  };

  // Adds new session
  void addSession (CalendarEvent event) async {
    // Add session to the database
    final newEvent = CalendarEvent(date: event.date, time: event.time.substring(10,15), attendees: event.attendees);
    await CalendarDatabase.instance.insert(newEvent);
    final refreshedList = CalendarDatabase.instance.getAllEvents();

    setState(() {
      eventsList = refreshedList;
    });

  }

  int daysUntil (CalendarEvent event){
    final now = DateTime.now();
    final targetDate = event.date;

    return targetDate.difference(now).inDays;
  }

  Future<int> _openDialog() async{
    final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return NewSessionDialog();
        }
    );

    // NOTE: return int as a status code for snackbars
    if (result != null && result != 0){
      // Result was valid, so we create a new session in the database

      addSession(result);

      // Trigger notifications
      final now = DateTime.now().toUtc();
      final triggerTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 3));
      _notifications.sendNotificationLater(
          "New Session created",
          "There has been a new session created",
          "New Session",
          triggerTime
      );
      return 1;
    }
    // If user exits
    else if (result == 0){
      return 0;
    }
    // If no date or time
    else{
      return -1;
    }
  }

  @override
  void initState() {
    super.initState();
    _notifications.init();

    _notifications.sendNotificationNow(
      "Test Notification",
      "If you see this, notifications are working!",
      "test_payload",
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sessions"),
        actions: [
          TextButton(
              onPressed: (){},
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.black,),
                  SizedBox(width: 5),
                  Text("Add availability", style: TextStyle(color: Colors.black),)
                ],
              ))
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
                      if (status == 1){
                        setState(() {
                          // Refresh list
                          eventsList = CalendarDatabase.instance.getAllEvents();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Session created successfully!"))
                        );
                      }
                      else{
                        if (status == -1){
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Session not created! Please select both a date and a time"))
                          );
                        }

                      }

                      // // Step 1: Create a SnackBar widget with text and an optional action button
                      // final snackbar = SnackBar(
                      //   content: Text('Event Created'), // The message shown in the Snackbar
                      //
                      //   // The action button that appears on the right side of the Snackbar
                      //   action: SnackBarAction(
                      //     label: 'Undo', // The text for the action button
                      //     onPressed: () {
                      //       // Code inside here runs when the user taps 'Undo'
                      //       print('Undo action');},
                      //   ),
                      // );
                      //
                      //   // Step 2: Use ScaffoldMessenger to show the Snackbar in the current context
                      //   ScaffoldMessenger.of(context).showSnackBar(snackbar);

                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.black,),
                        SizedBox(width: 5),
                        Text("Create a new session", style: TextStyle(color: Colors.black),)
                      ],
                    ))
            ),

            FutureBuilder(
                future: eventsList,
                builder: (context, snapshot){
                  // While waiting for connection
                  if (snapshot.connectionState ==  ConnectionState.waiting){
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // If error
                  if (snapshot.hasError){
                    return Center(
                      child: Text("Error has occured"),
                    );
                  }

                  // If there are no events in the database, return
                  if (!snapshot.hasData){
                    return Center(
                      child: Text("No events in the database:("),
                    );
                  }

                  // To make the data a list for itemCount
                  final events = snapshot.data!;

                  return Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: events.length,
                        itemBuilder: (context, index){
                          // Display each character one at a time
                          final event = events[index];
                          return Card(
                            elevation: 4,
                            shadowColor: Colors.black26,
                            color: Colors.grey.shade50,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                              '${daysUntil(event) == 1 ? 'day': 'days'}',
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
                                          onPressed: () async{
                                            // Delete event
                                            await CalendarDatabase.instance.deleteEvent(event.id!);

                                            // Refresh List
                                            setState(() {
                                              eventsList = CalendarDatabase.instance.getAllEvents();
                                            });
                                          },
                                          icon: Icon(Icons.delete))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );

                        }),
                  );

                }
            ),

          ],
        )
    );
  }
}

// ==================================
// Dialog Box to create new session
// ==================================

class NewSessionDialog extends StatefulWidget{
  const NewSessionDialog({super.key});

  @override
  State<StatefulWidget> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<NewSessionDialog>{
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Controller for attendees and attendee list
  final _attendeeController = TextEditingController();
  List<String> _attendees = [];

  
  void _pickDate() async{
    final date = await showDatePicker(
        context: context, 
        initialDate: DateTime.now(),
        firstDate: DateTime(2025), 
        lastDate: DateTime(2100)
    );

    if (date != null){
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _pickTime() async {
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay(hour: 12, minute: 0)
    );

    if (time != null){
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _addAttendee(){
    final attendee = _attendeeController.text.trim();
    if (attendee.isNotEmpty){
      setState(() {
        _attendees.add(attendee);
        print(_attendees);
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
                  color: Colors.white
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("New Session", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: 15,),
                  ElevatedButton(
                      onPressed: _pickDate,
                      child: Text("Pick Date")),
                  Text("Selected Date: ${_selectedDate}"),

                  SizedBox(height: 15,),
                  ElevatedButton(
                      onPressed: _pickTime,
                      child: Text("Pick Time")),
                  Text("Selected Time: ${_selectedTime}"),
                  SizedBox(height: 15,),
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
                  SizedBox(height: 2,),
                  Text("Added Attendees: ${_attendees.join(', ')}"),
                  SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: (){
                            Navigator.pop(context, 0); // To notify that user just exited dialog
                          },
                          child: Text("Exit")),
                      TextButton(
                          onPressed: (){

                            // If date or time is missing
                            if (_selectedTime == null || _selectedDate == null){
                              // Navigate back with nothing
                              Navigator.pop(context, null);
                            }
                            else{
                              // Create a calender event for the database
                              final CalendarEvent event = CalendarEvent(
                                  date: _selectedDate!,
                                  time: _selectedTime!.toString(),
                                  attendees: _attendees);

                              // Navigate back with calender object
                              Navigator.pop(context, event);
                            }

                            // Reset all variables
                            _selectedDate = null;
                            _selectedTime = null;
                            _attendees = [];
                          },
                          child: Text("Save Session"))
                    ],
                  )
                ],
              ),
            )
    );

  }
}
