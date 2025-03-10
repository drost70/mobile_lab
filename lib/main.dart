import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyAppScreen(),
    );
  }
}

class MyAppScreen extends StatefulWidget {
  const MyAppScreen({super.key});

  @override
  State<MyAppScreen> createState() => _MyAppScreenState();
}

class _MyAppScreenState extends State<MyAppScreen>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  Color _bgColor = Colors.black;

  final List<String> _quotes = [
    'Ніколи не здавайся!',
    'Ти можеш більше, ніж думаєш!',
    'Мрії здійснюються!',
    'Живи кожен день на повну!',
    'Сьогодні ідеальний день для нового старту!',
  ];
  String _randomQuote = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.greenAccent)
        .animate(_animationController);
  }

  void _onSubmit(String value) {
    if (value == 'Mriya') {
      _animationController.forward().then((_) {
        setState(() {
          _counter = 0;
          _bgColor = Colors.blueGrey;
        });
        _animationController.reverse();
      });
    } else {
      final number = int.tryParse(value);
      if (number != null) {
        setState(() => _counter += number);
      } else {
        setState(() {
          _bgColor = Colors.redAccent;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() => _bgColor = Colors.black);
        });
      }
    }
    _controller.clear();
  }

  void _showRandomQuote() {
    setState(() {
      _randomQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(title: const Text('Magic Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                return Text(
                  '$_counter',
                  style: TextStyle(fontSize: 80, color: _colorAnimation.value),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter a number or magic word',
                ),
                textAlign: TextAlign.center,
                onSubmitted: _onSubmit,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showRandomQuote,
              child: const Text('Натхнення!'),
            ),
            const SizedBox(height: 20),
            Text(
              _randomQuote,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
