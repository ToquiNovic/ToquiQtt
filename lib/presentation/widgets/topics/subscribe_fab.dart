import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/mqtt_bloc.dart';

class SubscribeFab extends StatelessWidget {
  const SubscribeFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showSubscribeDialog(context),
      label: const Text("Nuevo Tópico"),
      icon: const Icon(Icons.add),
    );
  }

  void _showSubscribeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Suscribirse"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<MqttBloc>().add(SubscribeToTopic(controller.text));
              }
              Navigator.pop(ctx);
            },
            child: const Text("Suscribir"),
          ),
        ],
      ),
    );
  }
}
