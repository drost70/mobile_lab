import 'package:my_project/data/user.dart';
import 'package:my_project/data/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserRepository implements UserRepository {
  @override
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? ''; 
    final password = prefs.getString('password') ?? ''; 
    final name = prefs.getString('name') ?? 'Користувач';

    if (email.isNotEmpty && password.isNotEmpty) {
      return User(email: email, password: password, name: name);
    }
    return null;
  }

  @override
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', user.email);
    await prefs.setString('password', user.password); 
    await prefs.setString('name', user.name ?? 'Користувач');
  }

  @override
  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('name');
  }
}
