import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';

class SubscriptionRepository {
  static const String _keyPrefix = 'mqtt_subs_';

  Future<void> saveSubscriptions(
    String brokerId,
    List<MqttSubscription> subs,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = jsonEncode(subs.map((s) => s.toJson()).toList());
    await prefs.setString('$_keyPrefix$brokerId', data);
  }

  Future<List<MqttSubscription>> getSubscriptions(String brokerId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('$_keyPrefix$brokerId');
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => MqttSubscription.fromJson(j)).toList();
  }
}
