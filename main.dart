import 'package:flutter/material.dart';
import 'package:miningsim/game_page.dart';
import 'package:miningsim/login_page.dart';

void main() {
  var userId;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mining Simulator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with the login page.
    );
  }
}
