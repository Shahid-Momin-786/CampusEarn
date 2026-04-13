import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/theme.dart';

class ApplicationsTab extends StatefulWidget {
  const ApplicationsTab({super.key});

  @override
  State<ApplicationsTab> createState() => _ApplicationsTabState();
}

class _ApplicationsTabState extends State<ApplicationsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ApplicationProvider>(context, listen: false).fetchStudentApplications();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACCEPTED': return Colors.green;
      case 'REJECTED': return Colors.red;
      case 'COMPLETED': return Colors.blue;
      case 'APPLIED':
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<ApplicationProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => appProvider.fetchStudentApplications(),
        child: appProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : appProvider.error != null
                ? Center(
                    child: Text('Error: ${appProvider.error}',
                        style: const TextStyle(color: Colors.red)))
                : appProvider.studentApplications.isEmpty
                    ? const Center(child: Text('You have not applied to any jobs yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: appProvider.studentApplications.length,
                        itemBuilder: (context, index) {
                          final application = appProvider.studentApplications[index];
                          final job = application.jobDetails;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(job?.title ?? 'Unknown Job', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${job?.employerCompany ?? ''}\nApplied on: ${application.createdAt.split('T')[0]}'),
                              isThreeLine: true,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(application.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getStatusColor(application.status)),
                                ),
                                child: Text(
                                  application.status,
                                  style: TextStyle(
                                    color: _getStatusColor(application.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
