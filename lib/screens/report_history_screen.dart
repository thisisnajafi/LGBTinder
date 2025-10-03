import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../models/api_models/user_models.dart';
import '../services/reporting_service.dart';
import '../providers/auth_provider.dart';
import '../components/error_handling/error_display_widget.dart';
import '../components/loading/loading_widgets.dart';
import '../components/error_handling/error_snackbar.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  List<Report> _reports = [];
  bool _isLoading = true;
  String? _error;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'User', 'Content', 'Message', 'Call'];

  @override
  void initState() {
    super.initState();
    _loadReportHistory();
  }

  Future<void> _loadReportHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      final reports = await ReportingService.getReportHistory(accessToken: accessToken);
      
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelReport(Report report) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final accessToken = await authProvider.accessToken;

      if (accessToken == null) {
        throw Exception('No access token available');
      }

      await ReportingService.cancelReport(
        reportId: report.id,
        accessToken: accessToken,
      );

      setState(() {
        _reports.removeWhere((r) => r.id == report.id);
      });

      if (mounted) {
        ErrorSnackBar.showSuccess(
          context,
          'Report cancelled successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorSnackBar.show(
          context,
          'Failed to cancel report: ${e.toString().replaceFirst('Exception: ', '')}',
        );
      }
    }
  }

  void _showCancelConfirmation(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Cancel Report',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to cancel this report? This action cannot be undone.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTypography.body1.copyWith(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelReport(report);
            },
            child: Text(
              'Cancel Report',
              style: AppTypography.body1.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      appBar: AppBar(
        title: const Text('Report History'),
        backgroundColor: AppColors.navbarBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadReportHistory,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return LoadingWidgets.fullScreen(
        message: 'Loading report history...',
      );
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _loadReportHistory,
        retryText: 'Retry',
      );
    }

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: _buildReportList(),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _ filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTypography.body2.copyWith(
                  color: isSelected ? AppColors.primary : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                backgroundColor: AppColors.navbarBackground,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.white24,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildReportList() {
    final filteredReports = _reports.where((report) {
      if (_selectedFilter == 'All') return true;
      return report.type.toLowerCase().contains(_selectedFilter toLowerCase());
    }).toList();

    if (filteredReports.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredReports.length,
      itemBuilder: (context, index) {
        final report = filteredReports[index];
        return _buildReportCard(report);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFilter == 'All' ? Icons.report_outlined : Icons.filter_alt_off,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedFilter == 'All' 
                  ? 'No reports found'
                  : 'No reports found for ${_selectedFilter.toLowerCase()}',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedFilter == 'All') ...[
              const SizedBox(height: 8),
              Text(
                'Reports you submit will appear here',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Report report) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(report.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getReportIcon(report.type),
                color: _getStatusColor(report.status),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reported ${report.type}',
                      style: AppTypography.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Reason: ${report.reason}',
                      style: AppTypography.body2.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(report.status),
            ],
          ),
          if (report.description != null) ...[
            const SizedBox(height: 8),
            Text(
              report.description!,
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Submitted: ${_formatDate(report.createdAt)}',
                style: AppTypography.caption.copyWith(
                  color: Colors.white54,
                ),
              ),
              const Spacer(),
              if (report.status.toLowerCase() == 'pending') ...[
                TextButton(
                  onPressed: () => _showCancelConfirmation(report),
                  child: Text(
                    'Cancel',
                    style: AppTypography.body2.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);
    final backgroundColor = color.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type.toLowerCase()) {
      case 'user':
        return Icons.person_off;
      case 'content':
        return Icons.content_copy;
      case 'message':
        return Icons.message;
      case 'call':
        return Icons.phone;
      default:
        return Icons.report;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class Report {
  final String id;
  final String type;
  final String reason;
  final String? description;
  final String status;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.type,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      type: json['reportable_type'] ?? 'Unknown',
      reason: json['reason'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
