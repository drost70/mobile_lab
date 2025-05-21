import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/home/home_cubit.dart';
import 'package:my_project/blocs/home/home_state.dart';
import 'package:my_project/providers/auth_provider.dart';
import 'package:my_project/screens/scan_screen.dart';
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

  Future<void> _checkWithIsolate(double temperature, double distance) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      isolateSensorCheck,
      [receivePort.sendPort, temperature, distance],
    );
    final result = await receivePort.first;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.toString()),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void isolateSensorCheck(List<dynamic> args) {
    final SendPort sendPort = args[0] as SendPort;
    final double temperature = args[1] as double;
    final double distance = args[2] as double;

    String message = '✅ Усі дані в нормі.';
    if (temperature < 10) {
      message = '❄️ Температура занизька!';
    } else if (temperature > 35) {
      message = '🔥 Температура зависока!';
    }

    if (distance < 3) {
      message += '\n⚠️ Відстань занадто мала!';
    }

    sendPort.send(message);
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
            body: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/REG.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Відстань утеплення теплиці:\n'
                        '${state.distance.toStringAsFixed(2)} м',
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
                        '${state.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        state.lastUpdate,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Оберіть COM-порт:',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      DropdownButton<int>(
                        dropdownColor: Colors.black87,
                        value: state.selectedPort?.deviceId,
                        hint: const Text(
                          'Оберіть порт',
                          style: TextStyle(color: Colors.white),
                        ),
                        items: state.availablePorts.map((device) {
                          return DropdownMenuItem(
                            value: device.deviceId,
                            child: Text(
                              device.deviceName,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (deviceId) {
                          if (deviceId == null) return;
                          final selected = state.availablePorts
                              .firstWhere((d) => d.deviceId == deviceId);
                          _homeCubit.selectPort(selected);
                        },
                      ),
                      if (state.availablePorts.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Порти не знайдено. Підключіть USB-пристрій.',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Сканувати QR-код'),
                        onPressed: state.availablePorts.isEmpty
                            ? null
                            : () {
                                Navigator.push<Widget>(
                                  context,
                                  MaterialPageRoute<Widget>(
                                    builder: (_) => const ScanScreen(),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
