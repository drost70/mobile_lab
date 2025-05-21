import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_project/providers/auth_provider.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double _distance = 10;
  double _temperature = 20;
  String _lastUpdate = 'Ніколи';
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _startMqttUpdates();
  }

  @override
  void dispose() {
    _mqttService.disconnect();
    super.dispose();
  }

  void _startMqttUpdates() {
    _mqttService.onTemperatureReceived = (String value) {
      final double newTemperature = double.tryParse(value) ?? 0.0;
      setState(() {
        _temperature = newTemperature;
      });
      _saveToPrefs();
    };

    _mqttService.onDistanceReceived = (String value) {
      final double newDistance = double.tryParse(value) ?? 0.0;
      setState(() {
        _distance = newDistance;
      });
      _saveToPrefs();
    };

    _mqttService.connect();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastUpdate = 'Останнє оновлення: ${DateTime.now()}\n'
          'Відстань: ${_distance.toStringAsFixed(2)} м\n'
          'Температура: ${_temperature.toStringAsFixed(1)}°C';
    });
    await prefs.setDouble('distance', _distance);
    await prefs.setDouble('temperature', _temperature);
    await prefs.setString('lastUpdate', _lastUpdate);
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _distance = prefs.getDouble('distance') ?? 10;
      _temperature = prefs.getDouble('temperature') ?? 20;
      _lastUpdate = prefs.getString('lastUpdate') ?? 'Ніколи';
    });

    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      setState(() {});
    }
  }

  Future<void> _logout() async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

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

  if (confirm == true) {
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}

  @override
  Widget build(BuildContext context) {
    final userName =
        Provider.of<AuthProvider>(context).user?.name ?? 'Користувач';

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
                setState(() {});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/REG.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Відстань утеплення теплиці:\n'
                '${_distance.toStringAsFixed(2)} м',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Температура теплиці:\n'
                '${_temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _lastUpdate,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
