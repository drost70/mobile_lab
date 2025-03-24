import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'login':
                  Navigator.pushNamed(context, '/login');
                  break;
                case 'register':
                  Navigator.pushNamed(context, '/register');
                  break;
                case 'profile':
                  Navigator.pushNamed(context, '/profile');
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'login', child: Text('Увійти')),
              PopupMenuItem(value: 'register', child: Text('Реєстрація')),
              PopupMenuItem(value: 'profile', child: Text('Профіль')),
            ],
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/greenhouse.jpg',
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Розумна теплиця',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Розумна теплиця – це автоматизована система для '
                      'моніторингу та управління кліматом всередині теплиці. '
                      'Вона використовує датчики та штучний інтелект для '
                      'підтримки ідеальних умов для рослин.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
