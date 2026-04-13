import 'package:flutter/material.dart';
import 'tabs/overview_tab.dart';
import 'tabs/verification_tab.dart';
import 'tabs/users_manage_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/admin_profile_tab.dart';
import '../../core/theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const OverviewTab(),
    const VerificationTab(),
    const UsersManageTab(),
    const ReportsTab(),
    const AdminProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusEarn Admin'),
        backgroundColor: AppTheme.surface,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.verified_user_outlined), label: 'Verify'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Users'),
          BottomNavigationBarItem(
              icon: Icon(Icons.flag_outlined), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
