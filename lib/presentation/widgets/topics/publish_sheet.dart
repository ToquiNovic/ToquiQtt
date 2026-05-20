import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/subscription_model.dart';
import '../../../logic/blocs/mqtt_bloc.dart';
import '../custom_inputs.dart';

class PublishSheet extends StatefulWidget {
  const PublishSheet({super.key});

  @override
  State<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends State<PublishSheet> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();

  int _qos = 0;
  bool _retain = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _topicController.addListener(_validateForm);
    _payloadController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        _topicController.text.trim().isNotEmpty &&
        _payloadController.text.trim().isNotEmpty;
    if (isValid != _isFormValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  void _onPublish() {
    context.read<MqttBloc>().add(
      PublishMessage(
        topic: _topicController.text.trim(),
        payload: _payloadController.text.trim(),
        qos: _qos,
        retain: _retain,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final subscriptions = context.select(
      (MqttBloc bloc) => bloc.state.subscriptions,
    );

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
                const Text(
                  'Publicar Mensaje',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _buildTopicAutocomplete(subscriptions),

                const SizedBox(height: 15),

                ToquiTextField(
                  label: 'Mensaje (Payload) *',
                  controller: _payloadController,
                  hint: 'ej. {"status": "ON"} o texto plano',
                  maxLines:
                      4, 
                ),

                const SizedBox(height: 15),
                _buildQosDropdown(),

                const Divider(height: 30),
                _buildRetainFlag(),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isFormValid ? _onPublish : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'PUBLICAR',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicAutocomplete(List<MqttSubscription> subscriptions) {
    return Autocomplete<MqttSubscription>(
      displayStringForOption: (MqttSubscription option) => option.topic,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return subscriptions;
        }
        return subscriptions.where((MqttSubscription option) {
          final matchesTopic = option.topic.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
          final matchesAlias =
              option.alias?.toLowerCase().contains(
                textEditingValue.text.toLowerCase(),
              ) ??
              false;
          return matchesTopic || matchesAlias;
        });
      },
      onSelected: (MqttSubscription selection) {
        _topicController.text = selection.topic;
        setState(() {
          _qos = selection
              .qos; 
        });
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
            if (_topicController.text != textEditingController.text &&
                _topicController.text.isNotEmpty) {
              textEditingController.text = _topicController.text;
            }

            textEditingController.addListener(() {
              _topicController.text = textEditingController.text;
            });

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Tópico *',
                hintText: 'Escribe o selecciona un tópico...',
                prefixIcon: const Icon(Icons.label_outline, size: 20),
                suffixIcon: subscriptions.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.arrow_drop_down),
                        onPressed: () {
                          if (!focusNode.hasFocus) {
                            focusNode.requestFocus();
                          }
                        },
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
              ),
            );
          },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (BuildContext context, int index) {
                  final MqttSubscription option = options.elementAt(index);
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 8,
                      backgroundColor: Color(option.color),
                    ),
                    title: Text(
                      option.alias ?? option.topic,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: option.alias != null ? Text(option.topic) : null,
                    trailing: Chip(
                      label: Text('QoS ${option.qos}'),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
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

  Widget _buildRetainFlag() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text(
        'Retener Mensaje (Retain)',
        style: TextStyle(fontSize: 14),
      ),
      subtitle: const Text(
        'El broker guardará este mensaje para nuevos suscriptores',
        style: TextStyle(fontSize: 11),
      ),
      value: _retain,
      onChanged: (v) => setState(() => _retain = v),
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
    _payloadController.dispose();
    super.dispose();
  }
}
