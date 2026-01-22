import 'dart:ui';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'About minilearn',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration( // Ini tetap const karena warna di sini statis
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2149DD),
              Color(0xFF1533AD),
              Color(0xFF0A1E6B),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Logo Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration( // 'const' dihapus karena ada withOpacity
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'mini',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900, // Perbaikan: Gunakan w900 sebagai ganti 'black'
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Card Transparan (Glassmorphism)
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration( // 'const' dihapus
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Tentang Kami',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'minilearn adalah platform edukasi digital revolusioner yang dirancang untuk menjembatani kesenjangan antara ambisi dan keahlian. Kami percaya bahwa pendidikan berkualitas tidak harus kaku dan sulit diakses.\n\n'
                            'Misi kami adalah memberdayakan individu untuk meningkatkan potensi mereka melalui materi belajar yang interaktif, kurikulum yang relevan dengan industri, dan pengalaman belajar yang bisa dilakukan kapan saja, di mana saja. Dengan minilearn, masa depan cerah ada di genggaman Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureBadge(Icons.bolt, 'Cepat'),
                    const SizedBox(width: 12),
                    _buildFeatureBadge(Icons.verified_user, 'Terpercaya'),
                    const SizedBox(width: 12),
                    _buildFeatureBadge(Icons.auto_awesome, 'Modern'),
                  ],
                ),
                
                const SizedBox(height: 60),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration( // 'const' dihapus
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}