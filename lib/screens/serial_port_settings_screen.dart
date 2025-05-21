import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/blocs/serial/serial_cubit.dart';
import 'package:my_project/blocs/serial/serial_state.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialPortSettingsScreen extends StatelessWidget {
  const SerialPortSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SerialCubit()..loadDevices(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Налаштування USB-порту')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<SerialCubit, SerialState>(
            listener: (context, state) {
              if (state is SerialLoaded && state.message != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message!)),
                );
              } else if (state is SerialError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              if (state is SerialLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SerialLoaded) {
                return Column(
                  children: [
                    DropdownButton<UsbDevice>(
                      isExpanded: true,
                      value: state.selectedDevice,
                      hint: const Text('Оберіть USB-пристрій'),
                      items: state.devices.map((device) {
                        return DropdownMenuItem(
                          value: device,
                          child: Text('${device.productName} (${
                            device.deviceId})'),
                        );
                      }).toList(),
                      onChanged: (device) {
                        context.read<SerialCubit>().selectDevice(device);
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: state.selectedDevice == null
                          ? null
                          : () {
                              context.read<SerialCubit>().saveSelectedDevice();
                            },
                      child: const Text('Зберегти та відкрити порт'),
                    ),
                  ],
                );
              } else if (state is SerialError) {
                return Center(child: Text('Помилка: ${state.error}'));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
