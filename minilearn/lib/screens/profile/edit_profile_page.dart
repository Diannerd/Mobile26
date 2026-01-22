import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart'; // Tambahkan ini

import '../../providers/auth_notifier.dart';
import '../../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  String _interest = 'IT';

  Uint8List? _pickedBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthNotifier>();
    final user = auth.user;

    _nameCtrl.text = user?.displayName ?? auth.profile?['displayName']?.toString() ?? '';
    _emailCtrl.text = user?.email ?? auth.profile?['email']?.toString() ?? '';

    final i = auth.profile?['interest']?.toString();
    if (i != null && i.isNotEmpty) _interest = i;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() => _pickedBytes = bytes);
  }

  Future<void> _save() async {
    final auth = context.read<AuthNotifier>();
    final fs = context.read<FirestoreService>();
    final user = auth.user;
    if (user == null) return;

    setState(() => _saving = true);

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final photoBase64 = _pickedBytes == null ? null : base64Encode(_pickedBytes!);

    try {
      // 1. Update Profile (Firestore) dulu agar data aman
      await fs.saveUserProfile(
        uid: user.uid,
        data: {
          'displayName': name,
          'email': email,
          'interest': _interest,
          if (photoBase64 != null) 'photoBase64': photoBase64,
        },
      );

      // 2. Update Firebase Auth Display Name
      if (name.isNotEmpty && name != (user.displayName ?? '')) {
        await user.updateDisplayName(name);
      }

      // 3. Update Email (Jika berubah)
      if (email.isNotEmpty && email != (user.email ?? '')) {
        await user.verifyBeforeUpdateEmail(email);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Link verifikasi email dikirim ✅')),
          );
        }
      }

      // 4. Sinkronisasi Data
      await user.reload();
      await auth.refreshUser();

      if (!mounted) return;
      
      // ✅ Gunakan context.pop() dari GoRouter agar sinkron dengan sistem rute
      context.pop(); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Glassy Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white24,
                                backgroundImage: _pickedBytes != null ? MemoryImage(_pickedBytes!) : null,
                                child: _pickedBytes == null 
                                  ? const Icon(Icons.person, size: 50, color: Colors.white) 
                                  : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.cyanAccent, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, size: 20, color: Color(0xFF1A2980)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(_nameCtrl, 'Full Name', Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildTextField(_emailCtrl, 'Email Address', Icons.email),
                        const SizedBox(height: 16),
                        
                        // Dropdown Glassy
                        DropdownButtonFormField<String>(
                          value: _interest, // Gunakan value, bukan initialValue
                          dropdownColor: const Color(0xFF1A2980),
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration('Interest', Icons.category_outlined),
                          items: ['IT', 'Math', 'Design'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _interest = v ?? 'IT'),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.cyanAccent,
                              foregroundColor: const Color(0xFF1A2980),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _saving 
                              ? const CircularProgressIndicator(color: Color(0xFF1A2980)) 
                              : const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper UI
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.cyanAccent),
      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label, icon),
    );
  }
}