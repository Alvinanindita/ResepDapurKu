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
  final _subCategoryController = TextEditingController(); 

  String _selectedCategory = 'Indonesian';
  String _selectedDifficulty = 'Mudah';
  String _selectedEmoji = '🍳';

  final List<String> _categories = ['Indonesian', 'Western', 'Dessert', 'Lainnya'];
  final List<String> _difficulties = ['Mudah', 'Sedang', 'Sulit'];
  final List<String> _emojis = [
    '🍳', '🍝', '🍖', '🥞', '🍲', '🥗', '🍰', '🥙',
    '🍔', '🍕', '🍜', '🍱', '🥘', '🍛', '🍣', '🥟',
    '🌮', '🌯', '🥪', '🍩', '🧁', '🍪', '🥧', '🍦',
    '🍗', '🍤', '🦐', '🦞', '🍢', '🍡', '🥮',
  ];

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117);
  static const Color primaryMain = Color(0xFF4A9969);

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
      
      final categoryParts = widget.recipe!.category.split(' - ');
      _selectedCategory = categoryParts[0];
      
      if (categoryParts.length > 1) {
        _subCategoryController.text = categoryParts[1];
      }

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
    _subCategoryController.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipes = ref.read(recipesProvider);
      final notifier = ref.read(recipesProvider.notifier);
      final historyNotifier = ref.read(historyProvider.notifier);

      final ingredientsList = _ingredientsController.text
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final rawCookTime = _cookTimeController.text.trim();
      final cookTime = rawCookTime.isNotEmpty ? '$rawCookTime menit' : '0 menit';
      final customSubCategory = _subCategoryController.text.trim().isEmpty ? 'Umum' : _subCategoryController.text.trim();
      final fullCategory = '$_selectedCategory - $customSubCategory';

      if (widget.recipe != null) {
        final updatedRecipe = widget.recipe!.copyWith(
          name: _nameController.text,
          category: fullCategory,
          image: _selectedEmoji,
          cookTime: cookTime,
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        final updatedRecipes = recipes.map((r) => r.id == updatedRecipe.id ? updatedRecipe : r).toList();
        notifier.updateRecipes(updatedRecipes);
        historyNotifier.addToHistory(updatedRecipe);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep diperbarui & riwayat disimpan!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      } else {
        final newRecipe = Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          category: fullCategory,
          image: _selectedEmoji,
          cookTime: cookTime,
          difficulty: _selectedDifficulty,
          description: _descriptionController.text,
          ingredients: ingredientsList,
        );

        notifier.updateRecipes([...recipes, newRecipe]);

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resep baru berhasil disimpan!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: primaryMain),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primaryDark, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.recipe != null;

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header yang lebih cantik
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: Icon(isEditMode ? Icons.edit_rounded : Icons.add_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    isEditMode ? 'Edit Resep' : 'Resep Baru',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    const SizedBox(height: 16),
                    const _SectionTitle(title: 'Ikon Masakan'),
                    const SizedBox(height: 12),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12),
                        scrollDirection: Axis.horizontal,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1, mainAxisSpacing: 12,
                        ),
                        itemCount: _emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = _emojis[index];
                          final isSelected = emoji == _selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedEmoji = emoji),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))] : [],
                                border: Border.all(color: isSelected ? primaryDark : Colors.transparent, width: 2),
                              ),
                              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Informasi Dasar'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: _buildInputDecoration('Nama Resep', Icons.restaurant_menu_rounded),
                      validator: (value) => (value == null || value.isEmpty) ? 'Nama resep tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildChipSelector(
                      label: 'Kategori Utama', 
                      options: _categories, 
                      selectedValue: _selectedCategory, 
                      onSelected: (value) => setState(() => _selectedCategory = value)
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subCategoryController,
                      decoration: _buildInputDecoration('Sub-kategori (Contoh: Padang)', Icons. category_rounded),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(title: 'Detail Memasak'),
                    const SizedBox(height: 12),
                    _buildChipSelector(
                      label: 'Tingkat Kesulitan', 
                      options: _difficulties, 
                      selectedValue: _selectedDifficulty, 
                      onSelected: (value) => setState(() => _selectedDifficulty = value)
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _cookTimeController,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Waktu Memasak (menit)', Icons.timer_rounded),
                      validator: (value) => (value == null || value.isEmpty) ? 'Waktu wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 2,
                      decoration: _buildInputDecoration('Deskripsi', Icons.notes_rounded),
                      validator: (value) => (value == null || value.isEmpty) ? 'Deskripsi wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ingredientsController,
                      maxLines: 3,
                      decoration: _buildInputDecoration('Bahan-bahan (pisahkan koma)', Icons.receipt_long_rounded),
                      validator: (value) => (value == null || value.isEmpty) ? 'Bahan wajib diisi' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveRecipe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditMode ? 'Simpan Perubahan' : 'Terbitkan Resep',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
    required String selectedValue,
    required ValueSetter<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[600])),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: options.map((item) {
            final isSelected = item == selectedValue;
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: primaryDark.withOpacity(0.2),
              onSelected: (selected) { if (selected) onSelected(item); },
              backgroundColor: Colors.grey[100],
              showCheckmark: false,
              labelStyle: TextStyle(
                color: isSelected ? primaryMain : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: isSelected ? primaryDark : Colors.transparent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.5),
    );
  }
}