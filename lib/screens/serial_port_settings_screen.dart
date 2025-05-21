import 'package:flutter/material.dart';
import 'package:my_project/services/serial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialPortSettingsScreen extends StatefulWidget {
  const SerialPortSettingsScreen({super.key});

  @override
  State<SerialPortSettingsScreen> createState() =>
      _SerialPortSettingsScreenState();
}

class _SerialPortSettingsScreenState
    extends State<SerialPortSettingsScreen> {
  List<UsbDevice> devices = [];
  UsbDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    devices = await SerialService.instance.getAvailableDevices();

    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('serial_device_id');

    if (savedId != null) {
      try {
        selectedDevice =
            devices.firstWhere((d) => d.deviceId == savedId);
      } catch (e) {
        selectedDevice = devices.isNotEmpty ? devices[0] : null;
      }
    } else if (devices.isNotEmpty) {
      selectedDevice = devices[0];
    } else {
      selectedDevice = null;
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveSelectedDevice() async {
    if (selectedDevice == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (selectedDevice?.deviceId != null) {
      await prefs.setInt('serial_device_id', selectedDevice!.deviceId!);
    }

    final success = await SerialService.instance.setPort(selectedDevice!);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Порт збережено й активовано'
              : 'Не вдалося відкрити порт',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Налаштування USB-порту')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<UsbDevice>(
              isExpanded: true,
              value: selectedDevice,
              hint: const Text('Оберіть USB-пристрій'),
              items: devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(
                    '${device.productName} (${device.deviceId})',
                  ),
                );
              }).toList(),
              onChanged: (device) {
                setState(() {
                  selectedDevice = device;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedDevice == null ? null : _saveSelectedDevice,
              child: const Text('Зберегти та відкрити порт'),
            ),
          ],
        ),
      ),
    );
  }
}
