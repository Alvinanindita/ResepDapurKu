// lib/screens/info_screen.dart

import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Aplikasi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 30, 205, 117), 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Resep Dapurku 📖',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 30, 205, 117),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 30, thickness: 1),
            
            _buildInfoTile(
              context,
              icon: Icons.developer_mode,
              title: 'Pengembang',
              subtitle: 'Alvina Nindita Nareswari',
            ),
            _buildInfoTile(
              context,
              icon: Icons.code,
              title: 'Teknologi',
              subtitle: 'Flutter (Dart) dengan Riverpod State Management',
            ),
            _buildInfoTile(
              context,
              icon: Icons.color_lens,
              title: 'Tema Utama',
              subtitle: 'Material Design 3 dengan skema warna Hijau',
            ),
            _buildInfoTile(
              context,
              icon: Icons.data_usage,
              title: 'Data',
              subtitle: 'Data resep disimpan secara lokal di dalam memori (Provider)',
            ),
    
           
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color.fromARGB(255, 30, 205, 117), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}