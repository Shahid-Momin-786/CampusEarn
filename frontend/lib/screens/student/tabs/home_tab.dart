import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/job_provider.dart';
import '../../../../providers/application_provider.dart';
import '../../../../core/theme.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    // Fetching jobs with coordinates (dummy location for now: approx NY)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<JobProvider>(context, listen: false)
          .fetchNearbyJobs(40.7128, -74.0060, radius: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final appProvider = Provider.of<ApplicationProvider>(context);
    // Build a set of job IDs the student has already applied to
    final appliedJobIds = appProvider.studentApplications.map((a) => a.job).toSet();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => jobProvider.fetchNearbyJobs(40.7128, -74.0060, radius: 20),
          color: AppTheme.primary,
          child: CustomScrollView(
            slivers: [
              // Hero Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good Morning,',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Find Your Next Gig 🚀',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 28,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.secondary],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.transparent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Search Bar Placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.surface.withOpacity(0.5)),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for campus jobs...',
                            hintStyle: TextStyle(color: AppTheme.textSecondary),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            fillColor: Colors.transparent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nearby Opportunities',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                          Text(
                            'Filters',
                            style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Content Section
              if (jobProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                )
              else if (jobProvider.error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Text('Error: ${jobProvider.error}', style: const TextStyle(color: AppTheme.error)),
                  ),
                )
              else if (jobProvider.nearbyJobs.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No nearby jobs found.')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final job = jobProvider.nearbyJobs[index];
                        return _buildPremiumJobCard(job, context, appliedJobIds);
                      },
                      childCount: jobProvider.nearbyJobs.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumJobCard(job, BuildContext context, Set<int> appliedJobIds) {
    final alreadyApplied = appliedJobIds.contains(job.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business_center, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.employerCompany,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${job.hourlyRate}/hr',
                    style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              job.description,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      job.distanceKm != null ? '${job.distanceKm} km away' : job.locationName ?? 'Campus',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                alreadyApplied
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.success.withOpacity(0.4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle_outline, color: AppTheme.success, size: 16),
                            SizedBox(width: 6),
                            Text('Applied', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          try {
                            await Provider.of<ApplicationProvider>(context, listen: false).applyForJob(job.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ Successfully applied!'), backgroundColor: AppTheme.success),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.error),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply Now'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
