import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  
  Widget build(BuildContext context) {
    final fs = context.read<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: StreamBuilder(
        stream: fs.announcementsStream(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Belum ada pengumuman'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data();
              return Card(
                child: ListTile(
                  title: Text((d['title'] ?? 'No title').toString()),
                  subtitle: Text((d['body'] ?? '').toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
