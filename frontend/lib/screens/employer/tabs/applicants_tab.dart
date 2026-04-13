import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/theme.dart';

class ApplicantsTab extends StatefulWidget {
  const ApplicantsTab({super.key});

  @override
  State<ApplicantsTab> createState() => _ApplicantsTabState();
}

class _ApplicantsTabState extends State<ApplicantsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchEmployerApplications();
    });
  }

  Future<void> _handleDecision(int appId, String status) async {
    try {
      await Provider.of<ApplicationProvider>(context, listen: false)
          .updateApplicationStatus(appId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(status == 'ACCEPTED'
              ? '✅ Application accepted! Chat is now enabled.'
              : '❌ Application rejected.'),
          backgroundColor:
              status == 'ACCEPTED' ? AppTheme.success : AppTheme.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppTheme.error,
        ));
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ACCEPTED':
        return AppTheme.success;
      case 'REJECTED':
        return AppTheme.error;
      default:
        return const Color(0xFFF59E0B); // amber
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ACCEPTED':
        return Icons.check_circle_outline;
      case 'REJECTED':
        return Icons.cancel_outlined;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

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
                    'Applicants',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 28),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${appProvider.employerApplications.length} total',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => appProvider.fetchEmployerApplications(),
                color: AppTheme.primary,
                child: appProvider.isLoading
                    ? const Center(
                        child:
                            CircularProgressIndicator(color: AppTheme.primary))
                    : appProvider.error != null
                        ? Center(
                            child: Text('Error: ${appProvider.error}',
                                style: const TextStyle(color: AppTheme.error)))
                        : appProvider.employerApplications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline,
                                        size: 64,
                                        color: AppTheme.textSecondary
                                            .withOpacity(0.3)),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No applicants yet.\nPost a job to get started!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                itemCount:
                                    appProvider.employerApplications.length,
                                itemBuilder: (context, index) {
                                  final app =
                                      appProvider.employerApplications[index];
                                  final jobTitle = app.jobDetails?.title ?? 'Job';
                                  final statusColor = _statusColor(app.status);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: app.status == 'APPLIED'
                                            ? Colors.transparent
                                            : statusColor.withOpacity(0.3),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Header row
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 22,
                                                backgroundColor:
                                                    AppTheme.primary.withOpacity(0.12),
                                                child: Text(
                                                  app.studentName.isNotEmpty
                                                      ? app.studentName[0]
                                                          .toUpperCase()
                                                      : 'S',
                                                  style: const TextStyle(
                                                    color: AppTheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      app.studentName,
                                                      style: const TextStyle(
                                                        color: AppTheme.textPrimary,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      'For: $jobTitle',
                                                      style: const TextStyle(
                                                          color: AppTheme
                                                              .textSecondary,
                                                          fontSize: 13),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Status badge
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        _statusIcon(app.status),
                                                        size: 13,
                                                        color: statusColor),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      app.status,
                                                      style: TextStyle(
                                                          color: statusColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Message if any
                                          if (app.message != null &&
                                              app.message!.isNotEmpty) ...[
                                            const SizedBox(height: 14),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: AppTheme.background,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                      Icons.format_quote,
                                                      size: 16,
                                                      color:
                                                          AppTheme.textSecondary),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      app.message!,
                                                      style: const TextStyle(
                                                        color:
                                                            AppTheme.textSecondary,
                                                        fontSize: 13,
                                                        fontStyle:
                                                            FontStyle.italic,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],

                                          // Action buttons — only for APPLIED
                                          if (app.status == 'APPLIED') ...[
                                            const SizedBox(height: 16),
                                            const Divider(
                                                color: Colors.white12,
                                                height: 1),
                                            const SizedBox(height: 14),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _handleDecision(
                                                            app.id, 'REJECTED'),
                                                    icon: const Icon(
                                                        Icons.close_rounded,
                                                        size: 16),
                                                    label:
                                                        const Text('Reject'),
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor:
                                                          AppTheme.error,
                                                      side: const BorderSide(
                                                          color: AppTheme.error,
                                                          width: 1.5),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              vertical: 12),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _handleDecision(
                                                            app.id, 'ACCEPTED'),
                                                    icon: const Icon(
                                                        Icons.check_rounded,
                                                        size: 16),
                                                    label:
                                                        const Text('Accept'),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          AppTheme.success,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              vertical: 12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
