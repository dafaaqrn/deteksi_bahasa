import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text('Pengaturan'),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: AuthService.instance,
          builder: (context, _) {
            final user = AuthService.instance.user;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                _SectionLabel('Akun'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.badge_outlined,
                      title: 'Username',
                      subtitle: user?.username ?? '-',
                      onTap: () => _showEditUsernameSheet(context),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: user?.email ?? '-',
                      onTap: null,
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: user?.hasGoogle == true ? Icons.g_mobiledata : Icons.lock_outline,
                      title: 'Metode Login',
                      subtitle: user?.hasGoogle == true
                          ? (user?.hasPassword == true
                              ? 'Google & Password'
                              : 'Akun Google')
                          : 'Email & Password',
                      onTap: null,
                    ),
                  ],
                ),
                _SectionLabel('Keamanan'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.password_outlined,
                      title: user?.hasPassword == true ? 'Ganti Password' : 'Tambahkan Password',
                      subtitle: user?.hasPassword == true
                          ? 'Ubah password akun'
                          : 'Supaya bisa login tanpa Google juga',
                      onTap: () => _showPasswordSheet(context, hasPassword: user?.hasPassword == true),
                    ),
                  ],
                ),
                _SectionLabel('Zona Berbahaya'),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.delete_forever_outlined,
                      title: 'Hapus Akun',
                      subtitle: 'Akun dan data terkait dihapus permanen',
                      titleColor: AppColors.error,
                      iconColor: AppColors.error,
                      iconBg: AppColors.errorContainer,
                      onTap: () => _confirmDeleteAccount(context),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showEditUsernameSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditUsernameSheet(),
    );
  }

  void _showPasswordSheet(BuildContext context, {required bool hasPassword}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPasswordSheet(hasPassword: hasPassword),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus akun?'),
        content: const Text(
          'Tindakan ini permanen. Akun, foto profil, dan data login kamu akan '
          'dihapus dan tidak bisa dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus Akun'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await AuthService.instance.deleteAccount();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}

class _EditUsernameSheet extends StatefulWidget {
  const _EditUsernameSheet();

  @override
  State<_EditUsernameSheet> createState() => _EditUsernameSheetState();
}

class _EditUsernameSheetState extends State<_EditUsernameSheet> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  String? _errorText;

  static final _usernamePattern = RegExp(r'^[a-z0-9_.]{3,30}$');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: AuthService.instance.user?.username ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    if (v.isEmpty) return 'Username wajib diisi';
    if (!_usernamePattern.hasMatch(v)) {
      return '3-30 karakter, hanya huruf kecil, angka, titik, underscore';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.updateUsername(_controller.text.trim().toLowerCase());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username berhasil diubah')),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: 'Ubah Username',
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      fields: [
        TextFormField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          validator: _validate,
          onFieldSubmitted: (_) => _saving ? null : _save(),
          decoration: InputDecoration(
            labelText: 'Username baru',
            errorText: _errorText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _EditPasswordSheet extends StatefulWidget {
  final bool hasPassword;
  const _EditPasswordSheet({required this.hasPassword});

  @override
  State<_EditPasswordSheet> createState() => _EditPasswordSheetState();
}

class _EditPasswordSheetState extends State<_EditPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;
  String? _errorText;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateCurrent(String? value) {
    if (!widget.hasPassword) return null;
    if ((value ?? '').isEmpty) return 'Password saat ini wajib diisi';
    return null;
  }

  String? _validateNew(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'Minimal 8 karakter';
    if (v.length > 128) return 'Maksimal 128 karakter';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _newController.text) return 'Konfirmasi password tidak cocok';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await AuthService.instance.updatePassword(
        currentPassword: widget.hasPassword ? _currentController.text : null,
        newPassword: _newController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.hasPassword ? 'Password berhasil diubah' : 'Password berhasil ditambahkan'),
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BottomSheetShell(
      title: widget.hasPassword ? 'Ganti Password' : 'Tambahkan Password',
      formKey: _formKey,
      saving: _saving,
      onSave: _save,
      errorText: _errorText,
      fields: [
        if (widget.hasPassword) ...[
          TextFormField(
            controller: _currentController,
            autofocus: true,
            obscureText: true,
            validator: _validateCurrent,
            decoration: InputDecoration(
              labelText: 'Password saat ini',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextFormField(
          controller: _newController,
          autofocus: !widget.hasPassword,
          obscureText: true,
          validator: _validateNew,
          decoration: InputDecoration(
            labelText: 'Password baru',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _confirmController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: _validateConfirm,
          onFieldSubmitted: (_) => _saving ? null : _save(),
          decoration: InputDecoration(
            labelText: 'Konfirmasi password baru',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

/// Bungkus bottom sheet form yang dipakai bersama oleh sheet username & password.
class _BottomSheetShell extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> fields;
  final bool saving;
  final String? errorText;
  final VoidCallback onSave;

  const _BottomSheetShell({
    required this.title,
    required this.formKey,
    required this.fields,
    required this.saving,
    required this.onSave,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ...fields,
              if (errorText != null) ...[
                const SizedBox(height: 8),
                Text(errorText!, style: TextStyle(color: AppColors.error, fontSize: 12.5)),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving ? null : onSave,
                  child: saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
        child: Column(children: children),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Color? iconColor;
  final Color? iconBg;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.iconColor,
    this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBg ?? AppColors.primaryFixed,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: titleColor),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
      trailing: onTap != null ? Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant) : null,
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.3)),
    );
  }
}