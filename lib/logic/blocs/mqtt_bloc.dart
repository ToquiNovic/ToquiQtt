import 'dart:developer'
    as dev; // Importamos la herramienta de logging profesional
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../data/models/broker_model.dart';

// --- Eventos ---
abstract class MqttEvent {}

class ConnectToBroker extends MqttEvent {
  final Broker broker;
  ConnectToBroker(this.broker);
}

class SubscribeToTopic extends MqttEvent {
  final String topic;
  SubscribeToTopic(this.topic);
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

// --- Estado ---
class MqttState {
  final MqttConnectionState connectionState;
  final List<String> subscribedTopics;
  final Map<String, String> latestMessages;
  final Broker? currentBroker;

  MqttState({
    this.connectionState = MqttConnectionState.disconnected,
    this.subscribedTopics = const [],
    this.latestMessages = const {},
    this.currentBroker,
  });

  MqttState copyWith({
    MqttConnectionState? connectionState,
    List<String>? subscribedTopics,
    Map<String, String>? latestMessages,
    Broker? currentBroker,
  }) {
    return MqttState(
      connectionState: connectionState ?? this.connectionState,
      subscribedTopics: subscribedTopics ?? this.subscribedTopics,
      latestMessages: latestMessages ?? this.latestMessages,
      currentBroker: currentBroker ?? this.currentBroker,
    );
  }
}

// --- BLoC ---
class MqttBloc extends Bloc<MqttEvent, MqttState> {
  MqttServerClient? client;

  MqttBloc() : super(MqttState()) {
    on<ConnectToBroker>((event, emit) async {
      dev.log('Iniciando conexión a ${event.broker.host}', name: 'MQTT_BLOC');

      emit(
        state.copyWith(
          connectionState: MqttConnectionState.connecting,
          currentBroker: event.broker,
        ),
      );

      client = MqttServerClient(event.broker.host, 'toqui_${event.broker.id}');
      client!.port = event.broker.port;
      client!.keepAlivePeriod = 20;

      try {
        await client!.connect();
        dev.log('Conexión establecida', name: 'MQTT_BLOC');
        emit(state.copyWith(connectionState: MqttConnectionState.connected));

        client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
          try {
            final recMess = c![0].payload as MqttPublishMessage;
            // Usamos una decodificación más robusta
            final pt = MqttPublishPayload.bytesToStringAsString(
              recMess.payload.message,
            );

            dev.log(
              '!!! DATA RECIBIDA !!! Tópico: ${c[0].topic} | Datos: $pt',
              name: 'MQTT_BLOC',
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

    on<UpdateBrokerInfo>((event, emit) {
      emit(state.copyWith(currentBroker: event.updatedBroker));
    });

    on<SubscribeToTopic>((event, emit) {
      if (client?.connectionStatus?.state == MqttConnectionState.connected) {
        dev.log('Suscribiéndose a: ${event.topic}', name: 'MQTT_BLOC');

        // Cambiamos a atLeastOnce (QoS 1) para asegurar que el broker reconozca la suscripción
        client!.subscribe(event.topic, MqttQos.atLeastOnce);

        // Evitamos duplicados en la lista de la UI
        if (!state.subscribedTopics.contains(event.topic)) {
          emit(
            state.copyWith(
              subscribedTopics: List.from(state.subscribedTopics)
                ..add(event.topic),
            ),
          );
        }
      }
    });

    on<_MessageReceived>((event, emit) {
      dev.log(
        'Actualizando estado con nuevo mensaje en ${event.topic}',
        name: 'MQTT_BLOC',
      );

      final newMessages = Map<String, String>.from(state.latestMessages);
      newMessages[event.topic] = event.message;

      emit(state.copyWith(latestMessages: newMessages));
    });
  }
}
