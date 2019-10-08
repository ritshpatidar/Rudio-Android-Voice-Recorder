import 'package:flutter/material.dart';
//import 'dart:async';
import 'record.dart';
import 'recordings.dart';
//import 'package:flutter/services.dart';
//void main() => runApp(MyApp());

void main() {
  final timerService = TimerService();
  runApp(
    TimerServiceProvider( // provide timer service to all widgets of your app
      service: timerService,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rudio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.keyboard_voice),text: "Record"),
                Tab(icon: Icon(Icons.library_music),text:"Recordings"),
              ],
            ),
            title: Text('Rudio'),
          ),
          body: TabBarView(
            children: [
              RecordPage(),
              RecordingsPage(), //Icon(Icons.directions_transit),
            ],
          ),
        ),
      ),
    );
  }
}
