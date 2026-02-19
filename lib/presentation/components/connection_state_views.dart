import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ConnectionStateGuard extends StatelessWidget {
  final MqttConnectionState state;
  final Widget child;
  final VoidCallback onRetry;

  const ConnectionStateGuard({
    super.key,
    required this.state,
    required this.child,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      MqttConnectionState.connecting => const LoadingView(),
      MqttConnectionState.connected => child,
      _ => ErrorView(onRetry: onRetry),
    };
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const Text("Error de conexión"),
          ElevatedButton(onPressed: onRetry, child: const Text("Reintentar")),
        ],
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String msg;
  const EmptyStateView({super.key, required this.msg});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(msg, style: const TextStyle(color: Colors.grey)),
    );
  }
}
