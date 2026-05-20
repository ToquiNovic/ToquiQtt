import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/message_model.dart';
import '../../components/connection_state_views.dart';

class MessagesTabView extends StatelessWidget {
  final List<ReceivedMessage> allMessages;
  final List<MqttSubscription> subscriptions;

  const MessagesTabView({
    super.key,
    required this.allMessages,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    if (allMessages.isEmpty) {
      return const EmptyStateView(msg: "No hay mensajes aún");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: allMessages.length,
      itemBuilder: (context, index) {
        final msg = allMessages[index];

        final sub = subscriptions.firstWhere(
          (s) => s.topic == msg.topic,
          orElse: () => const MqttSubscription(topic: '', color: 0xFF26C281),
        );

        final time = DateFormat(
          'yyyy-MM-dd HH:mm:ss:SSS',
        ).format(msg.timestamp);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F6F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(sub.color),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(7),
                          topRight: Radius.circular(7),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              sub.alias != null
                                  ? "Alias: ${sub.alias}"
                                  : "Topic: ${msg.topic}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "QoS: ${sub.qos}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (sub.alias != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "Topic: ${msg.topic}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blueGrey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          Text(
                            msg.payload,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 2),
                child: Text(
                  time,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
