import 'dart:async';
import 'dart:isolate';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/home/home_state.dart';
import 'package:my_project/services/serial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState()) {
    loadUserData();
    loadAvailablePorts();
  }

  Future<void> loadUserData() async {
    emit(state.copyWith(isLoading: true));
    final prefs = await SharedPreferences.getInstance();
    final distance = prefs.getDouble('distance') ?? 10;
    final temperature = prefs.getDouble('temperature') ?? 20;
    final lastUpdate = prefs.getString('lastUpdate') ?? 'Ніколи';

    emit(state.copyWith(
      distance: distance,
      temperature: temperature,
      lastUpdate: lastUpdate,
      isLoading: false,
    ),);
  }

  Future<void> loadAvailablePorts() async {
    final ports = await SerialService.instance.getAvailableDevices();
    UsbDevice? selected;
    if (ports.isNotEmpty) {
      selected = ports.first;
      SerialService.instance.setPort(selected);
    }
    emit(state.copyWith(
      availablePorts: ports,
      selectedPort: selected,
    ),);
  }

  void selectPort(UsbDevice device) {
    SerialService.instance.setPort(device);
    emit(state.copyWith(selectedPort: device));
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    emit(state.copyWith(isLoading: true));
    await prefs.setDouble('distance', state.distance);
    await prefs.setDouble('temperature', state.temperature);
    await prefs.setString('lastUpdate', state.lastUpdate);
    emit(state.copyWith(isLoading: false));
  }

  Future<String> checkWithIsolate() async {
    final receivePort = ReceivePort();
    await Isolate.spawn(
      _isolateSensorCheck,
      [receivePort.sendPort, state.temperature, state.distance],
    );
    final result = await receivePort.first as String;
    return result;
  }

  static void _isolateSensorCheck(List<dynamic> args) {
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

  // Додатково: методи для оновлення температури/відстані

  void updateDistance(double distance) {
    emit(state.copyWith(distance: distance));
  }

  void updateTemperature(double temperature) {
    emit(state.copyWith(temperature: temperature));
  }

  void updateLastUpdate() {
    final now = DateTime.now();
    final text = 'Останнє оновлення: $now\n'
        'Відстань: ${state.distance.toStringAsFixed(2)} м\n'
        'Температура: ${state.temperature.toStringAsFixed(1)}°C';
    emit(state.copyWith(lastUpdate: text));
  }
}
