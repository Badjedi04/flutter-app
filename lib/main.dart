import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const WordflowApp());
}

class WordflowApp extends StatelessWidget {
  const WordflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordflow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WordflowGame(),
    );
  }
}

class WordflowGame extends StatefulWidget {
  const WordflowGame({super.key});

  @override
  State<WordflowGame> createState() => _WordflowGameState();
}

class _WordflowGameState extends State<WordflowGame> {
  // State variables
  List<String> letters = []; // 12 random letters
  String currentWord = ''; // Word being built
  int timeLeft = 60; // Timer in seconds
  int score = 0; // Player score
  bool isGameRunning = false;

  // List of vowels and consonants for random generation
  final List<String> vowels = ['A', 'E', 'I', 'O', 'U'];
  final List<String> consonants = [
    'B',
    'C',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
    'M',
    'N',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  @override
  void initState() {
    super.initState();
    generateLetters();
    startTimer();
  }

  // Generate 12 random letters (balanced vowels and consonants)
  void generateLetters() {
    letters.clear();
    final random = Random();
    // 4 vowels, 8 consonants (adjust as needed for balance)
    for (int i = 0; i < 4; i++) {
      letters.add(vowels[random.nextInt(vowels.length)]);
    }
    for (int i = 0; i < 8; i++) {
      letters.add(consonants[random.nextInt(consonants.length)]);
    }
    letters.shuffle(); // Randomize the order
    setState(() {});
  }

  // Start or reset the timer
  void startTimer() {
    isGameRunning = true;
    timeLeft = 60;
    const duration = Duration(seconds: 1);
    Timer.periodic(duration, (timer) {
      if (timeLeft > 0 && isGameRunning) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        isGameRunning = false;
      }
    });
  }

  // Add a letter to the current word
  void addLetter(String letter) {
    setState(() {
      currentWord += letter;
    });
  }

  // Remove the last letter from the current word (UNDO)
  void removeLetter() {
    setState(() {
      if (currentWord.isNotEmpty) {
        currentWord = currentWord.substring(0, currentWord.length - 1);
      }
    });
  }

  // Submit the current word (simple logic for now, add dictionary check later)
  void submitWord() {
    if (currentWord.isNotEmpty) {
      setState(() {
        // Simple scoring: 1 point per letter, +5 seconds per letter for longer words
        score += currentWord.length;
        timeLeft += currentWord.length * 5;
        if (timeLeft > 60) timeLeft = 60; // Cap at 60 seconds
        currentWord = ''; // Clear the word
      });
    }
  }

  // Refresh letters (with a time penalty, e.g., -5 seconds)
  void refreshLetters() {
    setState(() {
      if (timeLeft >= 5) {
        timeLeft -= 5;
        generateLetters();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wordflow')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer and Score
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $timeLeft s', style: const TextStyle(fontSize: 20)),
                Text('Score: $score', style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          // Current Word Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              currentWord.isEmpty ? 'Tap letters to start' : currentWord,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Letter Grid (3x4 layout)
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children:
                letters.map((letter) {
                  return GestureDetector(
                    onTap: () => addLetter(letter),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                        child: Text(
                          letter,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: refreshLetters,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('REFRESH'),
              ),
              ElevatedButton(
                onPressed: removeLetter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('UNDO'),
              ),
              ElevatedButton(
                onPressed: submitWord,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('SUBMIT'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
