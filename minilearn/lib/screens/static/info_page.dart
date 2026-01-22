import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Supaya gradien penuh sampai atas
      appBar: AppBar(
        title: const Text(
          'Info & Panduan',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        // ✅ Background Gradien Konsisten
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A2980), // Deep Blue
              Color(0xFF26D0CE), // Light Teal
            ],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              const SizedBox(height: 10),
              _buildGlassFAQ(
                'Cara Mengakses Kursus',
                'Buka menu "Courses" di dashboard, pilih kategori yang Anda inginkan, lalu klik video pembelajaran.',
                Icons.play_lesson_outlined,
              ),
              _buildGlassFAQ(
                'Cara Melihat Pengumuman',
                'Pilih menu "Announcements" untuk melihat update terbaru dari admin mengenai jadwal atau promo.',
                Icons.campaign_outlined,
              ),
              _buildGlassFAQ(
                'Masalah Login?',
                'Pastikan koneksi internet stabil dan email Anda sudah terdaftar. Jika lupa password, hubungi admin@minilearn.com.',
                Icons.help_outline_rounded,
              ),
              _buildGlassFAQ(
                'Tentang Aplikasi',
                'MiniLearn adalah platform edukasi digital untuk membantu Anda belajar kapan saja dan di mana saja.',
                Icons.info_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Widget Helper untuk Bubble Glassmorphism
  Widget _buildGlassFAQ(String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1), // Efek kaca transparan
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2), // Border tipis efek kristal
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        // Menghilangkan garis divider bawaan ExpansionTile
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.cyanAccent),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          iconColor: Colors.white70,
          collapsedIconColor: Colors.white70,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Text(
                content,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}