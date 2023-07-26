import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient setup(String serverAddress, String uniqueID, int port) {
  return MqttBrowserClient.withPort('ws://'+serverAddress+'/mqtt', uniqueID, 9001);
}

