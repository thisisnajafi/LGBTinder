import '../models/models.dart';
import 'api_service.dart';

class SuperlikeService {
  final ApiService _apiService = ApiService();

  // Get available superlike packs
  Future<Map<String, dynamic>> getAvailablePacks() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/available');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load superlike packs: $e',
        'data': null,
      };
    }
  }

  // Purchase superlike pack
  Future<Map<String, dynamic>> purchasePack(int packId, String paymentMethod, {Map<String, dynamic>? paymentDetails}) async {
    try {
      final data = <String, dynamic>{
        'pack_id': packId,
        'payment_method': paymentMethod,
      };
      
      if (paymentDetails != null) {
        data.addAll(paymentDetails);
      }
      
      final response = await _apiService.post('/api/superlike-packs/purchase', data);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to purchase superlike pack: $e',
        'data': null,
      };
    }
  }

  // Get user's superlike packs
  Future<Map<String, dynamic>> getUserPacks() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/user-packs');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load user superlike packs: $e',
        'data': null,
      };
    }
  }

  // Get purchase history
  Future<Map<String, dynamic>> getPurchaseHistory() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/purchase-history');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load purchase history: $e',
        'data': null,
      };
    }
  }

  // Activate pending pack
  Future<Map<String, dynamic>> activatePendingPack(int packId) async {
    try {
      final response = await _apiService.post('/api/superlike-packs/activate-pending', {
        'pack_id': packId,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to activate pending pack: $e',
        'data': null,
      };
    }
  }

  // Get superlike usage statistics
  Future<Map<String, dynamic>> getUsageStatistics() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/usage-statistics');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load usage statistics: $e',
        'data': null,
      };
    }
  }

  // Get current superlike balance
  Future<Map<String, dynamic>> getCurrentBalance() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/current-balance');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load current balance: $e',
        'data': null,
      };
    }
  }

  // Use a superlike
  Future<Map<String, dynamic>> useSuperlike(int targetUserId) async {
    try {
      final response = await _apiService.post('/api/superlike-packs/use', {
        'target_user_id': targetUserId,
      });
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to use superlike: $e',
        'data': null,
      };
    }
  }

  // Get superlike usage history
  Future<Map<String, dynamic>> getUsageHistory() async {
    try {
      final response = await _apiService.get('/api/superlike-packs/usage-history');
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to load usage history: $e',
        'data': null,
      };
    }
  }

  // Parse superlike packs from API response
  List<SuperlikePack> parseSuperlikePacksFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return [];
    }

    final List<dynamic> packsData = response['data'] as List<dynamic>;
    return packsData.map((packData) => SuperlikePack.fromJson(packData as Map<String, dynamic>)).toList();
  }

  // Parse single superlike pack from API response
  SuperlikePack? parseSuperlikePackFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return null;
    }

    final packData = response['data'] as Map<String, dynamic>;
    return SuperlikePack.fromJson(packData);
  }

  // Parse purchase history from API response
  List<PurchaseHistory> parsePurchaseHistoryFromResponse(Map<String, dynamic> response) {
    if (response['success'] != true || response['data'] == null) {
      return [];
    }

    final List<dynamic> historyData = response['data'] as List<dynamic>;
    return historyData.map((historyItem) => PurchaseHistory.fromJson(historyItem as Map<String, dynamic>)).toList();
  }

  // Get best value pack from list
  SuperlikePack? getBestValuePack(List<SuperlikePack> packs) {
    if (packs.isEmpty) return null;
    
    SuperlikePack? bestValue;
    double bestPricePerSuperlike = double.infinity;
    
    for (final pack in packs) {
      if (pack.pricePerSuperlike < bestPricePerSuperlike) {
        bestPricePerSuperlike = pack.pricePerSuperlike;
        bestValue = pack;
      }
    }
    
    return bestValue;
  }

  // Get most popular pack from list
  SuperlikePack? getMostPopularPack(List<SuperlikePack> packs) {
    if (packs.isEmpty) return null;
    
    return packs.firstWhere(
      (pack) => pack.isMostPopular,
      orElse: () => packs.first,
    );
  }

  // Get packs grouped by size
  Map<String, List<SuperlikePack>> groupPacksBySize(List<SuperlikePack> packs) {
    final Map<String, List<SuperlikePack>> grouped = {};
    
    for (final pack in packs) {
      final size = pack.packSize;
      if (!grouped.containsKey(size)) {
        grouped[size] = [];
      }
      grouped[size]!.add(pack);
    }
    
    return grouped;
  }
}
