import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';
import '../screens/add_recipe_screen.dart';
import '../providers/user_provider.dart';

class RecipeDetailSheet extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailSheet({super.key, required this.recipe});

  static const Color primaryColor = Color.fromARGB(255, 30, 205, 117);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(recipe.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 20),
                        // Top Badge & Emoji
                        Center(
                          child: Hero(
                            tag: 'recipe-emoji-${recipe.id}',
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                recipe.image,
                                style: const TextStyle(fontSize: 70),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Recipe Name
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Category Tag
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              recipe.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Info Row
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoItem(Icons.timer_outlined, recipe.cookTime, "Waktu"),
                              _buildVerticalDivider(),
                              _buildInfoItem(Icons.auto_awesome_outlined, recipe.difficulty, "Kesulitan"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Section Title: Deskripsi
                        _buildSectionTitle('Deskripsi'),
                        const SizedBox(height: 8),
                        Text(
                          recipe.description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Section Title: Bahan
                        _buildSectionTitle('Bahan-Bahan'),
                        const SizedBox(height: 12),
                        ...recipe.ingredients.map((ingredient) => _buildIngredientTile(ingredient)),
                        
                        const SizedBox(height: 40),

                        // Bottom Actions
                        Row(
                          children: [
                            _buildActionButton(
                              context, 
                              icon: Icons.edit_outlined, 
                              label: 'Edit', 
                              color: Colors.blue[700]!,
                              onTap: () => _editRecipe(context),
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              context, 
                              icon: Icons.delete_outline_rounded, 
                              label: 'Hapus', 
                              color: Colors.red[600]!,
                              onTap: () => _showDeleteConfirmation(context, ref),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Favorite Button
              Positioned(
                top: 20,
                right: 20,
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: IconButton.filled(
                    onPressed: () {
                      final newFavorites = Set<String>.from(favorites);
                      if (isFavorite) {
                        newFavorites.remove(recipe.id);
                      } else {
                        newFavorites.add(recipe.id);
                      }
                      ref.read(favoritesProvider.notifier).state = newFavorites;
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: isFavorite ? Colors.red : Colors.grey,
                    ),
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
    );
  }

  Widget _buildIngredientTile(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon, 
    required String label, 
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LOGIC METHODS
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Hapus Resep?'),
        content: Text('Apakah Anda yakin ingin menghapus "${recipe.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              final recipes = ref.read(recipesProvider);
              ref.read(recipesProvider.notifier).state = recipes.where((r) => r.id != recipe.id).toList();
              
              final favorites = ref.read(favoritesProvider);
              if (favorites.contains(recipe.id)) {
                final newFavorites = Set<String>.from(favorites)..remove(recipe.id);
                ref.read(favoritesProvider.notifier).state = newFavorites;
              }

              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${recipe.name} dihapus'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _editRecipe(BuildContext context) {
    Navigator.pop(context);
    showDialog(context: context, builder: (context) => AddRecipeDialog(recipe: recipe));
  }
}