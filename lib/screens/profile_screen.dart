import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final user = AuthService.instance.user;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildMenuSection(context),
                const SizedBox(height: 16),
                _buildLogoutButton(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AuthUser? user) {
    final username = user?.username ?? 'Pengguna';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryFixed,
            border: Border.all(color: AppColors.surfaceContainerLowest, width: 4),
            boxShadow: [
              BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.08), blurRadius: 16),
            ],
          ),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          username,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          user?.email ?? '',
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
      // Material transparan: ListTile butuh ini supaya efek sentuh/ripple
      // kelihatan, tapi warna Container di atas tetap yang dipakai.
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
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
                    child: Divider(
                      height: 1,
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.onSurface.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.logout, color: AppColors.error, size: 20),
          ),
          title: Text(
            'Keluar',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.error,
            ),
          ),
          onTap: () => _confirmLogout(context),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu perlu login lagi untuk memakai aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // AuthGate otomatis kembali ke layar login setelah ini.
      await AuthService.instance.logout();
    }
  }
}