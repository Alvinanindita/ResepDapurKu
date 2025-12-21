// lib/widgets/recipe_card.dart 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/user_provider.dart';
import 'recipe_detail_sheet.dart';

class RecipeCard extends ConsumerStatefulWidget {
  final Recipe recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  ConsumerState<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends ConsumerState<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  // Mempertahankan konstanta warna dari Home Screen
   static const Color primaryDark = Color.fromARGB(255, 30, 205, 117); // #1ECD75 
  static const Color primaryMain = Color(0xFF4A9969);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) => _controller.forward();
  void _onTapUp(TapUpDetails details) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _showDeleteConfirmation() {
    // Implementasi dialog hapus
    // ...
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(widget.recipe.id);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());

        Future.delayed(const Duration(milliseconds: 150), () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => RecipeDetailSheet(recipe: widget.recipe),
          );
        });
      },
      onLongPress: () {
        // Haptic feedback
        // _showDeleteConfirmation(); 
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), 
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08), 
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========================= BAGIAN VISUAL ATAS (STACKED ICON) =========================
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lapisan Bawah (Warna Latar Belakang)
                    Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryMain.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    
                    // Ikon Resep di Tengah
                    Text(
                      widget.recipe.image,
                      style: const TextStyle(fontSize: 60),
                    ),

                    // Kategori sebagai Badge (di pojok kiri atas)
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryDark,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: primaryDark.withOpacity(0.3),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            )
                          ]
                        ),
                        child: Text(
                          widget.recipe.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Tombol Favorit (di pojok kanan atas)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          final newFavorites = Set<String>.from(favorites);
                          if (isFavorite) {
                            newFavorites.remove(widget.recipe.id);
                          } else {
                            newFavorites.add(widget.recipe.id);
                          }
                          ref.read(favoritesProvider.notifier).state = newFavorites;
                        },
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey.shade400,
                          size: 22, 
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ========================= BAGIAN DETAIL BAWAH =========================
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nama Resep
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w800, // Lebih tebal
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Info Bawah (Waktu Memasak dan Kesulitan)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          widget.recipe.cookTime,
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        
                        const Spacer(),

                        // Chip Kesulitan
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.recipe.difficulty,
                            style: TextStyle(
                              fontSize: 11, 
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}