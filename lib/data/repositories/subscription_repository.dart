import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import '../models/message_model.dart';

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

  Future<void> saveMessageHistory(
    String brokerId,
    List<ReceivedMessage> messages,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final historyToSave = messages.take(50).toList();

    final String data = jsonEncode(
      historyToSave.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('mqtt_history_$brokerId', data);
  }

  Future<List<ReceivedMessage>> getMessageHistory(String brokerId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('mqtt_history_$brokerId');
    if (data == null) return [];

    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => ReceivedMessage.fromJson(j)).toList();
  }

  Future<void> clearMessageHistory(String brokerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('mqtt_history_$brokerId');
  }
}
