import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blueAccent,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.blueGrey,
        tabs: const [
          Tab(text: "Mensajes", icon: Icon(Icons.mail_outline, size: 20)),
          Tab(text: "Tópicos", icon: Icon(Icons.list_alt, size: 20)),
        ],
      ),
    );
  }
}
