import 'package:flutter/material.dart'; 
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/data/user.dart';
import 'package:my_project/data/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserRepository _userRepository = LocalUserRepository();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _userRepository.getUser();
    if (user != null) {
      setState(() {
        _nameController.text = user.name!;
        _emailController.text = user.email;
      });
    }
  }

  Future<void> _saveChanges() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      setState(() => _errorMessage = 'Ім\'я не може бути порожнім');
      return;
    }

    final user = await _userRepository.getUser();
    if (user != null) {
      // ignore: lines_longer_than_80_chars
      final updatedUser = User(email: user.email, password: user.password, name: newName);
      await _userRepository.saveUser(updatedUser);

      setState(() {
        _successMessage = 'Дані оновлено!';
        _errorMessage = null;
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context, newName);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити акаунт?'),
        content: const Text('Цю дію не можна скасувати. Ви впевнені?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _userRepository.deleteUser();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/REG.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ім\'я'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  // ignore: lines_longer_than_80_chars
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              if (_successMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  // ignore: lines_longer_than_80_chars
                  child: Text(_successMessage!, style: const TextStyle(color: Colors.green)),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Зберегти зміни'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _deleteAccount,
                // ignore: lines_longer_than_80_chars
                child: const Text('Видалити акаунт', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
