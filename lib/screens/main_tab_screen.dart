// lib/screens/main_tab_screen.dart 

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/recipe_providers.dart';
import '../widgets/app_drawer.dart'; 
import 'home_screen.dart';
import 'history_screen.dart';
import 'info_screen.dart';

class MainTabScreen extends ConsumerWidget {
  const MainTabScreen({super.key});

  final List<Widget> screens = const [
    RecipeHomePage(),
    HistoryScreen(),
    InfoScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      endDrawer: const AppDrawer(), 
      
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(currentTabIndexProvider.notifier).state = index;
        },
        selectedItemColor: const Color.fromARGB(255, 30, 205, 117), 
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Info',
          ),
        ],
      ),
    );
  }
}