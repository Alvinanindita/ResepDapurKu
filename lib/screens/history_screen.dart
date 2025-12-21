// lib/screens/history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  static const Color primaryLight = Color(0xFFEAF5EC); // Hijau Pucat/Latar Belakang Card
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Ambil data riwayat dari provider
    final historyRecipes = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Resep Terakhir', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 30, 205, 117), // primaryDark
        actions: [
          // Tombol untuk menghapus semua riwayat
          TextButton(
            onPressed: historyRecipes.isEmpty 
              ? null 
              : () {
                // Panggil fungsi clear dari notifier agar terhapus juga di memori HP
                ref.read(historyProvider.notifier).clearHistory();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat berhasil dibersihkan')),
                );
              },
            child: Text(
              'Hapus Semua',
              style: TextStyle(
                color: historyRecipes.isEmpty ? Colors.white54 : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: historyRecipes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat edit.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyRecipes.length,
              itemBuilder: (context, index) {
                // Karena HistoryNotifier sudah menyimpan yang terbaru di index 0,
                // kita langsung pakai index saja.
                final recipe = historyRecipes[index];
                return RecipeListItem(recipe: recipe);
              },
            ),
    );
  }
}