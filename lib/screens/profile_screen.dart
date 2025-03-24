import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/REG.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const ColoredBox(
                color: Colors.green,
                child: Center(
                  child: Text(
                    'Помилка завантаження фото',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              );
            },
          ),
          ColoredBox(color: Colors.black.withValues(alpha: 0.3)),
          const SafeArea(
            child: Center(
              child: Text(
                'Інформація про користувача',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
