import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';
import '../avatar/animated_avatar.dart';

class SearchResult {
  final String id;
  final String name;
  final int age;
  final String imageUrl;
  final String bio;
  final List<String> interests;
  final double distance;
  final bool isVerified;

  const SearchResult({
    required this.id,
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.bio,
    required this.interests,
    required this.distance,
    this.isVerified = false,
  });
}

class SearchResultsList extends StatefulWidget {
  final List<SearchResult> results;
  final Function(SearchResult) onResultTap;
  final Function() onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const SearchResultsList({
    Key? key,
    required this.results,
    required this.onResultTap,
    required this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  }) : super(key: key);

  @override
  State<SearchResultsList> createState() => _SearchResultsListState();
}

class _SearchResultsListState extends State<SearchResultsList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && widget.hasMore && !widget.isLoading) {
        setState(() {
          _isLoadingMore = true;
        });
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.error != null) {
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
              widget.error!,
              style: AppTypography.bodyLargeStyle.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: widget.results.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == widget.results.length) {
          return _LoadingMoreIndicator();
        }

        return _SearchResultItem(
          result: widget.results[index],
          onTap: () => widget.onResultTap(widget.results[index]),
        );
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  result.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppColors.cardBackgroundLight,
                      child: Icon(
                        Icons.image,
                        size: 48,
                        color: AppColors.textSecondaryLight,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${result.name}, ${result.age}',
                          style: AppTypography.titleLargeStyle,
                        ),
                        if (result.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            color: AppColors.successLight,
                            size: 20,
                          ),
                        ],
                        const Spacer(),
                        Text(
                          '${result.distance.toStringAsFixed(1)} km',
                          style: AppTypography.bodyMediumStyle.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.bio,
                      style: AppTypography.bodyMediumStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.interests.map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            interest,
                            style: AppTypography.bodySmallStyle.copyWith(
                              color: AppColors.primaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
} 