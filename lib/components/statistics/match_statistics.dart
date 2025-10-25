import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/colors.dart';
import '../theme/typography.dart';
import '../services/haptic_feedback_service.dart';

class MatchStatistics {
  final int totalMatches;
  final int totalLikes;
  final int totalSuperLikes;
  final int totalPasses;
  final int totalSwipes;
  final double matchRate;
  final double likeRate;
  final double superLikeRate;
  final int streakDays;
  final int bestStreak;
  final DateTime? lastMatchDate;
  final List<MatchTrend> weeklyTrends;
  final List<MatchTrend> monthlyTrends;

  const MatchStatistics({
    required this.totalMatches,
    required this.totalLikes,
    required this.totalSuperLikes,
    required this.totalPasses,
    required this.totalSwipes,
    required this.matchRate,
    required this.likeRate,
    required this.superLikeRate,
    required this.streakDays,
    required this.bestStreak,
    this.lastMatchDate,
    required this.weeklyTrends,
    required this.monthlyTrends,
  });

  factory MatchStatistics.empty() {
    return MatchStatistics(
      totalMatches: 0,
      totalLikes: 0,
      totalSuperLikes: 0,
      totalPasses: 0,
      totalSwipes: 0,
      matchRate: 0.0,
      likeRate: 0.0,
      superLikeRate: 0.0,
      streakDays: 0,
      bestStreak: 0,
      weeklyTrends: [],
      monthlyTrends: [],
    );
  }
}

class MatchTrend {
  final DateTime date;
  final int matches;
  final int likes;
  final int superLikes;
  final int passes;

  const MatchTrend({
    required this.date,
    required this.matches,
    required this.likes,
    required this.superLikes,
    required this.passes,
  });
}

class MatchStatisticsWidget extends StatefulWidget {
  final MatchStatistics statistics;
  final VoidCallback? onRefresh;
  final bool isLoading;

  const MatchStatisticsWidget({
    Key? key,
    required this.statistics,
    this.onRefresh,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<MatchStatisticsWidget> createState() => _MatchStatisticsWidgetState();
}

class _MatchStatisticsWidgetState extends State<MatchStatisticsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  int _selectedPeriod = 0; // 0: Weekly, 1: Monthly
  final List<String> _periods = ['Weekly', 'Monthly'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.navbarBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildOverviewCards(),
                  const SizedBox(height: 20),
                  _buildTrendSection(),
                  const SizedBox(height: 20),
                  _buildDetailedStats(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.analytics,
          color: AppColors.primaryLight,
          size: 28,
        ),
        const SizedBox(width: 12),
        const Text(
          'Match Statistics',
          style: AppTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const Spacer(),
        if (widget.onRefresh != null)
          GestureDetector(
            onTap: () {
              HapticFeedbackService.selection();
              widget.onRefresh?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.refresh,
                color: AppColors.primaryLight,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Matches',
            value: widget.statistics.totalMatches.toString(),
            icon: Icons.favorite,
            color: AppColors.prideRed,
            subtitle: '${widget.statistics.matchRate.toStringAsFixed(1)}% match rate',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Current Streak',
            value: widget.statistics.streakDays.toString(),
            icon: Icons.local_fire_department,
            color: AppColors.prideOrange,
            subtitle: 'Best: ${widget.statistics.bestStreak} days',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              fontSize: 10,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Trends',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _periods.asMap().entries.map((entry) {
                  final index = entry.key;
                  final period = entry.value;
                  final isSelected = _selectedPeriod == index;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPeriod = index;
                      });
                      HapticFeedbackService.selection();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        period,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTrendChart(),
      ],
    );
  }

  Widget _buildTrendChart() {
    final trends = _selectedPeriod == 0 
        ? widget.statistics.weeklyTrends 
        : widget.statistics.monthlyTrends;
    
    if (trends.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: TrendChartPainter(
          trends: trends,
          period: _selectedPeriod,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detailed Statistics',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        const SizedBox(height: 16),
        _buildStatRow('Total Likes', widget.statistics.totalLikes.toString(), AppColors.prideGreen),
        _buildStatRow('Total Super Likes', widget.statistics.totalSuperLikes.toString(), AppColors.prideYellow),
        _buildStatRow('Total Passes', widget.statistics.totalPasses.toString(), AppColors.textSecondaryDark),
        _buildStatRow('Total Swipes', widget.statistics.totalSwipes.toString(), AppColors.primaryLight),
        _buildStatRow('Like Rate', '${widget.statistics.likeRate.toStringAsFixed(1)}%', AppColors.prideGreen),
        _buildStatRow('Super Like Rate', '${widget.statistics.superLikeRate.toStringAsFixed(1)}%', AppColors.prideYellow),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimaryDark,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  final List<MatchTrend> trends;
  final int period;

  TrendChartPainter({
    required this.trends,
    required this.period,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final maxMatches = trends.map((t) => t.matches).reduce(math.max);
    final maxLikes = trends.map((t) => t.likes).reduce(math.max);
    final maxValue = math.max(maxMatches, maxLikes);

    // Draw matches line
    paint.color = AppColors.prideRed;
    _drawLine(canvas, size, trends.map((t) => t.matches).toList(), maxValue, paint);

    // Draw likes line
    paint.color = AppColors.prideGreen;
    _drawLine(canvas, size, trends.map((t) => t.likes).toList(), maxValue, paint);

    // Draw super likes line
    paint.color = AppColors.prideYellow;
    _drawLine(canvas, size, trends.map((t) => t.superLikes).toList(), maxValue, paint);
  }

  void _drawLine(Canvas canvas, Size size, List<int> values, int maxValue, Paint paint) {
    if (values.isEmpty) return;

    final path = Path();
    final stepX = size.width / (values.length - 1);
    
    for (int i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - (values[i] / maxValue) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TrendChartPainter oldDelegate) {
    return oldDelegate.trends != trends || oldDelegate.period != period;
  }
}

class MatchStatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const MatchStatisticsCard({
    Key? key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackService.selection();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchStatisticsProvider {
  static MatchStatistics generateSampleStatistics() {
    final now = DateTime.now();
    final weeklyTrends = List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return MatchTrend(
        date: date,
        matches: math.Random().nextInt(5),
        likes: math.Random().nextInt(20),
        superLikes: math.Random().nextInt(3),
        passes: math.Random().nextInt(15),
      );
    });

    final monthlyTrends = List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      return MatchTrend(
        date: date,
        matches: math.Random().nextInt(10),
        likes: math.Random().nextInt(50),
        superLikes: math.Random().nextInt(8),
        passes: math.Random().nextInt(40),
      );
    });

    return MatchStatistics(
      totalMatches: 42,
      totalLikes: 156,
      totalSuperLikes: 23,
      totalPasses: 89,
      totalSwipes: 268,
      matchRate: 15.7,
      likeRate: 58.2,
      superLikeRate: 8.6,
      streakDays: 5,
      bestStreak: 12,
      lastMatchDate: now.subtract(const Duration(hours: 3)),
      weeklyTrends: weeklyTrends,
      monthlyTrends: monthlyTrends,
    );
  }
}
