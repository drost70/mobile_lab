import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/home/home_cubit.dart';
import 'package:my_project/blocs/home/home_state.dart';
import 'package:my_project/home_widgets/home_body.dart';
import 'package:my_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = HomeCubit();
    _homeCubit.loadUserData();
    _homeCubit.loadAvailablePorts();
  }

  @override
  void dispose() {
    _homeCubit.close();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження'),
        content: const Text('Ви впевнені, що хочете вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName =
        Provider.of<AuthProvider>(context).user?.name ?? 'Користувач';

    return BlocProvider<HomeCubit>(
      create: (_) => _homeCubit,
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Привіт, $userName!'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () async {
                    final updatedName =
                        await Navigator.pushNamed(context, '/profile');
                    if (!mounted) return;
                    if (updatedName != null && updatedName is String) {
                      _homeCubit.loadUserData();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            body: HomeBody(state: state, homeCubit: _homeCubit),
          );
        },
      ),
    );
  }
}
