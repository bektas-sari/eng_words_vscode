import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Example word list. Replace with your dataset as needed.
const List<Map<String, String>> wordPairs = [
  {'english': 'Apple', 'turkish': 'Elma'},
  {'english': 'Book', 'turkish': 'Kitap'},
  {'english': 'Car', 'turkish': 'Araba'},
  {'english': 'Dog', 'turkish': 'Köpek'},
  {'english': 'House', 'turkish': 'Ev'},
  {'english': 'Water', 'turkish': 'Su'},
  {'english': 'Sun', 'turkish': 'Güneş'},
  {'english': 'Tree', 'turkish': 'Ağaç'},
  {'english': 'Chair', 'turkish': 'Sandalye'},
  {'english': 'Table', 'turkish': 'Masa'},
  {'english': 'Window', 'turkish': 'Pencere'},
  {'english': 'Door', 'turkish': 'Kapı'},
  {'english': 'Pen', 'turkish': 'Kalem'},
  {'english': 'School', 'turkish': 'Okul'},
  {'english': 'Friend', 'turkish': 'Arkadaş'},
  {'english': 'Food', 'turkish': 'Yemek'},
  {'english': 'Music', 'turkish': 'Müzik'},
  {'english': 'Phone', 'turkish': 'Telefon'},
  {'english': 'Computer', 'turkish': 'Bilgisayar'},
  {'english': 'Flower', 'turkish': 'Çiçek'},
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Vocabulary Flashcards',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlashcardQuizPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlashcardQuizPage extends StatefulWidget {
  const FlashcardQuizPage({super.key});
  @override
  State<FlashcardQuizPage> createState() => _FlashcardQuizPageState();
}

class _FlashcardQuizPageState extends State<FlashcardQuizPage>
    with SingleTickerProviderStateMixin {
  late List<Map<String, String>> quizWords;
  int currentIndex = 0;
  int score = 0;
  bool showResult = false;
  bool isAnimating = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Color cardColor = Colors.white;
  bool? lastAnswerCorrect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _startQuiz();
  }

  void _startQuiz() {
    final random = Random();
    quizWords = List<Map<String, String>>.from(wordPairs)..shuffle(random);
    quizWords = quizWords.take(20).toList();
    currentIndex = 0;
    score = 0;
    showResult = false;
    isAnimating = false;
    lastAnswerCorrect = null;
    setState(() {});
  }

  void _onAnswer(bool correct) async {
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
      lastAnswerCorrect = correct;
      cardColor = correct ? Colors.green.shade100 : Colors.red.shade100;
      _offsetAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: correct ? const Offset(2.0, 0) : const Offset(-2.0, 0),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    });
    if (correct) score++;
    await _controller.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _controller.reset();
    setState(() {
      cardColor = Colors.white;
      isAnimating = false;
      lastAnswerCorrect = null;
      if (currentIndex < quizWords.length - 1) {
        currentIndex++;
      } else {
        showResult = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _getOptions(int idx) {
    final correct = quizWords[idx]['turkish']!;
    final wrongCandidates =
    wordPairs.where((w) => w['turkish'] != correct).toList();
    final random = Random();
    final wrong =
    wrongCandidates[random.nextInt(wrongCandidates.length)]['turkish']!;
    final options = [correct, wrong]..shuffle(random);
    return options;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Vocabulary Flashcards'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: showResult ? _buildResult() : _buildFlashcard(context),
      ),
    );
  }

  Widget _buildFlashcard(BuildContext context) {
    final word = quizWords[currentIndex]['english']!;
    final options = _getOptions(currentIndex);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Card ${currentIndex + 1} of ${quizWords.length}',
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SlideTransition(
              position: _offsetAnimation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 220,
                alignment: Alignment.center,
                child: Text(
                  word,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildOptionButton(options[0]),
            _buildOptionButton(options[1]),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionButton(String option) {
    final isDisabled = isAnimating;
    return ElevatedButton(
      onPressed:
      isDisabled
          ? null
          : () {
        final correct = quizWords[currentIndex]['turkish'] == option;
        _onAnswer(correct);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        textStyle: const TextStyle(fontSize: 20),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        elevation: 4,
      ),
      child: Text(option),
    );
  }

  Widget _buildResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          score >= quizWords.length * 0.7 ? Icons.emoji_events : Icons.school,
          color: Colors.deepPurple,
          size: 64,
        ),
        const SizedBox(height: 24),
        Text(
          'You got $score out of ${quizWords.length} correct!',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _startQuiz,
          icon: const Icon(Icons.restart_alt),
          label: const Text('Restart Quiz'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            textStyle: const TextStyle(fontSize: 20),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
        ),
      ],
    );
  }
}
