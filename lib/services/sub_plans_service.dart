import '../models/models.dart';
import 'api_service.dart';

class SubPlansService {
  final ApiService _apiService = ApiService();

  // Get all subplans
  Future<Map<String, dynamic>> getSubPlans() async {
    try {
      final response = await _apiService.get('/api/sub-plans');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load subplans: $e',
        'data': null,
      };
    }
  }

  // Get subplans by duration
  Future<Map<String, dynamic>> getSubPlansByDuration(int durationDays) async {
    try {
      final response = await _apiService.get('/api/sub-plans/duration/$durationDays');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load subplans by duration: $e',
        'data': null,
      };
    }
  }

  // Get subplans for specific plan
  Future<Map<String, dynamic>> getSubPlansForPlan(int planId) async {
    try {
      final response = await _apiService.get('/api/sub-plans/plan/$planId');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load subplans for plan: $e',
        'data': null,
      };
    }
  }

  // Compare subplans
  Future<Map<String, dynamic>> compareSubPlans(List<int> subPlanIds) async {
    try {
      final response = await _apiService.post('/api/sub-plans/compare', {
        'sub_plan_ids': subPlanIds,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to compare subplans: $e',
        'data': null,
      };
    }
  }

  // Get upgrade options for current subscription
  Future<Map<String, dynamic>> getUpgradeOptions(int currentSubPlanId) async {
    try {
      final response = await _apiService.get('/api/sub-plans/upgrade-options/$currentSubPlanId');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load upgrade options: $e',
        'data': null,
      };
    }
  }

  // Upgrade subscription
  Future<Map<String, dynamic>> upgradeSubscription(int currentSubPlanId, int newSubPlanId) async {
    try {
      final response = await _apiService.post('/api/sub-plans/upgrade', {
        'current_sub_plan_id': currentSubPlanId,
        'new_sub_plan_id': newSubPlanId,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to upgrade subscription: $e',
        'data': null,
      };
    }
  }

  // Get recommended subplan for user
  Future<Map<String, dynamic>> getRecommendedSubPlan(int planId, {String? userType}) async {
    try {
      final data = <String, dynamic>{
        'plan_id': planId,
      };
      if (userType != null) {
        data['user_type'] = userType;
      }
      
      final response = await _apiService.post('/api/sub-plans/recommend', data);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to get recommended subplan: $e',
        'data': null,
      };
    }
  }

  // Parse subplans from API response
  List<SubPlan> parseSubPlansFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return [];
    }

    final List<dynamic> subPlansData = response['data'] as List<dynamic>;
    return subPlansData.map((subPlanData) => SubPlan.fromJson(subPlanData as Map<String, dynamic>)).toList();
  }

  // Parse single subplan from API response
  SubPlan? parseSubPlanFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return null;
    }

    final subPlanData = response['data'] as Map<String, dynamic>;
    return SubPlan.fromJson(subPlanData);
  }

  // Get subplans grouped by duration
  Map<String, List<SubPlan>> groupSubPlansByDuration(List<SubPlan> subPlans) {
    final Map<String, List<SubPlan>> grouped = {};
    
    for (final subPlan in subPlans) {
      final duration = subPlan.durationDisplay;
      if (!grouped.containsKey(duration)) {
        grouped[duration] = [];
      }
      grouped[duration]!.add(subPlan);
    }
    
    return grouped;
  }

  // Get best value subplan from list
  SubPlan? getBestValueSubPlan(List<SubPlan> subPlans) {
    if (subPlans.isEmpty) return null;
    
    SubPlan? bestValue;
    double bestMonthlyPrice = double.infinity;
    
    for (final subPlan in subPlans) {
      if (subPlan.monthlyPrice < bestMonthlyPrice) {
        bestMonthlyPrice = subPlan.monthlyPrice;
        bestValue = subPlan;
      }
    }
    
    return bestValue;
  }

  // Get most popular subplan from list
  SubPlan? getMostPopularSubPlan(List<SubPlan> subPlans) {
    if (subPlans.isEmpty) return null;
    
    return subPlans.firstWhere(
      (subPlan) => subPlan.isMostPopular,
      orElse: () => subPlans.first,
    );
  }
}
