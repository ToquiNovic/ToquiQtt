import 'package:flutter/material.dart';
import '../../components/connection_state_views.dart';

class MessagesTabView extends StatelessWidget {
  final Map<String, String> messages;
  const MessagesTabView({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const EmptyStateView(msg: "No hay mensajes aún");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final topic = messages.keys.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.message, color: Colors.blue),
            title: Text(
              topic,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(messages[topic] ?? ''),
          ),
        );
      },
    );
  }
}
