import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import 'auth/login_screen.dart';
import 'student/student_dashboard.dart';
import 'employer/employer_dashboard.dart';
import 'admin/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Add artificial delay for splash logo visible 
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkToken();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final role = authProvider.user?.role.toUpperCase() ?? 'STUDENT';
      Widget dashboard;
      switch (role) {
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
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 100,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'CampusEarn',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hyperlocal Student Jobs',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
