import 'package:flutter/foundation.dart';
import '../models/api_models/matching_models.dart';
import '../models/api_models/auth_models.dart';
import '../models/user.dart';
import '../services/api_services/matching_api_service.dart';
import '../services/api_services/discovery_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';
import '../services/cache_service.dart';
import '../models/user_state_models.dart';

class MatchingStateProvider extends ChangeNotifier {
  // State variables
  List<MatchData> _matches = [];
  List<User> _potentialMatches = [];
  bool _isLoading = false;
  bool _isLiking = false;
  AuthError? _error;
  String? _lastLikeError;
  int? _lastLikedUserId;

  // Getters
  List<MatchData> get matches => _matches;
  List<User> get potentialMatches => _potentialMatches;
  bool get isLoading => _isLoading;
  bool get isLiking => _isLiking;
  AuthError? get error => _error;
  String? get lastLikeError => _lastLikeError;
  int? get lastLikedUserId => _lastLikedUserId;

  // Initialize the provider
  Future<void> initialize() async {
    await loadMatches();
  }

  // Load user matches
  Future<void> loadMatches() async {
    try {
      _setLoading(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final response = await MatchingApiService.getMatches(token);
      _matches = response.data;
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Like a user
  Future<bool> likeUser(int targetUserId) async {
    try {
      _setLiking(true);
      _clearError();
      _lastLikeError = null;
      _lastLikedUserId = targetUserId;

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting
      await RateLimitingService.checkRateLimit('likes');

      final request = LikeUserRequest(targetUserId: targetUserId);
      final response = await MatchingApiService.likeUser(request, token);

      if (response.status) {
        // If it's a match, refresh matches to get the new match
        if (response.data != null && response.data!.isMatch) {
          await loadMatches();
        }
        notifyListeners();
        return true;
      } else {
        _lastLikeError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is RateLimitExceededException) {
        _lastLikeError = e.message;
      } else {
        _handleError(e);
      }
      notifyListeners();
      return false;
    } finally {
      _setLiking(false);
    }
  }

  // Check if user is already liked
  bool isUserLiked(int userId) {
    // This would need to be implemented based on your API
    // For now, we'll assume we don't have this information
    return false;
  }

  // Get match by ID
  MatchData? getMatchById(int matchId) {
    try {
      return _matches.firstWhere((match) => match.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  // Get match by user ID
  MatchData? getMatchByUserId(int userId) {
    try {
      return _matches.firstWhere((match) => match.user.id == userId);
    } catch (e) {
      return null;
    }
  }

  // Refresh matches
  Future<void> refreshMatches() async {
    await loadMatches();
  }

  // Clear all data
  void clearData() {
    _matches.clear();
    _clearError();
    _lastLikeError = null;
    _lastLikedUserId = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLiking(bool liking) {
    _isLiking = liking;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    if (error is AuthError) {
      _error = error;
    } else if (error is RateLimitExceededException) {
      _error = AuthError(
        type: AuthErrorType.networkError,
        message: error.message,
        details: {'retry_after': error.retryAfter, 'message': 'Rate limit exceeded'},
      );
    } else {
      _error = AuthError(
        type: AuthErrorType.unknownError,
        message: 'An unexpected error occurred',
        details: {'error': error.toString()},
      );
    }
    notifyListeners();
  }

  // Load potential matches from discovery API
  Future<void> loadPotentialMatches({
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? filters,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Fetch profiles from discovery API
      final result = await DiscoveryApiService.getDiscoveryProfiles(
        token: token,
        page: page,
        limit: limit,
        filters: filters,
      );

      if (result['success'] == true) {
        _potentialMatches = result['profiles'] as List<User>;
        
        // Cache the profiles for offline access
        await CacheService.setData(
          key: 'discovery_profiles',
          value: _potentialMatches.map((u) => u.toJson()).toList(),
          expiryMinutes: 30,
        );
      } else {
        // Try to load from cache if API fails
        final cachedData = await CacheService.getData('discovery_profiles');
        if (cachedData != null && cachedData is List) {
          _potentialMatches = cachedData
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw AuthError(
            type: AuthErrorType.networkError,
            message: result['error'] as String? ?? 'Failed to load profiles',
          );
        }
      }
      
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Super like a user
  Future<bool> superLikeUser(int userId) async {
    try {
      _setLiking(true);
      _clearError();
      _lastLikeError = null;
      _lastLikedUserId = userId;

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      // Check rate limiting for superlikes
      await RateLimitingService.checkRateLimit('superlikes');

      final result = await MatchingApiService.superlikeUser(userId, token);

      if (result['success'] == true) {
        final isMatch = result['isMatch'] as bool? ?? false;
        
        // If it's a match, refresh matches to get the new match
        if (isMatch) {
          await loadMatches();
        }
        
        notifyListeners();
        return isMatch;
      } else {
        _lastLikeError = result['error'] as String?;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is RateLimitExceededException) {
        _lastLikeError = e.message;
      } else {
        _handleError(e);
      }
      notifyListeners();
      return false;
    } finally {
      _setLiking(false);
    }
  }

  // Dislike a user
  Future<void> dislikeUser(int userId) async {
    try {
      _setLoading(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final result = await MatchingApiService.dislikeUser(userId, token);

      if (result['success'] != true) {
        throw AuthError(
          type: AuthErrorType.networkError,
          message: result['error'] as String? ?? 'Failed to dislike user',
        );
      }
      
      notifyListeners();
    } catch (e) {
      _handleError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Load more matches (pagination)
  Future<void> loadMoreMatches() async {
    try {
      _setLoading(true);
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('No token');

      // Mock loading more matches for now
      // TODO: Implement actual pagination logic
      await Future.delayed(Duration(milliseconds: 500));
      
      notifyListeners();
    } catch (e) {
      _handleError(e);
    }
  }

  // ============================================================================
  // PREMIUM FEATURES
  // ============================================================================

  /// Undo last swipe (Premium feature)
  Future<User?> undoLastSwipe() async {
    try {
      _setLoading(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final result = await MatchingApiService.undoLastSwipe(token);

      if (result['success'] == true) {
        // Parse user data if available
        if (result['user'] != null) {
          final user = User.fromJson(result['user'] as Map<String, dynamic>);
          notifyListeners();
          return user;
        }
      } else {
        throw AuthError(
          type: AuthErrorType.networkError,
          message: result['error'] as String? ?? 'Failed to undo swipe',
        );
      }
      
      notifyListeners();
      return null;
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Boost profile (Premium feature)
  Future<bool> boostProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final token = await TokenManagementService.getAccessToken();
      if (token == null) {
        throw AuthError(
          type: AuthErrorType.unknownError,
          message: 'No authentication token found',
        );
      }

      final result = await MatchingApiService.boostProfile(token);

      if (result['success'] == true) {
        notifyListeners();
        return true;
      } else {
        throw AuthError(
          type: AuthErrorType.networkError,
          message: result['error'] as String? ?? 'Failed to boost profile',
        );
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}
