import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../notifications/notifications_screen.dart';
import 'tabs/home_tab.dart';
import 'tabs/applications_tab.dart';
import 'tabs/messages_tab.dart';
import 'tabs/profile_tab.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  Timer? _chatPollTimer;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ApplicationsTab(),
    const MessagesTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
      Provider.of<ApplicationProvider>(context, listen: false)
          .fetchStudentApplications()
          .then((_) => _refreshChatBadge());
    });

    // Poll unread chat messages every 10 seconds
    _chatPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) _refreshChatBadge();
    });
  }

  void _refreshChatBadge() {
    final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myId = authProvider.user?.id;
    if (myId == null) return;

    final acceptedAppIds = appProvider.studentApplications
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
              icon: Icon(Icons.search), label: 'Jobs'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), label: 'Applied'),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: chatUnread > 0 && _currentIndex != 2,
              label: Text('$chatUnread'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
