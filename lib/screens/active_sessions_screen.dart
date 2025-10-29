import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/device_session.dart';
import '../services/api_services/device_session_api_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Active Sessions Screen
/// 
/// Features:
/// - View all active sessions
/// - See device info and location
/// - Revoke individual sessions
/// - Revoke all other sessions
class ActiveSessionsScreen extends StatefulWidget {
  const ActiveSessionsScreen({Key? key}) : super(key: key);

  @override
  State<ActiveSessionsScreen> createState() => _ActiveSessionsScreenState();
}

class _ActiveSessionsScreenState extends State<ActiveSessionsScreen> {
  late DeviceSessionApiService _apiService;
  List<DeviceSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _apiService = DeviceSessionApiService(
      authService: AuthService(),
    );
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);

    try {
      final sessions = await _apiService.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading sessions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _revokeSession(DeviceSession session) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Revoke Session',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to revoke this session? You will be logged out on this device.',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Revoke',
              style: AppTypography.button.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.revokeSession(session.id);
        await _loadSessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session revoked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _revokeAllOtherSessions() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navbarBackground,
        title: Text(
          'Revoke All Other Sessions',
          style: AppTypography.h4.copyWith(color: Colors.white),
        ),
        content: Text(
          'This will log you out from all other devices except this one. Are you sure?',
          style: AppTypography.body1.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.button.copyWith(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Revoke All',
              style: AppTypography.button.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.revokeAllOtherSessions();
        await _loadSessions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All other sessions revoked'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final otherSessions =
        _sessions.where((session) => !session.isCurrent).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Active Sessions',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (otherSessions.isNotEmpty)
            TextButton(
              onPressed: _revokeAllOtherSessions,
              child: Text(
                'Revoke All',
                style: AppTypography.button.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage devices where you\'re currently logged in',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Current Session
                Text(
                  'This Device',
                  style: AppTypography.h5.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...(_sessions.where((s) => s.isCurrent).map((session) =>
                    _SessionCard(
                      session: session,
                      onRevoke: null,
                    ))),

                if (otherSessions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Other Devices',
                    style: AppTypography.h5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...otherSessions.map((session) => _SessionCard(
                        session: session,
                        onRevoke: () => _revokeSession(session),
                      )),
                ],

                if (_sessions.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        const Icon(
                          Icons.devices,
                          size: 80,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No active sessions',
                          style: AppTypography.body1.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final DeviceSession session;
  final VoidCallback? onRevoke;

  const _SessionCard({
    required this.session,
    this.onRevoke,
  });

  IconData _getDeviceIcon() {
    switch (session.deviceType.toLowerCase()) {
      case 'mobile':
      case 'phone':
        return Icons.phone_android;
      case 'tablet':
        return Icons.tablet;
      case 'desktop':
      case 'pc':
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  String _formatLastActive() {
    final now = DateTime.now();
    final difference = now.difference(session.lastActive);

    if (difference.inMinutes < 1) {
      return 'Active now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(session.lastActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.navbarBackground,
        borderRadius: BorderRadius.circular(12),
        border: session.isCurrent
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: session.isCurrent
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDeviceIcon(),
                color: session.isCurrent ? AppColors.primary : Colors.white54,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    session.deviceName,
                    style: AppTypography.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (session.isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Current',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.public,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        session.browser,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      session.location,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      _formatLastActive(),
                      style: AppTypography.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: onRevoke != null
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onRevoke,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

