import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ViewMode { grid, list }

class UserNotifier extends StateNotifier<String?> {
  UserNotifier() : super(null) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('user_name');
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
    state = name; // Update state setelah berhasil disimpan
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_name');
    state = null;
  }
}

final userNameProvider = StateNotifierProvider<UserNotifier, String?>((ref) => UserNotifier());

// --- View Mode dengan Auto Save ---
class ViewModeNotifier extends StateNotifier<ViewMode> {
  ViewModeNotifier() : super(ViewMode.grid) {
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('view_mode');
    if (mode != null) {
      state = mode == 'list' ? ViewMode.list : ViewMode.grid;
    }
  }

  Future<void> toggleViewMode(ViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('view_mode', mode == ViewMode.list ? 'list' : 'grid');
    state = mode;
  }
}

final viewModeProvider = StateNotifierProvider<ViewModeNotifier, ViewMode>((ref) {
  return ViewModeNotifier();
});

// --- Favorites dengan Auto Save ---
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavs = prefs.getStringList('favorites_key');
    if (savedFavs != null) {
      state = savedFavs.toSet();
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final newSet = Set<String>.from(state);
    
    if (newSet.contains(recipeId)) {
      newSet.remove(recipeId);
    } else {
      newSet.add(recipeId);
    }
    
    await prefs.setStringList('favorites_key', newSet.toList());
    state = newSet;
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier();
});