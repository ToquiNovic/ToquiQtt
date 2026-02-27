// widgets/broker_list_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mix/mix.dart';
import '../../logic/blocs/broker_bloc.dart';
import '../../data/models/broker_model.dart';
import '../../core/theme/toqui_styles.dart';
import '../screens/topics_screen.dart';
import 'add_broker_sheet.dart';

class BrokerListView extends StatelessWidget {
  const BrokerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<BrokerBloc, BrokerState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.brokers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
            itemCount: state.brokers.length,
            itemBuilder: (context, index) {
              final broker = state.brokers[index];
              return _BrokerCard(broker: broker);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors_off, size: 60, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            'No hay brokers configurados.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _BrokerCard extends StatelessWidget {
  final Broker broker;
  const _BrokerCard({required this.broker});

  @override
  Widget build(BuildContext context) {
    return Box(
      style: ToquiStyles.container,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTag('TCP'), _buildMenu(context, broker)],
          ),
          const SizedBox(height: 10),
          Text(
            broker.host,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _infoIcon(
                Icons.settings_input_component,
                'Puerto: ${broker.port}',
              ),
              const SizedBox(width: 20),
              _infoIcon(Icons.fingerprint, _truncateId(broker.clientId)),
            ],
          ),
          const SizedBox(height: 20),
          Pressable(
            onPress: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TopicsScreen(broker: broker)),
            ),
            child: Box(
              style: ToquiStyles.connectButton,
              child: const StyledText('Conectar'),
            ),
          ),
        ],
      ),
    );
  }

  String _truncateId(String id) =>
      id.length > 12 ? '${id.substring(0, 12)}...' : id;

  Widget _buildTag(String text) =>
      Box(style: ToquiStyles.tagTcp, child: StyledText(text));

  Widget _infoIcon(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 16, color: Colors.blueGrey),
      const SizedBox(width: 6),
      Text(
        text,
        style: const TextStyle(
          color: Colors.blueGrey,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _buildMenu(BuildContext context, Broker broker) =>
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.grey),
        onSelected: (value) {
          if (value == 'delete') {
            context.read<BrokerBloc>().add(RemoveBroker(broker.id));
          } else if (value == 'edit') {
            _showEditSheet(context, broker);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Text('Editar'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Text('Eliminar'),
              ],
            ),
          ),
        ],
      );

  void _showEditSheet(BuildContext context, Broker broker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => AddBrokerSheet(brokerToEdit: broker),
    );
  }
}
