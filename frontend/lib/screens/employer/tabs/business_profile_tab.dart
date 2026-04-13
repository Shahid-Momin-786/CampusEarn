import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/theme.dart';
import '../../auth/login_screen.dart';

class BusinessProfileTab extends StatefulWidget {
  const BusinessProfileTab({super.key});

  @override
  State<BusinessProfileTab> createState() => _BusinessProfileTabState();
}

class _BusinessProfileTabState extends State<BusinessProfileTab> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _webCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile =
          Provider.of<AuthProvider>(context, listen: false).user?.employerProfile;
      _nameCtrl.text = profile?.companyName ?? '';
      _descCtrl.text = profile?.companyDescription ?? '';
      _webCtrl.text = profile?.website ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _webCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final error =
        await Provider.of<AuthProvider>(context, listen: false).updateEmployerProfile({
      'company_name': _nameCtrl.text.trim(),
      'company_description': _descCtrl.text.trim(),
      'website': _webCtrl.text.trim(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error == null ? '✅ Profile saved!' : '❌ $error'),
        backgroundColor: error == null ? AppTheme.success : AppTheme.error,
      ));
    }
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {int maxLines = 1, String? hint, TextInputType? keyboard}) {
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
          keyboardType: keyboard,
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
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondary, Color(0xFF0891B2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withOpacity(0.4),
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
                        color: AppTheme.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('Employer',
                          style: TextStyle(
                              color: AppTheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              Text('Business Profile',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 18)),
              const SizedBox(height: 20),

              _buildField('Company / Business Name', _nameCtrl,
                  hint: 'e.g. Acme Corp'),
              _buildField('Description', _descCtrl,
                  hint: 'What does your business do?', maxLines: 3),
              _buildField('Website', _webCtrl,
                  hint: 'https://yoursite.com',
                  keyboard: TextInputType.url),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondary,
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
                      : const Text('Save Business Profile',
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
