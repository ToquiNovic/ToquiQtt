import 'package:flutter/material.dart';
import 'package:mix/mix.dart';
import '../../core/theme/toqui_styles.dart';

class TopicListTile extends StatelessWidget {
  final String topic;
  final String value;

  const TopicListTile({super.key, required this.topic, required this.value});

  @override
  Widget build(BuildContext context) {
    return Box(
      style: ToquiStyles.container,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  "Último mensaje recibido",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
