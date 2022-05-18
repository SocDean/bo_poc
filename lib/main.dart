import 'package:bo_poc/views/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(BoPoc());

class BoPoc extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bo app',
      theme: ThemeData(primaryColor: Colors.amber),
      home: LoginScreen(),
    );
  }
}
