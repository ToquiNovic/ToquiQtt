// lib/presentation/widgets/topics/topic_list_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mix/mix.dart';
import '../../core/theme/toqui_styles.dart';
import '../../../data/models/subscription_model.dart';
import '../../../logic/blocs/mqtt_bloc.dart';
import './topics/subscribe_sheet.dart';

class TopicListTile extends StatefulWidget {
  final MqttSubscription
  subscription; 
  final String value;

  const TopicListTile({
    super.key,
    required this.subscription,
    required this.value,
  });

  @override
  State<TopicListTile> createState() => _TopicListTileState();
}

class _TopicListTileState extends State<TopicListTile> {
  bool _isExpanded = false;

  void _onEdit(BuildContext context) {
    final mqttBloc = context.read<MqttBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: mqttBloc,
        child: SubscribeSheet(subscriptionToEdit: widget.subscription),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.subscription;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Box(
        style: ToquiStyles.container,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Color(sub.color),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              sub.alias ?? sub.topic,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildQosBadge(sub.qos),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 25,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () => _onEdit(context),
                            visualDensity: VisualDensity.compact,
                          ),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            size: 25,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Text(
                        sub.alias != null ? sub.topic : "Tópico suscrito",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(height: 1),
                        ),
                        _buildMessageContent(),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Último mensaje recibido:",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
            ),
            child: Text(
              widget.value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQosBadge(int qos) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "QoS $qos",
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
