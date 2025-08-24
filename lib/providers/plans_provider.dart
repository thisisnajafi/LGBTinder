import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/plans_service.dart';

class PlansProvider extends ChangeNotifier {
  final PlansService _plansService = PlansService();

  // Plans data
  List<Plan> _plans = [];
  List<Plan> get plans => _plans;

  // Current selected plan
  Plan? _selectedPlan;
  Plan? get selectedPlan => _selectedPlan;

  // Loading states
  bool _isLoadingPlans = false;
  bool _isLoadingPlanDetails = false;
  bool _isComparingPlans = false;

  bool get isLoadingPlans => _isLoadingPlans;
  bool get isLoadingPlanDetails => _isLoadingPlanDetails;
  bool get isComparingPlans => _isComparingPlans;

  // Error states
  String? _plansError;
  String? _planDetailsError;
  String? _comparisonError;

  String? get plansError => _plansError;
  String? get planDetailsError => _planDetailsError;
  String? get comparisonError => _comparisonError;

  // Plan comparison data
  List<Plan> _comparisonPlans = [];
  List<Plan> get comparisonPlans => _comparisonPlans;

  // Initialize the provider
  Future<void> initialize() async {
    await loadPlans();
  }

  // Load all plans
  Future<void> loadPlans() async {
    _setLoadingPlans(true);
    _clearPlansError();

    try {
      final response = await _plansService.getPlans();
      if (response['success']) {
        _plans = _plansService.parsePlansFromResponse(response);
        notifyListeners();
      } else {
        _setPlansError(response['message'] ?? 'Failed to load plans');
      }
    } catch (e) {
      _setPlansError('Error loading plans: $e');
    } finally {
      _setLoadingPlans(false);
    }
  }

  // Load plan details
  Future<void> loadPlanDetails(int planId) async {
    _setLoadingPlanDetails(true);
    _clearPlanDetailsError();

    try {
      final response = await _plansService.getPlanById(planId);
      if (response['success']) {
        final plan = _plansService.parsePlanFromResponse(response);
        if (plan != null) {
          _selectedPlan = plan;
          notifyListeners();
        } else {
          _setPlanDetailsError('Plan not found');
        }
      } else {
        _setPlanDetailsError(response['message'] ?? 'Failed to load plan details');
      }
    } catch (e) {
      _setPlanDetailsError('Error loading plan details: $e');
    } finally {
      _setLoadingPlanDetails(false);
    }
  }

  // Compare plans
  Future<void> comparePlans(List<int> planIds) async {
    _setComparingPlans(true);
    _clearComparisonError();

    try {
      final response = await _plansService.comparePlans(planIds);
      if (response['success']) {
        _comparisonPlans = _plansService.parsePlansFromResponse(response);
        notifyListeners();
      } else {
        _setComparisonError(response['message'] ?? 'Failed to compare plans');
      }
    } catch (e) {
      _setComparisonError('Error comparing plans: $e');
    } finally {
      _setComparingPlans(false);
    }
  }

  // Select a plan
  void selectPlan(Plan plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  // Clear selected plan
  void clearSelectedPlan() {
    _selectedPlan = null;
    notifyListeners();
  }

  // Get plan by ID
  Plan? getPlanById(int planId) {
    try {
      return _plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  // Get plan by title
  Plan? getPlanByTitle(String title) {
    try {
      return _plans.firstWhere((plan) => plan.title.toLowerCase() == title.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Get free plan
  Plan? get freePlan => _plans.firstWhere(
    (plan) => plan.title.toLowerCase() == 'free',
    orElse: () => _plans.first,
  );

  // Get bronze plan
  Plan? get bronzePlan => _plans.firstWhere(
    (plan) => plan.title.toLowerCase() == 'bronze',
    orElse: () => _plans.first,
  );

  // Get silver plan
  Plan? get silverPlan => _plans.firstWhere(
    (plan) => plan.title.toLowerCase() == 'silver',
    orElse: () => _plans.first,
  );

  // Get gold plan
  Plan? get goldPlan => _plans.firstWhere(
    (plan) => plan.title.toLowerCase() == 'gold',
    orElse: () => _plans.first,
  );

  // Get premium plans (excluding free)
  List<Plan> get premiumPlans => _plans.where((plan) => plan.title.toLowerCase() != 'free').toList();

  // Get recommended plan based on user preferences
  Plan? getRecommendedPlan({String? userType, int? budget}) {
    if (_plans.isEmpty) return null;

    // Default recommendation logic
    if (userType == 'casual') {
      return bronzePlan ?? _plans.first;
    } else if (userType == 'active') {
      return silverPlan ?? _plans.first;
    } else if (userType == 'premium') {
      return goldPlan ?? _plans.first;
    }

    // Budget-based recommendation
    if (budget != null) {
      if (budget >= 30) {
        return goldPlan ?? silverPlan ?? _plans.first;
      } else if (budget >= 20) {
        return silverPlan ?? bronzePlan ?? _plans.first;
      } else if (budget >= 10) {
        return bronzePlan ?? _plans.first;
      }
    }

    // Default to silver plan
    return silverPlan ?? bronzePlan ?? _plans.first;
  }

  // Loading state setters
  void _setLoadingPlans(bool loading) {
    _isLoadingPlans = loading;
    notifyListeners();
  }

  void _setLoadingPlanDetails(bool loading) {
    _isLoadingPlanDetails = loading;
    notifyListeners();
  }

  void _setComparingPlans(bool comparing) {
    _isComparingPlans = comparing;
    notifyListeners();
  }

  // Error state setters
  void _setPlansError(String error) {
    _plansError = error;
    notifyListeners();
  }

  void _setPlanDetailsError(String error) {
    _planDetailsError = error;
    notifyListeners();
  }

  void _setComparisonError(String error) {
    _comparisonError = error;
    notifyListeners();
  }

  // Clear error states
  void _clearPlansError() {
    _plansError = null;
    notifyListeners();
  }

  void _clearPlanDetailsError() {
    _planDetailsError = null;
    notifyListeners();
  }

  void _clearComparisonError() {
    _comparisonError = null;
    notifyListeners();
  }

  // Clear all errors
  void clearAllErrors() {
    _clearPlansError();
    _clearPlanDetailsError();
    _clearComparisonError();
  }

  // Refresh all data
  Future<void> refresh() async {
    await loadPlans();
  }
}
