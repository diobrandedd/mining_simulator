import 'package:flutter/material.dart';
import 'package:miningsim/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mining Simulator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with the login page.
    );
  }
}
