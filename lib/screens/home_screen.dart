// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_providers.dart';
import '../providers/user_provider.dart'; 
import '../widgets/category_chip.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_list_item.dart';
import 'add_recipe_screen.dart';

class RecipeHomePage extends ConsumerWidget {
  const RecipeHomePage({super.key});

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117); 
  static const Color primaryMain = Color(0xFF4A9969); 
  static const Color primaryLight = Color(0xFFEAF5EC); 

  Widget _buildEmptyState(bool showFav) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            showFav ? Icons.favorite_border : Icons.search_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            showFav ? 'Belum ada resep favorit' : 'Resep tidak ditemukan',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredRecipes = ref.watch(filteredRecipesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final viewMode = ref.watch(viewModeProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final userName = ref.watch(userNameProvider); 

    return Container(
      color: Colors.white, 
      child: Column(
        children: [
          // ====================== HEADER KUSTOM ======================
          Container(
            color: primaryDark,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 8, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Katalog Resep Dapurku',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      'Selamat datang, ${userName ?? 'Tamu'}!', 
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 28), 
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  tooltip: 'Menu Pengaturan',
                ),
              ],
            ),
          ),

          // ====================== SEARCH BAR ======================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField( 
              // PERBAIKAN: Key dihapus atau diganti menjadi statis agar widget tidak rebuild total saat mengetik
              // initialValue hanya dipasang sekali. Jika ingin reset via tombol 'clear', 
              // disarankan menggunakan TextEditingController, namun cara termudah tanpa merombak banyak kode adalah:
              controller: TextEditingController.fromValue(
                TextEditingValue(
                  text: searchQuery,
                  selection: TextSelection.collapsed(offset: searchQuery.length),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: "Cari resep...",
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, size: 20, color: primaryDark),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20, color: Colors.grey),
                        onPressed: () {
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // ====================== CATEGORY FILTER ======================
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.grey[50], 
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                CategoryChip(
                  label: 'Semua',
                  isSelected: selectedCategory == 'Semua',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = 'Semua';
                  },
                ),
                CategoryChip(
                  label: 'Indonesian',
                  isSelected: selectedCategory == 'Indonesian',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = 'Indonesian';
                  },
                ),
                CategoryChip(
                  label: 'Western',
                  isSelected: selectedCategory == 'Western',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = 'Western';
                  },
                ),
                CategoryChip(
                  label: 'Dessert',
                  isSelected: selectedCategory == 'Dessert',
                  onTap: () {
                    ref.read(selectedCategoryProvider.notifier).state = 'Dessert';
                  },
                ),
              ],
            ),
          ),

          if (showOnlyFavorites)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Resep favorit',
                    style: TextStyle(color: Colors.green, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(showOnlyFavoritesProvider.notifier).state = false;
                    },
                    child: const Text(
                      'Tampilkan Semua',
                      style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          // ====================== MAIN CONTENT ======================
          Expanded(
            child: Stack(
              children: [
                filteredRecipes.isEmpty
                    ? _buildEmptyState(showOnlyFavorites)
                    : viewMode == ViewMode.grid
                        ? GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRecipes.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemBuilder: (context, index) {
                              return RecipeCard(recipe: filteredRecipes[index]);
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredRecipes.length,
                            itemBuilder: (context, index) {
                              return RecipeListItem(
                                recipe: filteredRecipes[index],
                              );
                            },
                          ),
                
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const AddRecipeDialog(),
                      );
                    },
                    backgroundColor: primaryDark,
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}