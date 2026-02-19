import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/blocs/mqtt_bloc.dart';
import '../../data/models/broker_model.dart';
import '../widgets/topics/topics_app_bar.dart';
import '../widgets/topics/messages_tab_view.dart';
import '../widgets/topics/topics_tab_view.dart';
import '../widgets/topics/subscribe_fab.dart';
import '../components/connection_state_views.dart';
import '../components/custom_tab_bar.dart';
import '../widgets/broker_info_card.dart';

class TopicsScreen extends StatelessWidget {
  final Broker broker;
  const TopicsScreen({super.key, required this.broker});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MqttBloc()..add(ConnectToBroker(broker)),
      child: DefaultTabController(
        length: 2,
        child: _TopicsView(fallbackBroker: broker),
      ),
    );
  }
}

class _TopicsView extends StatelessWidget {
  final Broker fallbackBroker;
  const _TopicsView({required this.fallbackBroker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopicsAppBar(),
      body: BlocBuilder<MqttBloc, MqttState>(
        builder: (context, state) {
          final currentBroker = state.currentBroker ?? fallbackBroker;

          return ConnectionStateGuard(
            state: state.connectionState,
            onRetry: () =>
                context.read<MqttBloc>().add(ConnectToBroker(currentBroker)),
            child: Column(
              children: [
                BrokerInfoCard(broker: currentBroker),
                const CustomTabBar(),
                Expanded(
                  child: TabBarView(
                    children: [
                      MessagesTabView(messages: state.latestMessages),
                      TopicsTabView(
                        topics: state.subscribedTopics,
                        messages: state.latestMessages,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: const SubscribeFab(),
    );
  }
}
