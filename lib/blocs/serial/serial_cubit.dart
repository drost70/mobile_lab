import 'package:bloc/bloc.dart';
import 'package:my_project/blocs/serial/serial_state.dart';
import 'package:my_project/services/serial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialCubit extends Cubit<SerialState> {
  final SerialService serialService;
  final SharedPreferences prefs;

  SerialCubit({
    required this.serialService,
    required this.prefs,
  }) : super(SerialInitial());

  Future<void> loadDevices() async {
    emit(SerialLoading());
    try {
      final devices = await serialService.getAvailableDevices();
      final savedId = prefs.getInt('serial_device_id');

      UsbDevice? selectedDevice;

      if (savedId != null) {
        try {
          selectedDevice = devices.firstWhere((d) => d.deviceId == savedId);
        } catch (_) {
          selectedDevice = devices.isNotEmpty ? devices[0] : null;
        }
      } else {
        selectedDevice = devices.isNotEmpty ? devices[0] : null;
      }

      emit(SerialLoaded(devices: devices, selectedDevice: selectedDevice));
    } catch (e) {
      emit(SerialError('Не вдалося завантажити пристрої: $e'));
    }
  }

  void selectDevice(UsbDevice? device) {
    if (state is SerialLoaded) {
      final currentState = state as SerialLoaded;
      emit(currentState.copyWith(selectedDevice: device));
    }
  }

  Future<void> saveSelectedDevice() async {
    if (state is SerialLoaded) {
      final currentState = state as SerialLoaded;
      final device = currentState.selectedDevice;
      if (device == null || device.deviceId == null) return;

      try {
        await prefs.setInt('serial_device_id', device.deviceId!);
        final success = await serialService.setPort(device);

        final message = success
            ? 'Порт збережено й активовано'
            : 'Не вдалося відкрити порт';

        emit(currentState.copyWith(message: message));
      } catch (e) {
        emit(SerialError('Помилка збереження порту: $e'));
      }
    }
  }
}
