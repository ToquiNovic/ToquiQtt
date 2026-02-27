import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/subscription_model.dart';
import '../../../logic/blocs/mqtt_bloc.dart';
import '../custom_inputs.dart';

class SubscribeSheet extends StatefulWidget {
  final MqttSubscription? subscriptionToEdit;

  const SubscribeSheet({super.key, this.subscriptionToEdit});

  @override
  State<SubscribeSheet> createState() => _SubscribeSheetState();
}

class _SubscribeSheetState extends State<SubscribeSheet> {
  late TextEditingController _topicController;
  late TextEditingController _aliasController;
  late TextEditingController _idController;

  late int _qos;
  late Color _selectedColor;
  late bool _noLocal;
  late bool _retainAsPublished;
  final int _retainHandling = 0;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscriptionToEdit;

    _topicController = TextEditingController(text: sub?.topic ?? '');
    _aliasController = TextEditingController(text: sub?.alias ?? '');
    _idController = TextEditingController(
      text: sub?.identifier?.toString() ?? '',
    );

    _qos = sub?.qos ?? 0;
    _selectedColor = sub != null ? Color(sub.color) : Colors.blue;
    _noLocal = sub?.noLocal ?? false;
    _retainAsPublished = sub?.retainAsPublished ?? false;

    _topicController.addListener(() {
      setState(() => _isFormValid = _topicController.text.isNotEmpty);
    });

    _isFormValid = _topicController.text.isNotEmpty;
  }

  void _onSave() {
    final sub = MqttSubscription(
      topic: _topicController.text.trim(),
      qos: _qos,
      alias: _aliasController.text.trim().isEmpty
          ? null
          : _aliasController.text.trim(),
      color: _selectedColor.toARGB32(),
      identifier: int.tryParse(_idController.text),
      noLocal: _noLocal,
      retainAsPublished: _retainAsPublished,
      retainHandling: _retainHandling,
    );

    if (widget.subscriptionToEdit != null) {
      context.read<MqttBloc>().add(SubscribeToTopic(sub));
    } else {
      context.read<MqttBloc>().add(SubscribeToTopic(sub));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            25,
            12,
            25,
            bottomInset > 0 ? bottomInset + 10 : 10,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHandle(),
                const SizedBox(height: 20),
                Text(
                  widget.subscriptionToEdit != null
                      ? 'Editar Suscripción'
                      : 'Nueva Suscripción',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ToquiTextField(
                  label: 'Tópico *',
                  controller: _topicController,
                  hint: 'ej. sensores/+/temperatura',
                ),
                ToquiTextField(
                  label: 'Alias (Opcional)',
                  controller: _aliasController,
                  hint: 'ej. Temp Cocina',
                ),

                const SizedBox(height: 15),
                _buildColorSelector(),
                const SizedBox(height: 15),

                _buildQosDropdown(),

                const SizedBox(height: 10),
                ToquiTextField(
                  label: 'ID de Suscripción (Opcional)',
                  controller: _idController,
                  isNumber: true,
                  hint: 'Número entre 1 y 268M',
                ),

                const Divider(height: 30),
                _buildMqtt5Flags(),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isFormValid ? _onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    widget.subscriptionToEdit != null
                        ? 'ACTUALIZAR'
                        : 'SUSCRIBIRSE',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQosDropdown() {
    return DropdownButtonFormField<int>(
      initialValue: _qos,
      decoration: const InputDecoration(
        labelText: 'Calidad de Servicio (QoS)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 0, child: Text("QoS 0 - At most once")),
        DropdownMenuItem(value: 1, child: Text("QoS 1 - At least once")),
        DropdownMenuItem(value: 2, child: Text("QoS 2 - Exactly once")),
      ],
      onChanged: (v) => setState(() => _qos = v!),
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.cyan,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Color de Identificación",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: c,
                    child: _selectedColor.toARGB32() == c.toARGB32()
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMqtt5Flags() {
    return Column(
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('No Local', style: TextStyle(fontSize: 14)),
          subtitle: const Text(
            'No recibir mensajes propios',
            style: TextStyle(fontSize: 11),
          ),
          value: _noLocal,
          onChanged: (v) => setState(() => _noLocal = v),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'Retain as Published',
            style: TextStyle(fontSize: 14),
          ),
          value: _retainAsPublished,
          onChanged: (v) => setState(() => _retainAsPublished = v),
        ),
      ],
    );
  }

  Widget _buildHandle() => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10),
    ),
  );

  @override
  void dispose() {
    _topicController.dispose();
    _aliasController.dispose();
    _idController.dispose();
    super.dispose();
  }
}
