// lib/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../providers/recipe_providers.dart';
import '../screens/login_screen.dart';
import '../screens/info_screen.dart'; 

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  static const Color primaryDark = Color.fromARGB(255, 30, 205, 117);

  void _showChangeNameDialog(BuildContext context, WidgetRef ref, String currentName) {
    final TextEditingController controller = TextEditingController(text: currentName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Pengguna'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Nama Baru'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newName = controller.text.trim();
                
                final userNotifier = ref.read(userNameProvider.notifier);
                await userNotifier.setUserName(newName);
                
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama berhasil diubah!')),
                  );
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(userNameProvider.notifier).logout();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final showOnlyFavorites = ref.watch(showOnlyFavoritesProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Drawer(
      child: Column(
        children: [
          
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20, 
              bottom: 20, 
              left: 16
            ),
            width: double.infinity,
            color: primaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 50),
                const SizedBox(height: 8),
                Text(
                  userName ?? 'Tamu',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // List Menu
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_note, color: primaryDark),
                  title: const Text('Ubah Nama Pengguna'),
                  onTap: () {
                    _showChangeNameDialog(context, ref, userName ?? 'Tamu');
                  },
                ),
                const Divider(),
                
                // Fitur Tampilkan Favorit
                SwitchListTile(
                  title: const Text('Tampilkan Favorit Saja'),
                  secondary: Icon(
                    showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                    color: showOnlyFavorites ? Colors.red : primaryDark,
                  ),
                  value: showOnlyFavorites,
                  onChanged: (newValue) {
                    ref.read(showOnlyFavoritesProvider.notifier).state = newValue;
                  },
                ),
                
                // Fitur Ganti Tampilan Grid/List
                ListTile(
                  leading: Icon(
                    viewMode == ViewMode.grid ? Icons.grid_view : Icons.list,
                    color: primaryDark,
                  ),
                  title: Text('Ganti Tampilan (${viewMode == ViewMode.grid ? 'Grid' : 'List'})'),
                  onTap: () {
                    final nextMode = viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                    ref.read(viewModeProvider.notifier).toggleViewMode(nextMode);
                  },
                ),
                
                const Divider(),

                // MENU BARU: Informasi Aplikasi
                ListTile(
                  leading: const Icon(Icons.info_outline, color: primaryDark),
                  title: const Text('Informasi Pengembang'),
                  onTap: () {
                    Navigator.of(context).pop(); 
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const InfoScreen()),
                    );
                  },
                ),

              ],
            ),
          ),
        ],
      ),
    );
  } 
}