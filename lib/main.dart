import 'package:flutter/material.dart';

// The simplest possible Flutter app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Basic Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Guide Genie'),
        ),
        body: const Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}