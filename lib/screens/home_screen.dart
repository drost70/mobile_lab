import 'package:flutter/material.dart'; 
import 'package:my_project/data/local_user_repository.dart';
import 'package:my_project/data/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final UserRepository _userRepository = LocalUserRepository();
  String _userName = 'Користувач';
  double _distance = 10;
  double _temperature = 20;
  String _lastUpdate = 'Ніколи';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _distance = prefs.getDouble('distance') ?? 10;
      _temperature = prefs.getDouble('temperature') ?? 20;
      _lastUpdate = prefs.getString('lastUpdate') ?? 'Ніколи';
    });

    final user = await _userRepository.getUser();
    if (user != null) {
      setState(() {
        _userName = user.name!;
      });
    }
  }

  Future<void> _logout() async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _updateDistance(double newDistance) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _distance = newDistance;
      _lastUpdate = 'Останнє оновлення: ${DateTime.now()}\n'
          'Відстань: ${_distance.toStringAsFixed(2)} м\n'
          'Температура: ${_temperature.toStringAsFixed(1)}°C';
    });
    await prefs.setDouble('distance', _distance);
    await prefs.setString('lastUpdate', _lastUpdate);
  }

  Future<void> _updateTemperature(double newTemperature) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _temperature = newTemperature;
      _lastUpdate = 'Останнє оновлення: ${DateTime.now()}\n'
          'Відстань: ${_distance.toStringAsFixed(2)} м\n'
          'Температура: ${_temperature.toStringAsFixed(1)}°C';
    });
    await prefs.setDouble('temperature', _temperature);
    await prefs.setString('lastUpdate', _lastUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Привіт, $_userName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () async {
              final updatedName = await Navigator.pushNamed(context, '/profile');
              if (updatedName != null && updatedName is String) {
                setState(() {
                  _userName = updatedName;
                });
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
                'Відстань утеплення теплиці: ${_distance.toStringAsFixed(2)} м',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white, 
                ),
                textAlign: TextAlign.center,
              ),
              Slider(
                value: _distance,
                max: 20,
                divisions: 20,
                label: '${_distance.toStringAsFixed(2)} м',
                onChanged: _updateDistance,
              ),
              const SizedBox(height: 20),
              Text(
                'Температура теплиці: ${_temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              Slider(
                value: _temperature,
                min: 10,
                max: 50,
                divisions: 40,
                label: '${_temperature.toStringAsFixed(1)}°C',
                onChanged: _updateTemperature,
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
