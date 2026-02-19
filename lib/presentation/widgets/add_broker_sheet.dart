import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/broker_model.dart';
import '../../logic/blocs/broker_bloc.dart';
import 'custom_inputs.dart';

class AddBrokerSheet extends StatefulWidget {
  final Broker? brokerToEdit;
  const AddBrokerSheet({super.key, this.brokerToEdit});

  @override
  State<AddBrokerSheet> createState() => _AddBrokerSheetState();
}

class _AddBrokerSheetState extends State<AddBrokerSheet> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _clientIdController;
  late TextEditingController _userController;
  late TextEditingController _passController;
  late bool _useSsl;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    final b = widget.brokerToEdit;
    _hostController = TextEditingController(text: b?.host ?? '');
    _portController = TextEditingController(text: b?.port.toString() ?? '1883');
    _clientIdController = TextEditingController(
      text: b?.clientId ?? 'toqui_${const Uuid().v4().substring(0, 5)}',
    );
    _userController = TextEditingController(text: b?.username ?? '');
    _passController = TextEditingController(text: b?.password ?? '');
    _useSsl = b?.useSsl ?? false;

    _hostController.addListener(
      () => setState(() => _isFormValid = _hostController.text.isNotEmpty),
    );
    _isFormValid = _hostController.text.isNotEmpty;
  }

  void _onSave() {
    final broker = Broker(
      id: widget.brokerToEdit?.id ?? const Uuid().v4(),
      name: _hostController
          .text,
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text) ?? 1883,
      clientId: _clientIdController.text.trim(),
      username: _userController.text.trim().isEmpty
          ? null
          : _userController.text.trim(),
      password: _passController.text.trim().isEmpty
          ? null
          : _passController.text.trim(),
      useSsl: _useSsl,
    );

    if (widget.brokerToEdit != null) {
      context.read<BrokerBloc>().add(UpdateBroker(broker));
    } else {
      context.read<BrokerBloc>().add(AddBroker(broker));
    }

    Navigator.pop(context, broker);
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
                  widget.brokerToEdit != null
                      ? 'Editar Broker'
                      : 'Nuevo Broker',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ToquiTextField(
                  label: 'Host *',
                  controller: _hostController,
                  hint: 'ej. broker.emqx.io',
                ),
                ToquiTextField(
                  label: 'Puerto *',
                  controller: _portController,
                  isNumber: true,
                ),

                Row(
                  crossAxisAlignment: CrossAxisAlignment
                      .start,
                  children: [
                    Expanded(
                      child: ToquiTextField(
                        label: 'Client ID',
                        controller: _clientIdController,
                      ),
                    ),
                    IconButton(
                      padding: const EdgeInsets.only(top: 10),
                      icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                      onPressed: () => setState(
                        () => _clientIdController.text =
                            'toqui_${const Uuid().v4().substring(0, 5)}',
                      ),
                    ),
                  ],
                ),

                ToquiTextField(label: 'Usuario', controller: _userController),
                ToquiTextField(
                  label: 'Contraseña',
                  controller: _passController,
                  isPassword: true,
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Usar SSL/TLS',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  value: _useSsl,
                  activeThumbColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _useSsl = v),
                ),

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
                    widget.brokerToEdit != null ? 'ACTUALIZAR' : 'GUARDAR',
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
    _hostController.dispose();
    _portController.dispose();
    _clientIdController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
