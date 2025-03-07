import 'dart:async';
import 'dart:math';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

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
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: Colors.white,
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
  List<String> letters = List.generate(16, (_) => '');
  String currentWord = '';
  int timeLeft = 60;
  int score = 0;
  bool isGameRunning = false;
  late Set<String> validWords;

  @override
  void initState() {
    super.initState();
    validWords =
        all.map((word) => word.toLowerCase()).toSet(); // Changed to all
    _loadDictionary();
    generateLetters();
    startTimer();
  }

  Future<void> _loadDictionary() async {
    try {
      final String response = await rootBundle.loadString('assets/words.txt');
      setState(() {
        validWords.addAll(
          response
              .split('\n')
              .map((word) => word.trim().toLowerCase())
              .where((word) => word.isNotEmpty),
        );
      });
    } catch (e) {
      print('Error loading dictionary: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to load custom dictionary. Using default word list.',
          ),
        ),
      );
    }
  }

  void generateLetters() {
    final random = Random();
    const vowels = ['A', 'E', 'I', 'O', 'U'];
    const consonants = [
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
    letters = List.generate(16, (_) {
      return random.nextBool()
          ? vowels[random.nextInt(vowels.length)]
          : consonants[random.nextInt(consonants.length)];
    })..shuffle();
    setState(() {});
  }

  void startTimer() {
    isGameRunning = true;
    timeLeft = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0 && isGameRunning) {
        setState(() => timeLeft--);
      } else {
        timer.cancel();
        isGameRunning = false;
      }
    });
  }

  void addLetter(String letter) {
    if (currentWord.length < 10) {
      setState(() => currentWord += letter);
    }
  }

  void clearWord() {
    if (currentWord.isNotEmpty) {
      setState(() => currentWord = '');
    }
  }

  bool isValidWord(String word) {
    return validWords.contains(word.toLowerCase()) && word.length >= 2;
  }

  void submitWord() {
    if (currentWord.isNotEmpty) {
      if (isValidWord(currentWord)) {
        setState(() {
          score += currentWord.length;
          timeLeft += currentWord.length * 5;
          if (timeLeft > 60) timeLeft = 60;
          currentWord = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Valid word! +${currentWord.length} points'),
            ),
          );
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Invalid word: $currentWord')));
      }
    }
  }

  void refreshLetters() {
    if (timeLeft >= 5) {
      setState(() {
        timeLeft -= 5;
        generateLetters();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wordflow',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time: $timeLeft s',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      'Score: $score',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  currentWord.isEmpty ? 'Tap letters to start' : currentWord,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(4.0),
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 1.0,
                  children:
                      letters.map((letter) {
                        return GestureDetector(
                          onTap: () => addLetter(letter),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.grey[200],
                            ),
                            child: Center(
                              child: Text(
                                letter,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: refreshLetters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'REFRESH',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: clearWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[400],
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'CLEAR',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: submitWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(fontSize: 14),
                      ),
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
}
