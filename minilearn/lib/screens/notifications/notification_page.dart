import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2149DD),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Belum ada notifikasi.'),
      ),
    );
  }
}
