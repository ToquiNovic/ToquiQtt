import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/mqtt_bloc.dart';

class TopicsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopicsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: BlocBuilder<MqttBloc, MqttState>(
        buildWhen: (prev, curr) =>
            prev.currentBroker?.name != curr.currentBroker?.name,
        builder: (context, state) {
          final name = state.currentBroker?.name ?? 'Broker';
          return Text(name.isEmpty ? 'Broker' : name);
        },
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
