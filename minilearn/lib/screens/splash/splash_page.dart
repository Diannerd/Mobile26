import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_notifier.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    // Tahan 1.5 detik lalu pindah halaman
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final auth = context.read<AuthNotifier>();
      // kalau sudah login -> ke courses, kalau belum -> ke login/register
      if (auth.user != null) {
        context.go('/courses');
      } else {
        context.go('/login'); // kalau kamu pakai register dulu, ganti jadi '/register'
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF8ED1FF), // biru muda
      body: Center(
        child: Text(
          'minilearn',
          style: TextStyle(
            fontFamily: 'MiniLearnFont', // harus sama dengan pubspec
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
