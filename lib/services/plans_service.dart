import '../models/models.dart';
import 'api_service.dart';

class PlansService {
  final ApiService _apiService = ApiService();

  // Get all available plans
  Future<Map<String, dynamic>> getPlans() async {
    try {
      final response = await _apiService.get('/api/plans');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load plans: $e',
        'data': null,
      };
    }
  }

  // Get plan by ID
  Future<Map<String, dynamic>> getPlanById(int planId) async {
    try {
      final response = await _apiService.get('/api/plans/$planId');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load plan: $e',
        'data': null,
      };
    }
  }

  // Compare plans
  Future<Map<String, dynamic>> comparePlans(List<int> planIds) async {
    try {
      final response = await _apiService.post('/api/plans/compare', {
        'plan_ids': planIds,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to compare plans: $e',
        'data': null,
      };
    }
  }

  // Get plan features
  Future<Map<String, dynamic>> getPlanFeatures(int planId) async {
    try {
      final response = await _apiService.get('/api/plans/$planId/features');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load plan features: $e',
        'data': null,
      };
    }
  }

  // Parse plans from API response
  List<Plan> parsePlansFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return [];
    }

    final List<dynamic> plansData = response['data'] as List<dynamic>;
    return plansData.map((planData) => Plan.fromJson(planData as Map<String, dynamic>)).toList();
  }

  // Parse single plan from API response
  Plan? parsePlanFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return null;
    }

    final planData = response['data'] as Map<String, dynamic>;
    return Plan.fromJson(planData);
  }

  // Parse plan features from API response
  PlanFeatures? parsePlanFeaturesFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return null;
    }

    final featuresData = response['data'] as Map<String, dynamic>;
    return PlanFeatures.fromJson(featuresData);
  }
}
