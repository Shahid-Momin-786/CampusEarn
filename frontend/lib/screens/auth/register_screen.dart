import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme.dart';
import '../student/student_dashboard.dart';
import '../employer/employer_dashboard.dart';
import '../admin/admin_dashboard.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _role = 'STUDENT';
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final email = _emailController.text.trim();
    final pw = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (email.isEmpty || pw.isEmpty || firstName.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final service = AuthService();
      await service.register({
        'email': email,
        'password': pw,
        'first_name': firstName,
        'last_name': lastName,
        'role': _role,
      });
      
      // Auto-login after register
      await authProvider.login(email, pw);
      
      if (!mounted) return;
      if (authProvider.isAuthenticated) {
        final userRole = authProvider.user?.role.toUpperCase() ?? 'STUDENT';
        Widget dashboard;
        switch (userRole) {
          case 'EMPLOYER':
            dashboard = const EmployerDashboard();
            break;
          case 'ADMIN':
            dashboard = const AdminDashboard();
            break;
          case 'STUDENT':
          default:
            dashboard = const StudentDashboard();
            break;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => dashboard),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Join CampusEarn to connect on campus.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: 'First Name'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: const InputDecoration(labelText: 'Last Name'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _role,
                dropdownColor: AppTheme.surface,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'I am a...',
                ),
                items: const [
                  DropdownMenuItem(value: 'STUDENT', child: Text('Student seeking jobs')),
                  DropdownMenuItem(value: 'EMPLOYER', child: Text('Employer posting jobs')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
