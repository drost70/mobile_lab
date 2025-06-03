import 'package:flutter/material.dart';
import 'package:my_project/blocs/home/home_cubit.dart';
import 'package:my_project/blocs/home/home_state.dart';
import 'package:my_project/screens/scan_screen.dart';

class HomeBody extends StatelessWidget {
  final HomeState state;
  final HomeCubit homeCubit;

  const HomeBody({required this.state, required this.homeCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
              DataDisplay(state: state),
              const SizedBox(height: 30),
              const Text(
                'Оберіть COM-порт:',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              PortDropdown(state: state, homeCubit: homeCubit),
              if (state.availablePorts.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Порти не знайдено. Підключіть USB-пристрій.',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              const SizedBox(height: 20),
              QRScanButton(enabled: state.availablePorts.isNotEmpty),
            ],
          ),
        ),
      ),
    );
  }
}

class DataDisplay extends StatelessWidget {
  final HomeState state;

  const DataDisplay({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Відстань утеплення теплиці:\n${state.distance.toStringAsFixed(2)} м',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          'Температура теплиці:\n${state.temperature.toStringAsFixed(1)}°C',
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
      ],
    );
  }
}

class PortDropdown extends StatelessWidget {
  final HomeState state;
  final HomeCubit homeCubit;

  const PortDropdown({required this.state, required this.homeCubit, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
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
        final selected =
            state.availablePorts.firstWhere((d) => d.deviceId == deviceId);
        homeCubit.selectPort(selected);
      },
    );
  }
}

class QRScanButton extends StatelessWidget {
  final bool enabled;

  const QRScanButton({required this.enabled, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.qr_code_scanner),
      label: const Text('Сканувати QR-код'),
      onPressed: enabled
          ? () {
              Navigator.push<Widget>(
                context,
                MaterialPageRoute<Widget>(builder: (_) => const ScanScreen()),
              );
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}
