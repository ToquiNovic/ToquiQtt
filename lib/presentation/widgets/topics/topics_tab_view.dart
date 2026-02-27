import 'package:flutter/material.dart';
import '../topic_list_tile.dart';
import '../../components/connection_state_views.dart';
import '../../../data/models/subscription_model.dart';

class TopicsTabView extends StatelessWidget {
  final List<MqttSubscription> subscriptions;
  final Map<String, String> messages;

  const TopicsTabView({
    super.key,
    required this.subscriptions,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const EmptyStateView(msg: "Sin suscripciones");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final sub = subscriptions[index];
        final topicKey = sub.topic;

        return TopicListTile(
          subscription: sub,
          value: messages[topicKey] ?? "Esperando...",
        );
      },
    );
  }
}
