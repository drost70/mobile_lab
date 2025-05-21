import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:my_project/providers/auth_provider.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/screens/register_screen.dart';
import 'package:my_project/screens/scan_screen.dart';
import 'package:my_project/screens/serial_port_settings_screen.dart';
import 'package:my_project/services/internet_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadUser(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Greenhouse',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const RootScreen(),
        routes: {
          '/login': (_) => const LoginScreen(isConnected: true),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/scan': (_) => const ScanScreen(),
          '/serial_settings': (_) => const SerialPortSettingsScreen(),
        },
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends State<RootScreen> {
  final InternetService _internetService = InternetService();
  bool _isConnected = true;
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = _internetService.connectivityStream.listen
    ((ConnectivityResult result) {
      if (!mounted) return;

      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });

      if (!_isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Втрата з\'єднання з Інтернетом')),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.user != null) {
          return const HomeScreen();
        } else {
          return LoginScreen(isConnected: _isConnected);
        }
      },
    );
  }
}
