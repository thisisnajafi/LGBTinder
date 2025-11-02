import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../../services/profile_analytics_service.dart';
import '../../services/haptic_feedback_service.dart';
import '../../components/analytics/analytics_components.dart';
import '../../components/buttons/animated_button.dart';

class ProfileAnalyticsScreen extends StatefulWidget {
  const ProfileAnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileAnalyticsScreen> createState() => _ProfileAnalyticsScreenState();
}

class _ProfileAnalyticsScreenState extends State<ProfileAnalyticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _trends;
  List<AnalyticsEvent> _recentEvents = [];
  ProfileAnalytics? _analytics;
  bool _isLoading = true;
  String _profileId = 'current_user'; // In a real app, this would come from user session

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadAnalyticsData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyticsData() async {
    try {
      final summary = await ProfileAnalyticsService.instance.getAnalyticsSummary(_profileId);
      final trends = await ProfileAnalyticsService.instance.getAnalyticsTrends(_profileId);
      final recentEvents = await ProfileAnalyticsService.instance.getAnalyticsEvents(
        targetProfileId: _profileId,
        limit: 20,
      );
      final analytics = await ProfileAnalyticsService.instance.getProfileAnalytics(_profileId);
      
      if (mounted) {
        setState(() {
          _summary = summary;
          _trends = trends;
          _recentEvents = recentEvents;
          _analytics = analytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryLight,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark),
          onPressed: () {
            HapticFeedbackService.selection();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Profile Analytics',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimaryDark),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.textPrimaryDark),
            onPressed: _exportData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryLight,
          unselectedLabelColor: AppColors.textSecondaryDark,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  _buildTrendsTab(),
                  _buildActivityTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_summary != null)
            AnalyticsSummaryCard(
              summary: _summary!,
              onTap: _showDetailedSummary,
            ),
          
          const SizedBox(height: 24),
          
          if (_analytics != null) _buildDetailedMetrics(),
          
          const SizedBox(height: 24),
          
          if (_summary != null) _buildEngagementMetrics(),
          
          const SizedBox(height: 24),
          
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_trends != null)
            AnalyticsTrendsCard(
              trends: _trends!,
              onTap: _showDetailedTrends,
            ),
          
          const SizedBox(height: 24),
          
          if (_trends != null) _buildTrendCharts(),
          
          const SizedBox(height: 24),
          
          _buildTrendInsights(),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (_recentEvents.isEmpty)
            _buildEmptyActivityState()
          else
            ..._recentEvents.map((event) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnalyticsEventCard(
                  event: event,
                  onTap: () => _showEventDetails(event),
                ),
              );
            }),
          
          const SizedBox(height: 24),
          
          _buildActivityFilters(),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Metrics',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Super Likes',
                  '${_analytics!.totalSuperLikes}',
                  Icons.star,
                  AppColors.feedbackWarning,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Passes',
                  '${_analytics!.totalPasses}',
                  Icons.close,
                  AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Shares',
                  '${_analytics!.totalShares}',
                  Icons.share,
                  AppColors.primaryLight,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Reports',
                  '${_analytics!.totalReports}',
                  Icons.report,
                  AppColors.feedbackError,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Blocks',
                  '${_analytics!.totalBlocks}',
                  Icons.block,
                  AppColors.feedbackError,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  'Visits',
                  '${_analytics!.totalVisits}',
                  Icons.visibility,
                  AppColors.feedbackInfo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Metrics',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEngagementItem(
                  'Like Rate',
                  '${_summary!['likeRate'].toStringAsFixed(1)}%',
                  AppColors.feedbackError,
                ),
              ),
              Expanded(
                child: _buildEngagementItem(
                  'Message Rate',
                  '${_summary!['messageRate'].toStringAsFixed(1)}%',
                  AppColors.feedbackSuccess,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEngagementItem(
                  'Pass Rate',
                  '${_summary!['passRate'].toStringAsFixed(1)}%',
                  AppColors.feedbackWarning,
                ),
              ),
              Expanded(
                child: _buildEngagementItem(
                  'Engagement',
                  '${_summary!['engagementRate'].toStringAsFixed(1)}%',
                  AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCharts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          AnalyticsChartCard(
            title: 'Daily Views',
            data: _getChartData('views'),
            xAxisLabel: 'Days',
            yAxisLabel: 'Views',
            onTap: _showChartDetails,
          ),
          const SizedBox(height: 16),
          AnalyticsChartCard(
            title: 'Daily Likes',
            data: _getChartData('likes'),
            xAxisLabel: 'Days',
            yAxisLabel: 'Likes',
            onTap: _showChartDetails,
          ),
        ],
      ),
    );
  }

  Widget _buildTrendInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trend Insights',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_up,
            'Profile Performance',
            'Your profile is getting ${_trends!['averageViewsPerDay'].toStringAsFixed(1)} views per day on average',
            AppColors.feedbackSuccess,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.favorite,
            'Like Rate',
            'You\'re getting ${_trends!['averageLikesPerDay'].toStringAsFixed(1)} likes per day',
            AppColors.feedbackError,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            Icons.chat,
            'Message Activity',
            'You\'re receiving ${_trends!['averageMessagesPerDay'].toStringAsFixed(1)} messages per day',
            AppColors.feedbackInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: AppColors.textSecondaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            'No Activity Yet',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start using the app to see your profile analytics',
            style: AppTypography.body1.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Activity',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', true),
              _buildFilterChip('Views', false),
              _buildFilterChip('Likes', false),
              _buildFilterChip('Messages', false),
              _buildFilterChip('Shares', false),
              _buildFilterChip('Reports', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTypography.subtitle1.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackInfo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _clearData,
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text('Clear Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackError,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showSettings,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Settings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.feedbackWarning,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.body1.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        HapticFeedbackService.selection();
        // TODO: Implement filter logic
      },
      selectedColor: AppColors.primaryLight.withOpacity(0.2),
      checkmarkColor: AppColors.primaryLight,
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryDark,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  List<Map<String, dynamic>> _getChartData(String type) {
    // Mock data for charts - in a real app, this would come from the trends data
    return List.generate(7, (index) {
      return {
        'label': 'Day ${index + 1}',
        'value': (index + 1) * 5 + (index % 3) * 2,
      };
    });
  }

  void _refreshData() {
    HapticFeedbackService.selection();
    setState(() {
      _isLoading = true;
    });
    _loadAnalyticsData();
  }

  void _exportData() {
    HapticFeedbackService.selection();
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _clearData() {
    HapticFeedbackService.selection();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Clear Analytics Data',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to clear all analytics data? This action cannot be undone.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear analytics data
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analytics data cleared'),
                  backgroundColor: AppColors.feedbackSuccess,
                ),
              );
              _refreshData();
            },
            child: Text(
              'Clear',
              style: AppTypography.button.copyWith(color: AppColors.feedbackError),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    HapticFeedbackService.selection();
    // TODO: Show analytics settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics settings coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  void _showDetailedSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Detailed Summary',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_summary != null) ...[
                Text(
                  'Total Views: ${_summary!['totalViews']}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Likes: ${_summary!['totalLikes']}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Messages: ${_summary!['totalMessages']}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Engagement Rate: ${_summary!['engagementRate'].toStringAsFixed(1)}%',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.button.copyWith(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedTrends() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Detailed Trends',
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_trends != null) ...[
                Text(
                  'Period: ${_trends!['period']}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Average Views/Day: ${_trends!['averageViewsPerDay'].toStringAsFixed(1)}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Average Likes/Day: ${_trends!['averageLikesPerDay'].toStringAsFixed(1)}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 8),
                Text(
                  'Average Messages/Day: ${_trends!['averageMessagesPerDay'].toStringAsFixed(1)}',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.button.copyWith(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(AnalyticsEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          _getEventDisplayName(event.type),
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimaryDark),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: ${_formatDate(event.timestamp)}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
            ),
            if (event.targetUserId != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target User: ${event.targetUserId}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ],
            if (event.location != null) ...[
              const SizedBox(height: 8),
              Text(
                'Location: ${event.location}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ],
            if (event.source != null) ...[
              const SizedBox(height: 8),
              Text(
                'Source: ${event.source}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTypography.button.copyWith(color: AppColors.primaryLight),
            ),
          ),
        ],
      ),
    );
  }

  void _showChartDetails() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chart details coming soon!'),
        backgroundColor: AppColors.feedbackInfo,
      ),
    );
  }

  String _getEventDisplayName(AnalyticsEventType type) {
    switch (type) {
      case AnalyticsEventType.profileView:
        return 'Profile Viewed';
      case AnalyticsEventType.profileLike:
        return 'Profile Liked';
      case AnalyticsEventType.profileSuperLike:
        return 'Profile Super Liked';
      case AnalyticsEventType.profilePass:
        return 'Profile Passed';
      case AnalyticsEventType.profileMessage:
        return 'Message Sent';
      case AnalyticsEventType.profileShare:
        return 'Profile Shared';
      case AnalyticsEventType.profileReport:
        return 'Profile Reported';
      case AnalyticsEventType.profileBlock:
        return 'User Blocked';
      case AnalyticsEventType.profileUnblock:
        return 'User Unblocked';
      case AnalyticsEventType.profileVisit:
        return 'Profile Visited';
      case AnalyticsEventType.profileEdit:
        return 'Profile Edited';
      case AnalyticsEventType.profilePhotoAdd:
        return 'Photo Added';
      case AnalyticsEventType.profilePhotoRemove:
        return 'Photo Removed';
      case AnalyticsEventType.profileBioUpdate:
        return 'Bio Updated';
      case AnalyticsEventType.profileInterestAdd:
        return 'Interest Added';
      case AnalyticsEventType.profileInterestRemove:
        return 'Interest Removed';
      case AnalyticsEventType.profileLocationUpdate:
        return 'Location Updated';
      case AnalyticsEventType.profileVerificationSubmit:
        return 'Verification Submitted';
      case AnalyticsEventType.profileVerificationComplete:
        return 'Verification Completed';
      case AnalyticsEventType.profileCustomization:
        return 'Profile Customized';
      case AnalyticsEventType.profilePrivacyChange:
        return 'Privacy Changed';
      case AnalyticsEventType.profileVisibilityChange:
        return 'Visibility Changed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
