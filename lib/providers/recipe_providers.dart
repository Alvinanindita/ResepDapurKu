import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../data/recipe_data.dart';
import 'user_provider.dart';

// Notifier untuk mengelola Resep Utama
class RecipeNotifier extends StateNotifier<List<Recipe>> {
  RecipeNotifier() : super([]) {
    _initData();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('recipes_key');
    if (savedData != null) {
      final List<dynamic> decoded = json.decode(savedData);
      state = decoded.map((e) => Recipe.fromMap(e)).toList();
    } else {
      state = initialRecipes;
      _saveToPrefs();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(state.map((e) => e.toMap()).toList());
    await prefs.setString('recipes_key', encoded);
  }

  void updateRecipes(List<Recipe> newList) {
    state = newList;
    _saveToPrefs();
  }
}

// ✨ NOTIFIER BARU UNTUK HISTORY (SIMPAN PERMANEN)
class HistoryNotifier extends StateNotifier<List<Recipe>> {
  HistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedHistory = prefs.getString('history_key');
    if (savedHistory != null) {
      final List<dynamic> decoded = json.decode(savedHistory);
      state = decoded.map((e) => Recipe.fromMap(e)).toList();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(state.map((e) => e.toMap()).toList());
    await prefs.setString('history_key', encoded);
  }

  void addToHistory(Recipe recipe) {
    // Tambahkan ke posisi teratas, hapus jika ID sudah ada (agar tidak duplikat), ambil 10 terbaru
    final newList = [
      recipe,
      ...state.where((r) => r.id != recipe.id),
    ].take(10).toList();
    
    state = newList;
    _saveHistory();
  }

  void clearHistory() {
    state = [];
    _saveHistory();
  }
}

// Provider Utama
final recipesProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((ref) => RecipeNotifier());

// ✨ PROVIDER HISTORY (DIRUBAH JADI STATENOTIFIER)
final historyProvider = StateNotifierProvider<HistoryNotifier, List<Recipe>>((ref) => HistoryNotifier());

final selectedCategoryProvider = StateProvider<String>((ref) => 'Semua');
final searchQueryProvider = StateProvider<String>((ref) => '');
final showOnlyFavoritesProvider = StateProvider<bool>((ref) => false);
final currentTabIndexProvider = StateProvider<int>((ref) => 0);

// Provider untuk Filter & Pencarian Sub-Kategori
final filteredRecipesProvider = Provider<List<Recipe>>((ref) {
  final recipes = ref.watch(recipesProvider);
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final favorites = ref.watch(favoritesProvider);
  final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);

  var filteredRecipes = recipes;
  if (category != 'Semua') {
    filteredRecipes = filteredRecipes.where((r) => r.category.startsWith(category)).toList();
  }
  if (searchQuery.isNotEmpty) {
    filteredRecipes = filteredRecipes.where((r) => 
      r.name.toLowerCase().contains(searchQuery) ||
      r.description.toLowerCase().contains(searchQuery) ||
      r.category.toLowerCase().contains(searchQuery)
    ).toList();
  }
  if (showOnlyFavorites) {
    filteredRecipes = filteredRecipes.where((r) => favorites.contains(r.id)).toList();
  }
  return filteredRecipes;
});