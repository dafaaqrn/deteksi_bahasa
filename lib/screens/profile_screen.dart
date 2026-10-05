import 'package:flutter/material.dart';
import '../app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildMenuSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryFixed,
            border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
            boxShadow: [
              BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.08), blurRadius: 16),
            ],
          ),
          child: Icon(Icons.person, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text(
          'Dafa',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Belajar BISINDO sejak Oktober 2026',
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final stats = [
      (Icons.menu_book, 'Kata Dipelajari', '24'),
      (Icons.center_focus_strong, 'Deteksi Hari Ini', '12'),
      (Icons.local_fire_department, 'Streak', '5 hari'),
    ];

    return Row(
      children: stats.map((stat) {
        final isLast = stat == stats.last;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.05), blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Icon(stat.$1, color: AppColors.primary, size: 22),
                const SizedBox(height: 6),
                Text(
                  stat.$3,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final menuItems = [
      (Icons.settings, 'Pengaturan', AppColors.primary, AppColors.primaryFixed),
      (Icons.help_outline, 'Bantuan', AppColors.secondary, AppColors.secondaryFixed),
      (Icons.info_outline, 'Tentang Aplikasi', AppColors.tertiary, AppColors.tertiaryFixed),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: menuItems.map((item) {
          final isLast = item == menuItems.last;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.$4,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$1, color: item.$3, size: 20),
                ),
                title: Text(
                  item.$2,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                trailing: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.$2} - segera hadir')),
                  );
                },
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}