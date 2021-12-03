import 'package:ema/actions/admin_actions.dart';
import 'package:ema/utils/global_funcs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminHomePage extends StatefulWidget {
  final TextEditingController adminProjectIdController;

  const AdminHomePage({Key? key, required this.adminProjectIdController})
      : super(key: key);

  @override
  AdminHomePageState createState() => AdminHomePageState();
}

class AdminHomePageState extends State<AdminHomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _selectedDay = DateTime.now();
  DateTime? _time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // scaffold is a layout for the major Material Components
    return Scaffold(
      // body is majority of the screen
      body: Center(
        child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 96,
              padding: const EdgeInsets.only(
                  top: 20.0, bottom: 20.0, left: 20.0, right: 20.0),
              child: TextField(
                controller: widget.adminProjectIdController,
                obscureText: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Project ID',
                ),
              ),
            ),
            Container(
              height: 280,
              child: TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                  DatePicker.showTimePicker(context,
                      showTitleActions: true,
                      showSecondsColumn: false, onConfirm: (time) {
                    setState(() {
                      _time = time;
                    });
                  }, currentTime: DateTime.now());
                },
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                rowHeight: 40.0,
              ),
            ),
            Container(
              height: 14,
              child: Text(
                'Send notification at ${_time?.hour}:${_time?.minute} on ${_selectedDay?.month}/${_selectedDay?.day}/${_selectedDay?.year}?',
              ),
            ),
            Container(
              height: 48,
              child: TextButton(
                onPressed: () {
                  scheduleNotification(_time?.minute, _time?.hour, _selectedDay?.year, _selectedDay?.month, _selectedDay?.day);
                  print('Scheduled');
                },
                child: const Text('Schedule'),
              ),
            ),
            Container(
              height: 48,
              child: TextButton(
                onPressed: () {
                  signOut();
                },
                child: const Text('Logout'),
              ),
            ),
            // OutlinedButton(
            //   onPressed: addUser,
            //   child: Text('Add User'),
            // ),
            // OutlinedButton(
            //   onPressed: checkUser,
            //   child: Text('Check User'),
            // ),
          ],
        )),
      ),
      // floatingActionButton: const FloatingActionButton(
      //     tooltip: 'Send Reminder',
      //     child: Icon(Icons.add),
      //     onPressed: null,
      // ),
    );
  }
}
