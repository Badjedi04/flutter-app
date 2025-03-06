import 'package:flutter/material.dart';
import 'constants/game_screen.dart'; // Import the game screen

void main() {
  runApp(const WordflowApp());
}

class WordflowApp extends StatelessWidget {
  const WordflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordflow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const WordflowGame(), // Use the game screen as home
    );
  }
}
