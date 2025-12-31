import 'package:flutter/material.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengembang', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // --- BAGIAN FOTO PROFIL DIPERBARUI ---
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 60, // Ukuran sedikit diperbesar agar lebih jelas
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/foto.jpeg'),
                    ),
                  ),
                  // --------------------------------------
                  const SizedBox(height: 15),
                  const Text(
                    'Alvina Nindita Nareswari',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'NIM 2205101047',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDevCard(
                    icon: Icons.school,
                    title: 'Pendidikan',
                    content: 'Universitas PGRI Madiun',
                  ),
                  _buildDevCard(
                    icon: Icons.email_outlined,
                    title: 'Kontak',
                    content: 'alvinanindita28@gmail.com',
                  ),
                  _buildDevCard(
                    icon: Icons.link,
                    title: 'LinkedIn / GitHub',
                    content: '@alvinanindita',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '"Belajar dan berkarya melalui kode."',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevCard({required IconData icon, required String title, required String content}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryDark),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(content, style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }
}