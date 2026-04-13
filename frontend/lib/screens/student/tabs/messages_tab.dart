import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/theme.dart';
import '../../chat/chat_detail_screen.dart';

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchStudentApplications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);
    final apps = appProvider.studentApplications.where((a) => a.status == 'ACCEPTED').toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Messages',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  if (apps.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${apps.length} active',
                        style: const TextStyle(
                            color: AppTheme.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: appProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : apps.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  size: 64,
                                  color: AppTheme.textSecondary.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text(
                                'No active chats yet.',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Get your applications accepted\nto start chatting with employers.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: apps.length,
                          itemBuilder: (context, index) {
                            final app = apps[index];
                            final title = app.jobDetails?.employerCompany ?? 'Employer';
                            final jobTitle = app.jobDetails?.title ?? 'Job';

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(
                                    appId: app.id,
                                    title: title,
                                    subtitle: jobTitle,
                                  ),
                                ),
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.success.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor:
                                          AppTheme.primary.withOpacity(0.12),
                                      child: Text(
                                        title.isNotEmpty ? title[0].toUpperCase() : 'E',
                                        style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            jobTitle,
                                            style: const TextStyle(
                                                color: AppTheme.textSecondary,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Icon(Icons.chevron_right,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.success.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Active',
                                            style: TextStyle(
                                                color: AppTheme.success,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
