import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnglishProContentPage extends StatefulWidget {
  const EnglishProContentPage({super.key});

  @override
  State<EnglishProContentPage> createState() => _EnglishProContentPageState();
}

class _EnglishProContentPageState extends State<EnglishProContentPage> {
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('English Pro Content', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chapter 1: Welcome to English Pro",
                    style: TextStyle(color: Colors.cyanAccent, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  Text(
                    """
PASTE TEKS EBOOK KAMU DI SINI...
Contoh: Professional English focuses on clear communication.
It includes business vocabulary, formal emails, and presentations.
                    """,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: _fontSize,
                      height: 1.6,
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
}