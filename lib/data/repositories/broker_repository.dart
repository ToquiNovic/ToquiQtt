import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/broker_model.dart';

class BrokerRepository {
  static const String _key = 'mqtt_brokers';

  Future<List<Broker>> getBrokers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_key);
      if (data == null) return [];

      final List<dynamic> decoded = jsonDecode(data);
      return decoded.map((e) => Broker.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveBroker(Broker broker) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Broker> current = await getBrokers();

    final int index = current.indexWhere((b) => b.id == broker.id);

    if (index >= 0) {
      current[index] = broker;
    } else {
      current.add(broker);
    }

    final String encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> deleteBroker(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Broker> current = await getBrokers();

    current.removeWhere((broker) => broker.id == id);

    final String encoded = jsonEncode(current.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}
