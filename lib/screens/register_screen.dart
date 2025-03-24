import 'package:flutter/material.dart';
import 'package:my_project/widgets/custom_button.dart';
import 'package:my_project/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
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
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CustomTextField(hint: 'Ім\'я'),
                  const CustomTextField(hint: 'Email'),
                  const CustomTextField(hint: 'Пароль', obscureText: true),
                  CustomButton(
                    text: 'Зареєструватися',
                    onPressed: () => Navigator.pushNamed(context, '/home'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text(
                      'Вже маєте акаунт? Увійдіть',
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
