// lib/widgets/recipe_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/user_provider.dart';
import 'recipe_detail_sheet.dart';

class RecipeListItem extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeListItem({super.key, required this.recipe});

  @override
  ConsumerState<RecipeListItem> createState() => _RecipeListItemState();
}

class _RecipeListItemState extends ConsumerState<RecipeListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Menggunakan warna hijau yang konsisten dengan tema Anda
  static const Color primaryDark = Color(0xFF1ECD75); 

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'mudah':
        return Colors.green;
      case 'sedang':
        return Colors.blue.shade700;
      case 'sulit':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.recipe.id);
    final difficultyColor = _getDifficultyColor(widget.recipe.difficulty);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: () {
          _controller.reverse();
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => RecipeDetailSheet(recipe: widget.recipe),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  spreadRadius: 0.5,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Emoji / Ikon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.recipe.image,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 12),

                // 2. Info Resep
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.recipe.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold, 
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Perbaikan Utama: Menggunakan Wrap agar tidak overflow
                      Wrap(
                        spacing: 6, // Jarak horizontal antar item
                        runSpacing: 4, // Jarak vertikal jika item turun ke bawah
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildInfoChip(
                            icon: Icons.access_time, 
                            label: widget.recipe.cookTime, 
                            color: Colors.orange.shade800
                          ),
                          _buildInfoChip(
                            icon: Icons.bookmark_border, 
                            label: widget.recipe.difficulty, 
                            color: difficultyColor
                          ),
                          // Gunakan Flexible di dalam Wrap agar teks kategori bisa dipotong jika terlalu panjang
                          Text(
                            widget.recipe.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Tombol Favorit
                // Di dalam lib/widgets/recipe_list_item.dart pada IconButton Favorit:
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey.shade400,
                    size: 22,
                  ),
                  onPressed: () {
                    // ✨ Cukup panggil fungsi toggleFavorite dari notifier
                    ref.read(favoritesProvider.notifier).toggleFavorite(widget.recipe.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label.split(' ').first, 
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}