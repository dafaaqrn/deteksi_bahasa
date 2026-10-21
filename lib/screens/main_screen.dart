import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dictionary_screen.dart';
import 'riwayat_screen.dart';
import 'profile_screen.dart';
import '../app_colors.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const DictionaryScreen(),
      const RiwayatScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      // Dibungkus ListenableBuilder supaya ikon Profil otomatis update
      // begitu user ganti foto (AuthService.notifyListeners()).
      bottomNavigationBar: ListenableBuilder(
        listenable: AuthService.instance,
        builder: (context, _) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.surfaceContainerLowest,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.onSurfaceVariant,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            onTap: _goToTab,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Kamus',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: _buildProfileIcon(selected: false),
                activeIcon: _buildProfileIcon(selected: true),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileIcon({required bool selected}) {
    final photoUrl = AuthService.instance.user?.photoUrl;
    final defaultIcon = Icon(selected ? Icons.person : Icons.person_outline);

    if (photoUrl == null) return defaultIcon;

    return ClipOval(
      child: Image.network(
        '${ApiConfig.baseUrl}$photoUrl',
        width: 24,
        height: 24,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultIcon,
      ),
    );
  }
}