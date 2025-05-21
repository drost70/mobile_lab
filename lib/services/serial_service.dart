import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:logger/logger.dart';
import 'package:usb_serial/usb_serial.dart';

class SerialService {
  static final SerialService instance = SerialService._internal();

  UsbPort? _port;
  UsbDevice? _device;
  bool _isOpen = false;

  final Logger _logger = Logger();

  SerialService._internal();

  Future<List<UsbDevice>> getAvailableDevices() async {
    final devices = await UsbSerial.listDevices();

    for (final device in devices) {
      _logger.i(
        'USB Device found: '
        'Name=${device.deviceName}, '
        'VendorID=${device.vid}, '
        'ProductID=${device.pid}, '
        'DeviceID=${device.deviceId}',
      );
    }

    return devices;
  }

  Future<bool> setPort(UsbDevice device) async {
    try {
      if (_isOpen) {
        await closePort();
      }

      _device = device;
      _port = await device.create();
      if (_port == null) {
        _logger.e('Не вдалося створити порт для пристрою');
        return false;
      }

      final bool openResult = await _port!.open();
      if (!openResult) {
        _logger.e('Не вдалося відкрити порт');
        return false;
      }

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        9600,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      _isOpen = true;
      _logger.i('Порт відкрито для пристрою: ${device.deviceId}');
      return true;
    } catch (e) {
      _logger.e('Помилка при відкритті порту: $e');
      return false;
    }
  }

  Future<void> closePort() async {
    if (_isOpen && _port != null) {
      await _port!.close();
      _isOpen = false;
      _logger.i('Порт закрито');
    }
  }

  UsbDevice? get currentDevice => _device;

  Future<String?> readSavedData({Duration timeout = const Duration
  (seconds: 2),}) async {
    if (!_isOpen || _port == null) return null;

    try {
      final command = Uint8List.fromList(utf8.encode('READ\n'));
      await _port!.write(command);

      final buffer = <int>[];
      final completer = Completer<String?>();
      late StreamSubscription<List<int>> subscription;

      final timer = Timer(timeout, () {
        subscription.cancel();
        if (buffer.isEmpty) {
          completer.complete(null);
        } else {
          completer.complete(utf8.decode(buffer).trim());
        }
      });

      subscription = _port!.inputStream!.listen((data) {
        buffer.addAll(data);
        if (buffer.contains(10)) {
          timer.cancel();
          subscription.cancel();
          completer.complete(utf8.decode(buffer).trim());
        }
      });

      return await completer.future;
    } catch (e) {
      _logger.e('Помилка читання збережених даних: $e');
      return null;
    }
  }

  Future<bool> sendData(String data, {Duration timeout = const Duration
  (seconds: 2),}) async {
    if (!_isOpen || _port == null) return false;

    try {
      final bytes = Uint8List.fromList(utf8.encode(data));
      await _port!.write(bytes);
      return true;
    } catch (e) {
      _logger.e('Помилка надсилання даних: $e');
      return false;
    }
  }
}
