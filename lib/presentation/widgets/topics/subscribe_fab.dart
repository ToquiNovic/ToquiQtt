import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/mqtt_bloc.dart';
import '../../../data/models/subscription_model.dart';
import 'subscribe_sheet.dart';

class SubscribeFab extends StatelessWidget {
  const SubscribeFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showSubscribeDialog(context),
      backgroundColor: Colors.blueAccent,
      label: const Text(
        "Nueva Suscripción",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showSubscribeDialog(BuildContext context) {
    final mqttBloc = context.read<MqttBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          BlocProvider.value(value: mqttBloc, child: const SubscribeSheet()),
    );
  }
}

class _SubscribeDialogContent extends StatefulWidget {
  const _SubscribeDialogContent();
  @override
  State<_SubscribeDialogContent> createState() =>
      _SubscribeDialogContentState();
}

class _SubscribeDialogContentState extends State<_SubscribeDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _aliasController = TextEditingController();
  final _idController = TextEditingController();

  int _qos = 0;
  Color _selectedColor = Colors.blue;
  bool _noLocal = false;
  final bool _retainAsPublished = false;
  final int _retainHandling = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nueva Suscripción"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: "Tópico *"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              DropdownButtonFormField<int>(
                initialValue: _qos,
                decoration: const InputDecoration(labelText: "QoS"),
                items: [0, 1, 2]
                    .map(
                      (i) => DropdownMenuItem(value: i, child: Text("QoS $i")),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _qos = v!),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text("Color: "),
                  ...[Colors.blue, Colors.red, Colors.green].map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: c,
                          child: _selectedColor == c
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(labelText: "Alias"),
              ),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(labelText: "Identifier"),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text("No Local"),
                value: _noLocal,
                onChanged: (v) => setState(() => _noLocal = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final sub = MqttSubscription(
                topic: _topicController.text,
                qos: _qos,
                alias: _aliasController.text.isEmpty
                    ? null
                    : _aliasController.text,
                color: _selectedColor.toARGB32(),
                identifier: int.tryParse(_idController.text),
                noLocal: _noLocal,
                retainAsPublished: _retainAsPublished,
                retainHandling: _retainHandling,
              );
              context.read<MqttBloc>().add(SubscribeToTopic(sub));
              Navigator.pop(context);
            }
          },
          child: const Text("Suscribir"),
        ),
      ],
    );
  }
}
