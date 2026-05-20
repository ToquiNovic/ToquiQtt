import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../logic/blocs/mqtt_bloc.dart';
import 'publish_sheet.dart';
import 'subscribe_sheet.dart';

class MultiActionFab extends StatelessWidget {
  const MultiActionFab({super.key});

  @override
  Widget build(BuildContext context) {
    final mqttBloc = context.read<MqttBloc>();

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      backgroundColor: Colors.blueAccent,
      foregroundColor: Colors.white,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      spacing: 12,
      spaceBetweenChildren: 12,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.rss_feed),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          label: 'Nueva Suscripción',
          onTap: () => _showSubscribeSheet(context, mqttBloc),
        ),
        SpeedDialChild(
          child: const Icon(Icons.send),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          label: 'Publicar Mensaje',
          onTap: () => _showPublishSheet(context, mqttBloc),
        ),
        SpeedDialChild(
          child: const Icon(Icons.delete_sweep),
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          label: 'Limpiar Historial',
          onTap: () {
            mqttBloc.add(ClearChatHistory());

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Historial eliminado permanentemente"),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showSubscribeSheet(BuildContext context, MqttBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          BlocProvider.value(value: bloc, child: const SubscribeSheet()),
    );
  }

  void _showPublishSheet(BuildContext context, MqttBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          BlocProvider.value(value: bloc, child: const PublishSheet()),
    );
  }
}
