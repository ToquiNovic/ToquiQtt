// lib/data/models/message_model.dart
class ReceivedMessage {
  final String topic;
  final String payload;
  final DateTime timestamp;

  ReceivedMessage({
    required this.topic,
    required this.payload,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'topic': topic,
    'payload': payload,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ReceivedMessage.fromJson(Map<String, dynamic> json) =>
      ReceivedMessage(
        topic: json['topic'],
        payload: json['payload'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
