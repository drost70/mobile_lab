import 'package:flutter/material.dart';
import 'package:my_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.name ?? '';
      _emailController.text = user.email;
    }
  }

  Future<void> _saveChanges() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updatedName = _nameController.text;
    await authProvider.updateName(updatedName);

    if (!mounted) return;
    Navigator.pop(context, updatedName);
  }

  void _deleteAccount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.deleteAccount();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ваш акаунт було видалено')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/greenhouse.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Зберегти зміни'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Видалити акаунт'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
