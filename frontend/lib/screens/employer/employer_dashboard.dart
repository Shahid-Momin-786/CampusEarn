import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../notifications/notifications_screen.dart';
import 'tabs/my_jobs_tab.dart';
import 'tabs/applicants_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/business_profile_tab.dart';

class EmployerDashboard extends StatefulWidget {
  const EmployerDashboard({super.key});

  @override
  State<EmployerDashboard> createState() => _EmployerDashboardState();
}

class _EmployerDashboardState extends State<EmployerDashboard> {
  int _currentIndex = 0;
  Timer? _chatPollTimer;

  final List<Widget> _tabs = [
    const MyJobsTab(),
    const ApplicantsTab(),
    const EmployerMessagesTab(),
    const BusinessProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      Provider.of<ApplicationProvider>(context, listen: false)
          .fetchEmployerApplications()
          .then((_) => _refreshChatBadge());
    });

    _chatPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _refreshChatBadge();
    });
  }

  void _refreshChatBadge() {
    final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.user?.id;
    if (myId == null) return;

    final acceptedAppIds = appProvider.employerApplications
        .where((a) => a.status == 'ACCEPTED')
        .map((a) => a.id)
        .toList();

    Provider.of<ChatProvider>(context, listen: false)
        .refreshUnreadCount(acceptedAppIds, myId);
  }

  @override
  void dispose() {
    _chatPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatUnread = Provider.of<ChatProvider>(context).totalUnread;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusEarn'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Badge(
                  isLabelVisible: provider.unreadCount > 0,
                  label: Text('${provider.unreadCount}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
              );
            },
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.business_center_outlined), label: 'My Jobs'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Applicants'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: chatUnread > 0 && _currentIndex != 2,
              label: Text('$chatUnread'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            label: 'Messages',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
