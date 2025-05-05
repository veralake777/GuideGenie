import 'package:flutter/material.dart';

class GameFeedScreen extends StatelessWidget {
  const GameFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Feed')),
      body: const Center(
        child: Text('Game-specific posts and guides will be shown here.'),
      ),
    );
  }
}