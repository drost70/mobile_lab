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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _colorAnimation = ColorTween(begin: Colors.white, end: Colors.redAccent)
        .animate(_animationController);
  }

  void _onSubmit(String value) {
    if (value == 'Avada Kedavra') {
      _animationController.forward().then((_) {
        setState(() => _counter = 0);
        _animationController.reverse();
      });
    } else {
      final number = int.tryParse(value);
      if (number != null) {
        setState(() => _counter += number);
      }
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
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
                  labelText: 'Enter a number or magic spell',
                ),
                textAlign: TextAlign.center,
                onSubmitted: _onSubmit,
              ),
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
