import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon11.webp', // Pastikan path ini sesuai dengan folder Anda
                width: 80,          // Sesuaikan ukuran agar pas dengan desain Anda
                height: 80,
                fit: BoxFit.contain,
                ),
            const Text(
              'Aplikasi Resep Dapurku',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            
            const SizedBox(height: 30),
            const Text(
              'Resep Dapurku adalah aplikasi asisten dapur pribadi yang membantu Anda menemukan dan mengelola berbagai resep masakan lezat dengan mudah dan cepat.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 30),
            _buildFeatureSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fitur Utama:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        _featureItem(Icons.search, 'Pencarian Resep Cepat'),
        _featureItem(Icons.favorite, 'Simpan Resep Favorit'),
        _featureItem(Icons.grid_view, 'Tampilan Grid & List'),
        _featureItem(Icons.timer, 'Informasi Estimasi Memasak'),
        const Divider(height: 40),
        const Text(
          'Teknologi:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        const Text('Dibangun menggunakan Flutter untuk performa yang responsif.'),
      ],
    );
  }

  Widget _featureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: primaryDark),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}