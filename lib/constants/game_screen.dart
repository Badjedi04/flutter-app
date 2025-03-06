import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/word_data.dart'; // Import static data

class WordflowGame extends StatefulWidget {
  const WordflowGame({super.key});

  @override
  State<WordflowGame> createState() => _WordflowGameState();
}

class _WordflowGameState extends State<WordflowGame> {
  // State variables
  List<String> letters = [];
  String currentWord = '';
  int timeLeft = 60;
  int score = 0;
  bool isGameRunning = false;

  final random = Random();

  @override
  void initState() {
    super.initState();
    generateLetters();
    startTimer();
  }

  void generateLetters() {
    letters.clear();
    for (int i = 0; i < 3; i++) {
      letters.add(vowels[random.nextInt(vowels.length)]);
    }
    for (int i = 0; i < 5; i++) {
      letters.add(consonants[random.nextInt(consonants.length)]);
    }
    letters.shuffle();
    setState(() {});
  }

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

  void addLetter(String letter) {
    setState(() {
      currentWord += letter;
    });
  }

  void removeLetter() {
    setState(() {
      if (currentWord.isNotEmpty) {
        currentWord = currentWord.substring(0, currentWord.length - 1);
      }
    });
  }

  bool isValidWord(String word) {
    return validWords.contains(word.toLowerCase());
  }

  void submitWord() {
    if (currentWord.isNotEmpty) {
      if (isValidWord(currentWord)) {
        setState(() {
          score += currentWord.length;
          timeLeft += currentWord.length * 5;
          if (timeLeft > 60) timeLeft = 60;
          currentWord = '';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Valid word: $currentWord')));
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid word: $currentWord')));
      }
    }
  }

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
        title: const Text(
          'Wordflow',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Time: $timeLeft s',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Score: $score',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    currentWord.isEmpty ? 'Tap letters to start' : currentWord,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children:
                      letters.map((letter) {
                        return GestureDetector(
                          onTap: () => addLetter(letter),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      text: 'REFRESH',
                      color: Colors.grey[700]!,
                      onPressed: refreshLetters,
                    ),
                    _buildButton(
                      text: 'UNDO',
                      color: Colors.orange[600]!,
                      onPressed: removeLetter,
                    ),
                    _buildButton(
                      text: 'SUBMIT',
                      color: Colors.green[600]!,
                      onPressed: submitWord,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
