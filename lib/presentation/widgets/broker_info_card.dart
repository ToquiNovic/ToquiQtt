import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toquiqtt/logic/blocs/mqtt_bloc.dart';
import '../../data/models/broker_model.dart';
import '../widgets/add_broker_sheet.dart';

class BrokerInfoCard extends StatelessWidget {
  final Broker broker;

  const BrokerInfoCard({super.key, required this.broker});

  void _showEditSheet(BuildContext context) async {
    final mqttBloc = context.read<MqttBloc>();

    final updatedBroker = await showModalBottomSheet<Broker>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBrokerSheet(brokerToEdit: broker),
    );

    if (updatedBroker != null) {
      mqttBloc.add(UpdateBrokerInfo(updatedBroker));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CONEXIÓN ESTABLECIDA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(
                broker.useSsl ? Icons.lock : Icons.lock_open,
                color: Colors.white70,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            broker.host,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoItem(
                      Icons.settings_input_component,
                      'Puerto: ${broker.port}',
                    ),
                    const SizedBox(height: 8),
                    _infoItem(Icons.fingerprint, 'ID: ${broker.clientId}'),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              InkWell(
                onTap: () => _showEditSheet(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text(
                        "Editar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: Colors.white60, size: 14),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    ],
  );
}
