import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/job_provider.dart';
import '../../../../core/theme.dart';
import '../create_job_screen.dart';

class MyJobsTab extends StatefulWidget {
  const MyJobsTab({super.key});

  @override
  State<MyJobsTab> createState() => _MyJobsTabState();
}

class _MyJobsTabState extends State<MyJobsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false).fetchEmployerJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateJobScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Post Job'),
      ),
      body: RefreshIndicator(
        onRefresh: () => jobProvider.fetchEmployerJobs(),
        child: jobProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : jobProvider.error != null
                ? Center(
                    child: Text('Error: ${jobProvider.error}',
                        style: const TextStyle(color: Colors.red)))
                : jobProvider.employerJobs.isEmpty
                    ? const Center(child: Text('You have not posted any jobs yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: jobProvider.employerJobs.length,
                        itemBuilder: (context, index) {
                          final job = jobProvider.employerJobs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('\$${job.hourlyRate}/hr • Active: ${job.isActive}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: AppTheme.secondary),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
