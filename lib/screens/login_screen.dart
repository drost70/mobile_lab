import 'package:flutter/material.dart';
import 'package:my_project/widgets/custom_button.dart';
import 'package:my_project/widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
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
          // ignore: deprecated_member_use
          ColoredBox(color: Colors.black.withOpacity(0.3)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomTextField(hint: 'Email'),
                  const CustomTextField(hint: 'Пароль', obscureText: true),
                  CustomButton(
                    text: 'Увійти',
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Не маєте акаунту? Зареєструйтеся',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
