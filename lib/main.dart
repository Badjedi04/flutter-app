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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor:
            Colors.white, // Set default background to white
      ),
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
  List<String> letters = []; // 8 random letters (2x4 grid)
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

  // Simple dictionary of valid English words (expand this for a full app)
  final Set<String> validWords =
      {
        'at',
        'be',
        'in',
        'on',
        'to',
        'up',
        'we',
        'me',
        'he',
        'she',
        'and',
        'for',
        'the',
        'you',
        'are',
        'was',
        'with',
        'they',
        'this',
        'have',
        'from',
        'that',
        'will',
        'what',
        'about',
        'which',
        'their',
        'would',
        'there',
        'should',
        'could',
        'other',
        'into',
        'over',
        'after',
        'year',
        'time',
        'more',
        'only',
        'good',
        'word',
        'flow',
        'game',
        'play',
        'list',
        'test',
        'line',
        'point',
        'score',
        'start',
      }.map((word) => word.toLowerCase()).toSet();

  @override
  void initState() {
    super.initState();
    generateLetters();
    startTimer();
  }

  // Generate 8 random letters (balanced vowels and consonants for 2x4 grid)
  void generateLetters() {
    letters.clear();
    final random = Random();
    // 3 vowels, 5 consonants (adjust as needed for balance)
    for (int i = 0; i < 3; i++) {
      letters.add(vowels[random.nextInt(vowels.length)]);
    }
    for (int i = 0; i < 5; i++) {
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

  // Check if a word is valid (exists in the dictionary)
  bool isValidWord(String word) {
    return validWords.contains(word.toLowerCase());
  }

  // Submit the current word (only score valid words)
  void submitWord() {
    if (currentWord.isNotEmpty) {
      if (isValidWord(currentWord)) {
        setState(() {
          // Simple scoring: 1 point per letter, +5 seconds per letter for longer words
          score += currentWord.length;
          timeLeft += currentWord.length * 5;
          if (timeLeft > 60) timeLeft = 60; // Cap at 60 seconds
          currentWord = ''; // Clear the word
          // Optional: Show a success message (e.g., SnackBar)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Valid word: $currentWord')));
        });
      } else {
        // Optional: Show an error message for invalid words
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid word: $currentWord')));
      }
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
      appBar: AppBar(
        title: const Text('Wordflow', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white, // Match background
        elevation: 0, // Remove shadow for a cleaner look
      ),
      body: SingleChildScrollView(
        // Add scrolling capability for larger screens
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer and Score
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: $timeLeft s',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Current Word Display
              Text(
                currentWord.isEmpty ? 'Tap letters to start' : currentWord,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              // Letter Grid (2x4 layout)
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap:
                    true, // Ensures the grid doesn’t take up unnecessary space
                physics:
                    const NeverScrollableScrollPhysics(), // Disable grid scrolling to use parent scroll
                padding: const EdgeInsets.all(8.0),
                children:
                    letters.map((letter) {
                      return GestureDetector(
                        onTap: () => addLetter(letter),
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                            color:
                                Colors
                                    .white, // Match background for consistency
                          ),
                          child: Center(
                            child: Text(
                              letter,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: refreshLetters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey[300], // Light grey for REFRESH
                      foregroundColor: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('REFRESH'),
                  ),
                  ElevatedButton(
                    onPressed: removeLetter,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300], // Light grey for UNDO
                      foregroundColor: Colors.black, // Text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('UNDO'),
                  ),
                  ElevatedButton(
                    onPressed: submitWord,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Green for SUBMIT
                      foregroundColor: Colors.white, // White text for contrast
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('SUBMIT'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
