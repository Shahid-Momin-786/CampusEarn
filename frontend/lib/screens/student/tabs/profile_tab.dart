import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/theme.dart';
import '../../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _univCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _isAvailable = true;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = Provider.of<AuthProvider>(context, listen: false).user?.studentProfile;
      _univCtrl.text = profile?.university ?? '';
      _majorCtrl.text = profile?.major ?? '';
      _skillsCtrl.text = profile?.skills ?? '';
      _bioCtrl.text = profile?.bio ?? '';
      _isAvailable = profile?.availability ?? true;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _univCtrl.dispose();
    _majorCtrl.dispose();
    _skillsCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final error = await Provider.of<AuthProvider>(context, listen: false).updateStudentProfile({
      'university': _univCtrl.text.trim(),
      'major': _majorCtrl.text.trim(),
      'skills': _skillsCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'availability': _isAvailable,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error == null ? '✅ Profile saved!' : '❌ $error'),
        backgroundColor: error == null ? AppTheme.success : AppTheme.error,
      ));
    }
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {int maxLines = 1, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar & name header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, AppTheme.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          (user?.firstName.isNotEmpty == true)
                              ? user!.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(user?.email ?? '',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Student',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              // Section header
              Text('Edit Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 20),

              _buildField('University', _univCtrl, hint: 'e.g. MIT'),
              _buildField('Major / Field of Study', _majorCtrl,
                  hint: 'e.g. Computer Science'),
              _buildField('Skills', _skillsCtrl,
                  hint: 'e.g. Python, Flutter, Design',
                  maxLines: 2),
              _buildField('Bio', _bioCtrl,
                  hint: 'Tell employers about yourself...', maxLines: 3),

              // Availability toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available for Work',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                            _isAvailable
                                ? 'Visible to employers'
                                : 'Hidden from employers',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (v) => setState(() => _isAvailable = v),
                      activeColor: AppTheme.success,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Profile',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 16),
              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text('Logout',
                      style: TextStyle(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    await Provider.of<AuthProvider>(context, listen: false)
                        .logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
