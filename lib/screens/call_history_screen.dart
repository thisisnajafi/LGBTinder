import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/api_services/call_api_service.dart';

/// Call History Screen
/// 
/// Displays list of all voice and video calls:
/// - Incoming and outgoing calls
/// - Missed call indicators
/// - Call duration display
/// - Redial functionality
/// - Delete from history
/// - Block calls from user
class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  final CallApiService _callApiService = CallApiService();
  
  List<CallHistoryItem> _callHistory = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCallHistory();
  }

  Future<void> _loadCallHistory() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final history = await _callApiService.getCallHistory();
      if (mounted) {
        setState(() {
          _callHistory = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCall(String callId) async {
    final success = await _callApiService.deleteCallFromHistory(callId);
    
    if (success) {
      setState(() {
        _callHistory.removeWhere((call) => call.callId == callId);
      });
      _showSnackBar('Call removed from history');
    } else {
      _showSnackBar('Failed to delete call', isError: true);
    }
  }

  Future<void> _blockUser(String userId) async {
    final success = await _callApiService.blockCallsFrom(userId);
    
    if (success) {
      _showSnackBar('User blocked from calling you');
      _loadCallHistory(); // Refresh list
    } else {
      _showSnackBar('Failed to block user', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  void _initiateCall(CallHistoryItem call) {
    // Navigate to appropriate call screen
    if (call.isVideo) {
      Navigator.pushNamed(
        context,
        '/video-call',
        arguments: {
          'userId': call.userId,
          'userName': call.userName,
          'userAvatar': call.userAvatar,
        },
      );
    } else {
      Navigator.pushNamed(
        context,
        '/voice-call',
        arguments: {
          'userId': call.userId,
          'userName': call.userName,
          'userAvatar': call.userAvatar,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navbarBackground,
        elevation: 0,
        title: Text(
          'Call History',
          style: AppTypography.h4.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCallHistory,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load call history',
              style: AppTypography.body1.copyWith(
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCallHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_callHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_disabled,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'No call history',
              style: AppTypography.body1.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _callHistory.length,
      itemBuilder: (context, index) {
        final call = _callHistory[index];
        return _buildCallHistoryItem(call);
      },
    );
  }

  Widget _buildCallHistoryItem(CallHistoryItem call) {
    return Dismissible(
      key: Key(call.callId),
      background: _buildSwipeBackground(
        color: AppColors.error,
        icon: Icons.delete,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeBackground(
        color: Colors.orange,
        icon: Icons.block,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Delete
          return await _showDeleteConfirmation(call);
        } else {
          // Block
          return await _showBlockConfirmation(call);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _deleteCall(call.callId);
        } else {
          _blockUser(call.userId);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.navbarBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: call.userAvatar != null
                    ? NetworkImage(call.userAvatar!)
                    : null,
                child: call.userAvatar == null
                    ? Text(
                        call.userName.substring(0, 1).toUpperCase(),
                        style: AppTypography.h4.copyWith(
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    call.isVideo ? Icons.videocam : Icons.phone,
                    size: 14,
                    color: _getCallStatusColor(call),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  call.userName,
                  style: AppTypography.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (call.isMissed)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Missed',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(
                call.direction == CallDirection.incoming
                    ? Icons.call_received
                    : Icons.call_made,
                size: 14,
                color: _getCallStatusColor(call),
              ),
              const SizedBox(width: 4),
              Text(
                call.timeAgo,
                style: AppTypography.caption.copyWith(
                  color: Colors.white54,
                ),
              ),
              if (call.duration != null && call.duration! > 0) ...[
                Text(
                  ' · ',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
                Text(
                  call.formattedDuration,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              call.isVideo ? Icons.videocam : Icons.phone,
              color: AppColors.primary,
            ),
            onPressed: () => _initiateCall(call),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Icon(
        icon,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Color _getCallStatusColor(CallHistoryItem call) {
    if (call.isMissed) {
      return AppColors.error;
    } else if (call.status == CallStatus.completed) {
      return AppColors.success;
    } else if (call.status == CallStatus.rejected) {
      return AppColors.warning;
    } else {
      return Colors.white54;
    }
  }

  Future<bool> _showDeleteConfirmation(CallHistoryItem call) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.navbarBackground,
            title: Text(
              'Delete Call',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
              ),
            ),
            content: Text(
              'Remove this call from your history?',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showBlockConfirmation(CallHistoryItem call) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.navbarBackground,
            title: Text(
              'Block User',
              style: AppTypography.h4.copyWith(
                color: Colors.white,
              ),
            ),
            content: Text(
              'Block ${call.userName} from calling you?',
              style: AppTypography.body2.copyWith(
                color: Colors.white70,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: AppTypography.body1.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Block',
                  style: AppTypography.body1.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}

