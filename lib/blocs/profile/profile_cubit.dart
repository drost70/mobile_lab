import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:my_project/data/user.dart';
import 'package:my_project/providers/auth_provider.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final AuthProvider authProvider;

  ProfileCubit({required this.authProvider}) : super(ProfileInitial());

  void loadUser() {
    final user = authProvider.user;
    if (user != null) {
      emit(ProfileLoaded(user));
    } else {
      emit(const ProfileError('Користувача не знайдено'));
    }
  }

  Future<void> updateName(String name) async {
    try {
      await authProvider.updateName(name);
      final user = authProvider.user;
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(const ProfileError('Користувача не знайдено після оновлення'));
      }
    } catch (e) {
      emit(const ProfileError('Помилка оновлення імені'));
    }
  }

  Future<void> deleteAccount() async {
    try {
      await authProvider.deleteAccount();
      emit(ProfileDeleted());
    } catch (e) {
      emit(const ProfileError('Помилка видалення акаунту'));
    }
  }
}
