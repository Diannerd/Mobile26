import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Menjalankan fungsi registrasi sesuai kode asli Anda
      final cred = await context.read<AuthService>().register(_email.text.trim(), _pass.text);
      await context.read<FirestoreService>().createUserIfMissing(
            uid: cred.user!.uid,
            email: cred.user!.email ?? _email.text.trim(),
          );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2149DD), // Hex #2149dd
      body: Stack(
        children: [
          // Dekorasi Latar Belakang (Opsional: Ikon buku agar tidak sepi)
          Positioned(
            top: -20,
            right: -20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(Icons.school, size: 250, color: Colors.white),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  
                  // Logo minilearn (Sesuai font desain sebelumnya)
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                      ),
                      children: [
                        TextSpan(text: 'mini', style: TextStyle(color: Colors.white)),
                        TextSpan(text: 'learn', style: TextStyle(color: Color(0xFFF9E79F))),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Text(
                    'Create an account to start your journey',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 50),

                  // Input Email
                  _buildInputField(
                    controller: _email,
                    hint: 'Email Address',
                    icon: Icons.email_outlined,
                  ),
                  
                  const SizedBox(height: 15),

                  // Input Password
                  _buildInputField(
                    controller: _pass,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  // Error Message
                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Tombol Register
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2149DD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      child: _loading 
                        ? const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2149DD))
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // Tombol Kembali ke Login
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 15),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Login",
                            style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk merapikan tampilan TextField
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}