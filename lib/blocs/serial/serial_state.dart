import 'package:equatable/equatable.dart';
import 'package:usb_serial/usb_serial.dart';

abstract class SerialState extends Equatable {
  const SerialState();

  @override
  List<Object?> get props => [];
}

class SerialInitial extends SerialState {}

class SerialLoading extends SerialState {}

class SerialLoaded extends SerialState {
  final List<UsbDevice> devices;
  final UsbDevice? selectedDevice;
  final String? message;

  const SerialLoaded({
    required this.devices,
    required this.selectedDevice,
    this.message,
  });

  SerialLoaded copyWith({
    List<UsbDevice>? devices,
    UsbDevice? selectedDevice,
    String? message,
  }) {
    return SerialLoaded(
      devices: devices ?? this.devices,
      selectedDevice: selectedDevice ?? this.selectedDevice,
      message: message,
    );
  }

  @override
  List<Object?> get props => [devices, selectedDevice, message];
}

class SerialError extends SerialState {
  final String error;

  const SerialError(this.error);

  @override
  List<Object?> get props => [error];
}
