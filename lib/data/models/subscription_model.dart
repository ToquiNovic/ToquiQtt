import 'package:equatable/equatable.dart';

class MqttSubscription extends Equatable {
  final String topic;
  final int qos;
  final String? alias;
  final int color;
  final int? identifier;
  final bool noLocal;
  final bool retainAsPublished;
  final int retainHandling;

  const MqttSubscription({
    required this.topic,
    this.qos = 0,
    this.alias,
    this.color = 0xFF2196F3,
    this.identifier,
    this.noLocal = false,
    this.retainAsPublished = false,
    this.retainHandling = 0,
  });

  @override
  List<Object?> get props => [
    topic,
    qos,
    alias,
    color,
    identifier,
    noLocal,
    retainAsPublished,
    retainHandling,
  ];

  factory MqttSubscription.fromJson(Map<String, dynamic> json) =>
      MqttSubscription(
        topic: json['topic'],
        qos: json['qos'] ?? 0,
        alias: json['alias'],
        color: json['color'] ?? 0xFF2196F3,
        identifier: json['identifier'],
        noLocal: json['noLocal'] ?? false,
        retainAsPublished: json['retainAsPublished'] ?? false,
        retainHandling: json['retainHandling'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'qos': qos,
    'alias': alias,
    'color': color,
    'identifier': identifier,
    'noLocal': noLocal,
    'retainAsPublished': retainAsPublished,
    'retainHandling': retainHandling,
  };
}
