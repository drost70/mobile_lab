import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/auth/auth_state.dart';
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/data/user.dart';
import 'package:my_project/data/user_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepository;

  AuthCubit({UserRepository? userRepository})
      : _userRepository = userRepository ?? LocalUserRepository(),
        super(AuthInitial());

  Future<void> loadUser() async {
    emit(AuthLoading());
    final user = await _userRepository.getUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final user = await _userRepository.getUser();
    if (user != null &&
        user.email == email &&
        user.password == password) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError('Невірний email або пароль'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> register(User user) async {
    emit(AuthLoading());
    await _userRepository.saveUser(user);
    emit(AuthAuthenticated(user));
  }

  Future<void> logout() async {
    await _userRepository.deleteUser();
    emit(AuthUnauthenticated());
  }

  Future<void> updateName(String newName) async {
    if (state is AuthAuthenticated) {
      final currentUser = (state as AuthAuthenticated).user;
      final updatedUser = User(
        email: currentUser.email,
        password: currentUser.password,
        name: newName,
      );
      await _userRepository.saveUser(updatedUser);
      emit(AuthAuthenticated(updatedUser));
    }
  }

  Future<void> deleteAccount() async {
    await _userRepository.deleteUser();
    emit(AuthUnauthenticated());
  }
}
