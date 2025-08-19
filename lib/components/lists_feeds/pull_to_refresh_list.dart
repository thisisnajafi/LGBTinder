import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

class PullToRefreshList extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool isLoading;
  final String? loadingMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const PullToRefreshList({
    Key? key,
    required this.child,
    required this.onRefresh,
    this.isLoading = false,
    this.loadingMessage,
    this.errorMessage,
    this.onRetry,
  }) : super(key: key);

  @override
  State<PullToRefreshList> createState() => _PullToRefreshListState();
}

class _PullToRefreshListState extends State<PullToRefreshList>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorLight,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              widget.errorMessage!,
              style: AppTypography.bodyLargeStyle.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: widget.onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    if (widget.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            if (widget.loadingMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                widget.loadingMessage!,
                style: AppTypography.bodyLargeStyle.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primaryLight,
      backgroundColor: Theme.of(context).cardColor,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _isRefreshing ? 20 * (1 - _animation.value) : 0),
            child: Opacity(
              opacity: _isRefreshing ? _animation.value : 1.0,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
} 