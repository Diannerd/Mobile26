import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_notifier.dart';
import '../../services/firestore_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final fs = context.read<FirestoreService>();
    final uid = auth.user!.uid;

    // ambil data profile
    final name = auth.displayName;
    final email = auth.user?.email ?? '-';
    final interest = auth.interest ?? '-';

    // decode foto base64 jika ada
    Uint8List? photoBytes;
    final b64 = auth.photoBase64;
    if (b64 != null && b64.isNotEmpty) {
      try {
        photoBytes = base64Decode(b64);
      } catch (_) {
        photoBytes = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF2149DD),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () => context.go('/profile/edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== Header Profile ======
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: const Color(0xFFE6E6FF),
                backgroundImage: photoBytes == null ? null : MemoryImage(photoBytes),
                child: photoBytes == null
                    ? const Icon(Icons.person, color: Color(0xFF2149DD), size: 30)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(email, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.interests, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('Interest: $interest', style: const TextStyle(color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/profile/edit'),
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2149DD),
                foregroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Text('Progress saya:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // ====== Progress ======
          StreamBuilder(
            stream: fs.userProgressStream(uid),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Text('Belum ada progress.');

              return Column(
                children: docs.map((doc) {
                  final d = doc.data();
                  final percent = (d['percent'] as num?)?.toDouble() ?? 0.0;
                  final courseId = (d['courseId'] ?? '').toString();

                  return Card(
                    child: ListTile(
                      title: Text('Course: $courseId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Progress: ${(percent * 100).toStringAsFixed(0)}%'),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(value: percent),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}
