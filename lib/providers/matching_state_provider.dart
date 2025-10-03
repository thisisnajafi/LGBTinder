import 'package:flutter/foundation.dart';
import '../models/api_models/matching_models.dart';
import '../models/api_models/auth_models.dart';
import '../models/user.dart';
import '../services/api_services/matching_api_service.dart';
import '../services/token_management_service.dart';
import '../services/rate_limiting_service.dart';
import '../models/user_state_models.dart';

class MatchingStateProvider extends ChangeNotifier {
  // State variables
  List<Match> _matches = [];
  List<User> _potentialMatches = [];
  bool _isLoading = false;
  bool _isLiking = false;
  AuthError? _error;
  String? _lastLikeError;
  int? _lastLikedUserId;

  // Getters
  List<Match> get matches => _matches;
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

      _matches = await MatchingApiService.getMatches(token);
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

      final request = LikeRequest(targetUserId: targetUserId);
      final response = await MatchingApiService.likeUser(request, token);

      if (response.status) {
        // If it's a match, refresh matches to get the new match
        if (response.data != null && response.data!['is_match'] == true) {
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
  Match? getMatchById(int matchId) {
    try {
      return _matches.firstWhere((match) => match.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  // Get match by user ID
  Match? getMatchByUserId(int userId) {
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
        details: 'Rate limit exceeded. Retry after ${error.retryAfter} seconds.',
      );
    } else {
      _error = AuthError(
        type: AuthErrorType.unknownError,
        message: 'An unexpected error occurred',
        details: error.toString(),
      );
    }
    notifyListeners();
  }

  // Load potential matches
  Future<void> loadPotentialMatches() async {
    try {
      _setLoading(true);
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('No token');
      
      // Mock potential matches for now
      _potentialMatches = [];
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
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('No token');
      
      // Mock super like for now - return true to indicate match
      _lastLikedUserId = userId;
      _setLiking(false);
      notifyListeners();
      return false; // Not a match for now
    } catch (e) {
      _setLiking(false);
      _handleError(e);
      return false;
    }
  }

  // Dislike a user
  Future<void> dislikeUser(int userId) async {
    try {
      _setLoading(true);
      final token = await TokenManagementService.getAccessToken();
      if (token == null) throw Exception('No token');
      
      // Mock dislike for now
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

  // Dispose method
  @override
  void dispose() {
    super.dispose();
  }
}
