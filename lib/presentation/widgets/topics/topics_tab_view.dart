import 'package:flutter/material.dart';
import '../topic_list_tile.dart';
import '../../components/connection_state_views.dart';

class TopicsTabView extends StatelessWidget {
  final List<String> topics;
  final Map<String, String> messages;

  const TopicsTabView({
    super.key,
    required this.topics,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const EmptyStateView(msg: "Sin suscripciones");

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return TopicListTile(
          topic: topic,
          value: messages[topic] ?? "Esperando...",
        );
      },
    );
  }
}
