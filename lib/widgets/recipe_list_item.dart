// lib/widgets/recipe_list_item.dart (MODIFIKASI TOTAL: Desain Daftar Lebih Dinamis)

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
  
  static const Color primaryDark = Color(0xFFE65100);

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

  // Metode untuk mendapatkan warna indikator kesulitan
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
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // Radius lebih besar
              border: Border.all(color: Colors.grey.shade100, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06), // Bayangan sedikit lebih tebal
                  spreadRadius: 0.5,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // 1. Emoji / Indikator Utama
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.recipe.image,
                    style: const TextStyle(fontSize: 28), // Ikon sedikit lebih besar
                  ),
                ),
                const SizedBox(width: 16),

                // 2. Recipe Info (Nama & Sub-info)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Resep
                      Text(
                        widget.recipe.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold, 
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      
                      // Row Info Detail
                      Row(
                        children: [
                          // Chip Waktu Memasak
                          _buildInfoChip(
                            icon: Icons.access_time, 
                            label: widget.recipe.cookTime, 
                            color: primaryDark
                          ),
                          const SizedBox(width: 8),

                          // Chip Kesulitan
                          _buildInfoChip(
                            icon: Icons.bookmark_border, 
                            label: widget.recipe.difficulty, 
                            color: difficultyColor
                          ),
                          const SizedBox(width: 8),
                          
                          // Chip Kategori (minimalis)
                          Text(
                            widget.recipe.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. Tombol Favorit
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey.shade400,
                  ),
                  onPressed: () {
                    final newFavorites = Set<String>.from(favorites);
                    if (isFavorite) {
                      newFavorites.remove(widget.recipe.id);
                    } else {
                      newFavorites.add(widget.recipe.id);
                    }
                    ref.read(favoritesProvider.notifier).state = newFavorites;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget kustom untuk membuat chip info (meminjam gaya dari detail sheet)
  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label.split(' ').first, // Hanya ambil nilai (misal: "20" dari "20 menit")
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}