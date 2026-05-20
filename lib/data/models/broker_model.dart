// data/models/broker_model.dart
import 'package:uuid/uuid.dart';

class Broker {
  final String id;
  final String name;
  final String host;
  final int port;
  final String clientId;
  final String? username;
  final String? password;
  final bool useSsl;

  Broker({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.clientId,
    this.username,
    this.password,
    this.useSsl = false,
  });


  factory Broker.fromJson(Map<String, dynamic> json) => Broker(
    id: json['id'],
    name: json['name'],
    host: json['host'],
    port: json['port'],
    clientId: json['clientId'],
    username: json['username'],
    password: json['password'],
    useSsl: json['useSsl'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'clientId': clientId,
    'username': username,
    'password': password,
    'useSsl': useSsl,
  };

  // --- HELPERS ---

  factory Broker.createDefault() {
    final uniqueId = const Uuid().v4();
    return Broker(
      id: uniqueId,
      name: '',
      host: '',
      port: 1883,
      clientId: 'toqui_${uniqueId.substring(0, 5)}',
    );
  }
}
