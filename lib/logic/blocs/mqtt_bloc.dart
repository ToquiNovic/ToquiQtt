import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../data/models/broker_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/subscription_model.dart';
import '../../data/repositories/subscription_repository.dart';

// --- Eventos ---
abstract class MqttEvent {}

class ConnectToBroker extends MqttEvent {
  final Broker broker;
  ConnectToBroker(this.broker);
}

class SubscribeToTopic extends MqttEvent {
  final MqttSubscription subscription;
  SubscribeToTopic(this.subscription);
}

class UpdateBrokerInfo extends MqttEvent {
  final Broker updatedBroker;
  UpdateBrokerInfo(this.updatedBroker);
}

class _MessageReceived extends MqttEvent {
  final String topic;
  final String message;
  _MessageReceived(this.topic, this.message);
}

class PublishMessage extends MqttEvent {
  final String topic;
  final String payload;
  final int qos;
  final bool retain;

  PublishMessage({
    required this.topic,
    required this.payload,
    this.qos = 0,
    this.retain = false,
  });
}

class ClearChatHistory extends MqttEvent {}

// --- Estado ---
class MqttState {
  final MqttConnectionState connectionState;
  final List<MqttSubscription> subscriptions;
  final Map<String, String> latestMessages;
  final List<ReceivedMessage> allMessages;
  final Broker? currentBroker;

  MqttState({
    this.connectionState = MqttConnectionState.disconnected,
    this.subscriptions = const <MqttSubscription>[],
    this.latestMessages = const <String, String>{},
    this.allMessages = const [],
    this.currentBroker,
  });

  MqttState copyWith({
    MqttConnectionState? connectionState,
    List<MqttSubscription>? subscriptions,
    Map<String, String>? latestMessages,
    List<ReceivedMessage>? allMessages,
    Broker? currentBroker,
  }) {
    return MqttState(
      connectionState: connectionState ?? this.connectionState,
      subscriptions: subscriptions ?? this.subscriptions,
      latestMessages: latestMessages ?? this.latestMessages,
      allMessages: allMessages ?? this.allMessages,
      currentBroker: currentBroker ?? this.currentBroker,
    );
  }
}

// --- BLoC ---
class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final SubscriptionRepository repository;
  MqttServerClient? client;
  StreamSubscription? _updatesSubscription;

  MqttBloc(this.repository) : super(MqttState()) {
    on<ConnectToBroker>((event, emit) async {
      dev.log('Iniciando conexión a ${event.broker.host}', name: 'MQTT_BLOC');

      final savedSubs = await repository.getSubscriptions(event.broker.id);
      final savedHistory = await repository.getMessageHistory(event.broker.id);

      emit(
        state.copyWith(
          connectionState: MqttConnectionState.connecting,
          currentBroker: event.broker,
          subscriptions: savedSubs,
          allMessages: savedHistory,
        ),
      );

      client = MqttServerClient(event.broker.host, 'toqui_${event.broker.id}');
      client!.port = event.broker.port;
      client!.keepAlivePeriod = 20;
      client!.logging(on: false);

      try {
        await client!.connect();
        dev.log('Conexión establecida', name: 'MQTT_BLOC');
        emit(state.copyWith(connectionState: MqttConnectionState.connected));

        for (var sub in savedSubs) {
          final qos = MqttQos.values[sub.qos.clamp(0, 2)];
          client!.subscribe(sub.topic, qos);
        }

        await _updatesSubscription?.cancel();
        _updatesSubscription = client!.updates!.listen((
          List<MqttReceivedMessage<MqttMessage?>>? c,
        ) {
          if (c == null || c.isEmpty) return;
          try {
            final recMess = c[0].payload as MqttPublishMessage;
            final pt = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message,
            );
            add(_MessageReceived(c[0].topic, pt));
          } catch (e) {
            dev.log('Error procesando payload', name: 'MQTT_BLOC', error: e);
          }
        });
      } catch (e) {
        dev.log('Error de conexión', name: 'MQTT_BLOC', error: e);
        emit(state.copyWith(connectionState: MqttConnectionState.faulted));
      }
    });

    on<SubscribeToTopic>((event, emit) async {
      if (client?.connectionStatus?.state == MqttConnectionState.connected) {
        final sub = event.subscription;
        final qos = MqttQos.values[sub.qos.clamp(0, 2)];

        client!.subscribe(sub.topic, qos);

        final updatedSubscriptions = List<MqttSubscription>.from(
          state.subscriptions,
        );

        final index = updatedSubscriptions.indexWhere(
          (s) => s.topic == sub.topic,
        );

        if (index != -1) {
          updatedSubscriptions[index] = sub;
          dev.log(
            'Actualizando tópico existente: ${sub.topic}',
            name: 'MQTT_BLOC',
          );
        } else {
          updatedSubscriptions.add(sub);
          dev.log('Agregando nuevo tópico: ${sub.topic}', name: 'MQTT_BLOC');
        }

        if (state.currentBroker != null) {
          await repository.saveSubscriptions(
            state.currentBroker!.id,
            updatedSubscriptions,
          );
        }

        emit(state.copyWith(subscriptions: updatedSubscriptions));
      }
    });

    on<_MessageReceived>((event, emit) async {
      final newMessage = ReceivedMessage(
        topic: event.topic,
        payload: event.message,
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<ReceivedMessage>.from(state.allMessages)
        ..insert(0, newMessage);

      if (state.currentBroker != null) {
        await repository.saveMessageHistory(
          state.currentBroker!.id,
          updatedMessages,
        );
      }

      emit(state.copyWith(allMessages: updatedMessages));
    });

    on<ClearChatHistory>((event, emit) async {
      if (state.currentBroker != null) {
        await repository.clearMessageHistory(state.currentBroker!.id);
      }
      emit(state.copyWith(allMessages: []));
    });

    on<PublishMessage>((event, emit) async {
      if (client?.connectionStatus?.state == MqttConnectionState.connected) {
        try {
          final builder = MqttClientPayloadBuilder();
          builder.addString(event.payload);

          final qos = MqttQos.values[event.qos.clamp(0, 2)];

          client!.publishMessage(
            event.topic,
            qos,
            builder.payload!,
            retain: event.retain,
          );

          dev.log('Mensaje publicado en: ${event.topic}', name: 'MQTT_BLOC');
        } catch (e) {
          dev.log('Error al publicar mensaje', name: 'MQTT_BLOC', error: e);
        }
      } else {
        dev.log('No se pudo publicar: Cliente no conectado', name: 'MQTT_BLOC');
      }
    });
  }

  @override
  Future<void> close() {
    _updatesSubscription?.cancel();
    client?.disconnect();
    return super.close();
  }
}
