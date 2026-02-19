import 'package:flutter/material.dart';
import '../widgets/add_broker_sheet.dart';
import '../widgets/broker_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showAddBroker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBrokerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'ToquiQTT',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: const BrokerListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBroker(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
