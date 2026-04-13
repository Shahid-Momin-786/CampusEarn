import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.surface,
      ),
      body: provider.isLoading && notifications.isEmpty 
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : notifications.isEmpty 
              ? const Center(
                  child: Text("No notifications yet.", style: TextStyle(color: AppTheme.textSecondary)),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return ListTile(
                      tileColor: notif.isRead ? null : AppTheme.primary.withOpacity(0.1),
                      leading: Icon(
                        notif.isRead ? Icons.notifications_none : Icons.notifications_active,
                        color: notif.isRead ? Colors.grey : AppTheme.primary,
                      ),
                      title: Text(notif.message, style: const TextStyle(color: AppTheme.textPrimary)),
                      subtitle: Text(notif.createdAt.substring(0, 10), style: const TextStyle(color: AppTheme.textSecondary)),
                      onTap: notif.isRead ? null : () => provider.markAsRead(notif.id),
                    );
                  },
                ),
    );
  }
}
