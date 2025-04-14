import 'package:flutter/material.dart';
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/data/user.dart';
import 'package:my_project/data/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _userRepository = LocalUserRepository();
  User? _user;

  User? get user => _user;

  Future<void> loadUser() async {
    _user = await _userRepository.getUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final savedUser = await _userRepository.getUser();
    if (savedUser != null &&
        savedUser.email == email &&
        savedUser.password == password) {
      _user = savedUser;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  Future<void> register(User user) async {
    await _userRepository.saveUser(user);
    _user = user;
    notifyListeners();
  }

  Future<void> updateName(String newName) async {
    if (_user != null) {
      _user = User(
        email: _user!.email,
        password: _user!.password,
        name: newName,
      );
      await _userRepository.saveUser(_user!);
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    await _userRepository.deleteUser();
    _user = null;
    notifyListeners();
  }
}
