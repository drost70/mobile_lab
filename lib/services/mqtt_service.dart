import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

typedef OnMessageReceived = void Function(String message);

class MqttService {
  final _client = MqttServerClient(
    'test.mosquitto.org',
    'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
  );
  final String topic = 'sensor/data';
  OnMessageReceived? onTemperatureReceived;
  OnMessageReceived? onDistanceReceived;

  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 500);

  final logger = Logger();

  Future<void> connect() async {
    _client.port = 1883;
    _client.keepAlivePeriod = 60;
    _client.onDisconnected = onDisconnected;
    _client.onConnected = onConnected;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client_id')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } catch (e) {
      logger.e('MQTT Connection failed: $e');
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      logger.i('✅ MQTT Connected');
      _client.subscribe(topic, MqttQos.atMostOnce);

      _client.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage>> messages) {
          final recMess = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          logger.i('📥 MQTT message: $payload');

          _handleMqttMessage(payload);
        },
      );
    }
  }

  void _handleMqttMessage(String payload) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(_debounceDuration, () {
      try {
        final data = jsonDecode(payload);
        if (data is Map<String, dynamic> &&
            data.containsKey('temperature') &&
            data.containsKey('distance')) {
          final temperature = data['temperature'].toString();
          final distance = data['distance'].toString();

          onTemperatureReceived?.call(temperature);
          onDistanceReceived?.call(distance);
        }
      } catch (e) {
        logger.e('Invalid JSON message: $payload');
      }
    });
  }

  void disconnect() {
    _client.disconnect();
  }

  void onDisconnected() {
    logger.w('⚠️ MQTT Disconnected');
  }

  void onConnected() {
    logger.i('🔌 MQTT Connected callback');
  }
}
