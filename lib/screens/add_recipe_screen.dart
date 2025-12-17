// lib/screens/add_recipe_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../providers/recipe_providers.dart';

class AddRecipeDialog extends ConsumerStatefulWidget {
  final Recipe? recipe;

  const AddRecipeDialog({super.key, this.recipe});

  @override
  ConsumerState<AddRecipeDialog> createState() => _AddRecipeDialogState();
}

class _AddRecipeDialogState extends ConsumerState<AddRecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  
  // Hapus _selectedSubCategory, ganti dengan controller untuk input teks kustom
  final _subCategoryController = TextEditingController(); // ✨ CONTROLLER BARU

  String _selectedCategory = 'Indonesian';
  String _selectedDifficulty = 'Mudah';
  String _selectedEmoji = '🍳';

  final List<String> _categories = ['Indonesian', 'Western', 'Dessert', 'Lainnya']; // ✨ Tambah 'Lainnya' jika kategori utama ingin lebih fleksibel
  final List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];

  // Hapus _subCategoriesMap karena kita menggunakan input teks kustom.

  // Tambahan ikon makanan baru!
  final List<String> _emojis = [
    '🍳', '🍝', '🍖', '🥞', '🍲', '🥗', '🍰', '🥙',
    '🍔', '🍕', '🍜', '🍱', '🥘', '🍛', '🍣', '🥟',
    '🌮', '🌯', '🥪', '🍩', '🧁', '🍪', '🥧', '🍦',
    '🥓', '🍗', '🍤', '🦐', '🦞', '🍢', '🍡', '🥮',
  ];

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117); // #1ECD75 (Aksen Cerah/Fresh)
  static const Color primaryMain = Color(0xFF4A9969); // Hijau Hutan/Dasar

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;

      final cookTimeParts = widget.recipe!.cookTime.split(' ');
      _cookTimeController.text = cookTimeParts.isNotEmpty && cookTimeParts.first.isNotEmpty
          ? cookTimeParts.first
          : '';

      _descriptionController.text = widget.recipe!.description;
      _ingredientsController.text = widget.recipe!.ingredients.join(', ');
      
      // ✨ Logika pemisahan Category dan Sub-category saat Edit Mode
      // Asumsikan format Category adalah: "Kategori Utama - Sub-kategori"
      final categoryParts = widget.recipe!.category.split(' - ');
      _selectedCategory = categoryParts[0];
      
      // Isi controller sub-category dari data yang tersimpan
      if (categoryParts.length > 1) {
        _subCategoryController.text = categoryParts[1];
      }
      // Jika hanya ada Kategori Utama (misalnya dari data lama), controller akan kosong.

      _selectedDifficulty = widget.recipe!.difficulty;
      _selectedEmoji = widget.recipe!.image;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _descriptionController.dispose();
    _ingredientsController.dispose();
    _subCategoryController.dispose(); // ✨ Jangan lupa dispose controller baru
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipes = ref.read(recipesProvider);

      final ingredientsList = _ingredientsController.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // Logika untuk Waktu Memasak
      final rawCookTime = _cookTimeController.text.trim();
      final cookTime = rawCookTime.isNotEmpty
          ? '$rawCookTime menit'
          : '0 menit';

      // ✨ Ambil Sub-kategori dari input teks
      final customSubCategory = _subCategoryController.text.trim().isEmpty 
          ? 'Umum' // Beri nilai default jika kosong
          : _subCategoryController.text.trim();

      // Gabungkan Kategori Utama dan Sub-kategori Kustom
      final fullCategory = '$_selectedCategory - $customSubCategory';

      if (widget.recipe != null) {
        // ===================================
        // ✨ LOGIKA EDIT MODE DENGAN HISTORY
        // ===================================
        final updatedRecipe = widget.recipe!.copyWith(
          name: _nameController.text,
          // ✨ Simpan Kategori lengkap (utama + sub-kustom)
          category: fullCategory,
          image: _selectedEmoji,
          cookTime: cookTime,
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        final updatedRecipes = recipes.map((r) {
          return r.id == updatedRecipe.id ? updatedRecipe : r;
        }).toList();

        // 1. Update daftar resep utama
        ref.read(recipesProvider.notifier).state = updatedRecipes;

        // 2. Update History Provider
        final history = ref.read(historyProvider);
        
        final newHistory = [
          updatedRecipe,
          ...history.where((r) => r.id != updatedRecipe.id),
        ];

        final limitedHistory = newHistory.length > 10 ? newHistory.sublist(0, 10) : newHistory;

        ref.read(historyProvider.notifier).state = limitedHistory;

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Resep berhasil diperbarui!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // ===================================
        // LOGIKA ADD MODE (TAMBAH RESEP BARU)
        // ===================================
        
        // Asumsi Recipe id dihitung berdasarkan panjang list.
        final newId = (recipes.length + 1).toString();

        final newRecipe = Recipe(
          id: newId,
          name: _nameController.text,
          // ✨ Simpan Kategori lengkap (utama + sub-kustom)
          category: fullCategory,
          image: _selectedEmoji,
          cookTime: cookTime,
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        ref.read(recipesProvider.notifier).state = [...recipes, newRecipe];

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Resep berhasil ditambahkan!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // --- Widget Kustom untuk Segmented Chip Button ---
  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String selectedValue,
    required ValueSetter<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: options.map((item) {
            final isSelected = item == selectedValue;
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: primaryMain.withOpacity(0.1),
              onSelected: (selected) {
                if (selected) onSelected(item);
              },
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? primaryDark : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? primaryDark : Colors.grey.shade300,
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ✨ Widget baru untuk Input Teks Sub-kategori
  Widget _buildSubCategoryInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sub-kategori Kustom ($_selectedCategory)',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _subCategoryController,
          decoration: InputDecoration(
            labelText: 'Contoh: Padang, Italia, Puding Buah',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.category_outlined),
            isDense: true,
          ),
          // Tidak perlu validator wajib, karena kita akan memberi nilai default jika kosong
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.recipe != null;

    // Sub-kategori yang dipilih dari TextField
    // final currentSubCategory = _subCategoryController.text; // Tidak perlu di sini

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 750,
        ),
        child: Column(
          children: [
            // Header (Tidak Berubah)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEditMode ? Icons.edit : Icons.add_circle,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditMode ? 'Edit Resep' : 'Tambah Resep',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Emoji Selector (Tidak Berubah)
                    const Text(
                      'Pilih Icon Resep',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        scrollDirection: Axis.horizontal,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedEmoji = emoji;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryMain.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryDark
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Recipe Name (Tidak Berubah)
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Resep',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.restaurant_menu),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama resep tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Kategori Utama (Chip Selector)
                    _buildChipSelector(
                      label: 'Kategori Utama',
                      options: _categories,
                      selectedValue: _selectedCategory,
                      onSelected: (value) {
                        setState(() {
                          _selectedCategory = value;
                          // Opsional: Hapus input sub-kategori kustom saat kategori utama berubah
                          // _subCategoryController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // ✨ INPUT TEKS SUB-KATEGORI KUSTOM
                    _buildSubCategoryInput(),
                    const SizedBox(height: 16),
                    
                    // Tingkat Kesulitan (Tidak Berubah)
                    _buildChipSelector(
                      label: 'Tingkat Kesulitan',
                      options: _difficulties,
                      selectedValue: _selectedDifficulty,
                      onSelected: (value) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cook Time (Tidak Berubah)
                    TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Waktu Memasak (dalam menit, contoh: 30)',
                        suffixText: 'menit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.access_time),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Waktu memasak tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid untuk waktu memasak';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description (Tidak Berubah)
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                        isDense: true,
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Ingredients (Tidak Berubah)
                    TextFormField(
                      controller: _ingredientsController,
                      decoration: InputDecoration(
                        labelText: 'Bahan-bahan',
                        hintText: 'Pisahkan dengan koma atau enter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.list_alt),
                        isDense: true,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bahan-bahan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Save Button (Tidak Berubah)
                    ElevatedButton(
                      onPressed: _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        isEditMode ? 'Perbarui Resep' : 'Simpan Resep',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}