import 'package:equatable/equatable.dart';
import 'package:usb_serial/usb_serial.dart';

class HomeState extends Equatable {
  final double distance;
  final double temperature;
  final String lastUpdate;
  final List<UsbDevice> availablePorts;
  final UsbDevice? selectedPort;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.distance = 10,
    this.temperature = 20,
    this.lastUpdate = 'Ніколи',
    this.availablePorts = const [],
    this.selectedPort,
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    double? distance,
    double? temperature,
    String? lastUpdate,
    List<UsbDevice>? availablePorts,
    UsbDevice? selectedPort,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      distance: distance ?? this.distance,
      temperature: temperature ?? this.temperature,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      availablePorts: availablePorts ?? this.availablePorts,
      selectedPort: selectedPort ?? this.selectedPort,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        distance,
        temperature,
        lastUpdate,
        availablePorts,
        selectedPort,
        isLoading,
        errorMessage,
      ];
}
