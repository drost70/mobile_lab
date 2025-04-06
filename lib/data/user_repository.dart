import 'package:my_project/data/user.dart';

abstract class UserRepository {
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<void> deleteUser();
  Future<void> clearUser(); 
}
