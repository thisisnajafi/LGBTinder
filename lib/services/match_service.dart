import 'api_service.dart';

class MatchService {
  final ApiService _apiService = ApiService();

  // Get potential matches
  Future<Map<String, dynamic>> getPotentialMatches({
    int? page,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();
    
    if (filters != null) {
      filters.forEach((key, value) {
        if (value != null) queryParams[key] = value.toString();
      });
    }

    return await _apiService.getData('/matches/potential', queryParameters: queryParams);
  }

  // Like a user
  Future<Map<String, dynamic>> likeUser(String userId) async {
    return await _apiService.postData('/matches/like', {
      'user_id': userId,
    });
  }

  // Super like a user
  Future<Map<String, dynamic>> superLikeUser(String userId) async {
    return await _apiService.postData('/matches/super-like', {
      'user_id': userId,
    });
  }

  // Pass (skip) a user
  Future<Map<String, dynamic>> passUser(String userId) async {
    return await _apiService.postData('/matches/pass', {
      'user_id': userId,
    });
  }

  // Get matches (mutual likes)
  Future<Map<String, dynamic>> getMatches({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/matches', queryParameters: queryParams);
  }

  // Get match by ID
  Future<Map<String, dynamic>> getMatchById(String matchId) async {
    return await _apiService.getData('/matches/$matchId');
  }

  // Delete match
  Future<Map<String, dynamic>> deleteMatch(String matchId) async {
    return await _apiService.deleteData('/matches/$matchId');
  }

  // Get match statistics
  Future<Map<String, dynamic>> getMatchStats() async {
    return await _apiService.getData('/matches/stats');
  }

  // Get recent activity
  Future<Map<String, dynamic>> getRecentActivity({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/matches/activity', queryParameters: queryParams);
  }

  // Get likes received
  Future<Map<String, dynamic>> getLikesReceived({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/matches/likes-received', queryParameters: queryParams);
  }

  // Get likes sent
  Future<Map<String, dynamic>> getLikesSent({
    int? page,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (page != null) queryParams['page'] = page.toString();
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/matches/likes-sent', queryParameters: queryParams);
  }

  // Check if there's a match with a user
  Future<Map<String, dynamic>> checkMatch(String userId) async {
    return await _apiService.getData('/matches/check/$userId');
  }

  // Get match suggestions
  Future<Map<String, dynamic>> getMatchSuggestions({
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    
    if (limit != null) queryParams['limit'] = limit.toString();

    return await _apiService.getData('/matches/suggestions', queryParameters: queryParams);
  }

  // Report a match
  Future<Map<String, dynamic>> reportMatch(String matchId, String reason) async {
    return await _apiService.postData('/matches/$matchId/report', {
      'reason': reason,
    });
  }

  // Unmatch a user
  Future<Map<String, dynamic>> unmatchUser(String matchId) async {
    return await _apiService.deleteData('/matches/$matchId');
  }

  // Get match preferences
  Future<Map<String, dynamic>> getMatchPreferences() async {
    return await _apiService.getData('/matches/preferences');
  }

  // Update match preferences
  Future<Map<String, dynamic>> updateMatchPreferences(Map<String, dynamic> preferences) async {
    return await _apiService.updateData('/matches/preferences', preferences);
  }
} 