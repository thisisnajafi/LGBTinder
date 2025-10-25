import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_services/reference_data_api_service.dart';
import '../../models/api_models/reference_data_models.dart';

/// Cache service for reference data to reduce API calls and improve performance
class ReferenceDataCache {
  static const String _cacheVersion = '1.0';
  static const String _cacheExpiryKey = 'cache_expiry';
  static const String _countriesKey = 'countries';
  static const String _citiesKey = 'cities';
  static const String _referenceDataKey = 'reference_data';
  
  static const Duration _cacheExpiryDuration = Duration(hours: 24);
  
  /// Check if cache is valid
  static Future<bool> isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryMillis = prefs.getInt(_cacheExpiryKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      return now < expiryMillis;
    } catch (e) {
      return false;
    }
  }
  
  /// Get cached countries
  static Future<List<Country>> getCachedCountries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final countriesJson = prefs.getString(_countriesKey);
      
      if (countriesJson != null) {
        final List<dynamic> countriesList = jsonDecode(countriesJson);
        return countriesList.map((json) => Country.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading cached countries: $e');
      return [];
    }
  }
  
  /// Cache countries
  static Future<void> cacheCountries(List<Country> countries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final countriesJson = jsonEncode(countries.map((c) => c.toJson()).toList());
      
      await prefs.setString(_countriesKey, countriesJson);
      await _updateCacheExpiry();
    } catch (e) {
      print('Error caching countries: $e');
    }
  }
  
  /// Get cached cities for a country
  static Future<List<City>> getCachedCities(int countryId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citiesKey = '${_citiesKey}_$countryId';
      final citiesJson = prefs.getString(citiesKey);
      
      if (citiesJson != null) {
        final List<dynamic> citiesList = jsonDecode(citiesJson);
        return citiesList.map((json) => City.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading cached cities: $e');
      return [];
    }
  }
  
  /// Cache cities for a country
  static Future<void> cacheCities(int countryId, List<City> cities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final citiesKey = '${_citiesKey}_$countryId';
      final citiesJson = jsonEncode(cities.map((c) => c.toJson()).toList());
      
      await prefs.setString(citiesKey, citiesJson);
    } catch (e) {
      print('Error caching cities: $e');
    }
  }
  
  /// Get cached reference data
  static Future<Map<String, List<ReferenceDataItem>>> getCachedReferenceData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final referenceDataJson = prefs.getString(_referenceDataKey);
      
      if (referenceDataJson != null) {
        final Map<String, dynamic> dataMap = jsonDecode(referenceDataJson);
        return Map<String, List<ReferenceDataItem>>.from(
          dataMap.map((key, value) => MapEntry(
            key,
            (value as List).map((item) => ReferenceDataItem.fromJson(item)).toList()
          ))
        );
      }
      
      return {};
    } catch (e) {
      print('Error loading cached reference data: $e');
      return {};
    }
  }
  
  /// Cache reference data
  static Future<void> cacheReferenceData(Map<String, List<ReferenceDataItem>> referenceData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final referenceDataJson = jsonEncode(
        referenceData.map((key, value) => MapEntry(
          key,
          value.map((item) => item.toJson()).toList()
        ))
      );
      
      await prefs.setString(_referenceDataKey, referenceDataJson);
      await _updateCacheExpiry();
    } catch (e) {
      print('Error caching reference data: $e');
    }
  }
  
  /// Update cache expiry time
  static Future<void> _updateCacheExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(_cacheExpiryDuration).millisecondsSinceEpoch;
    await prefs.setInt(_cacheExpiryKey, expiryTime);
  }
  
  /// Clear all cached data
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheExpiryKey);
      await prefs.remove(_countriesKey);
      await prefs.remove(_referenceDataKey);
      
      // Clear cities cache
      final keys = prefs.getKeys().where((key) => key.startsWith(_citiesKey));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  /// Load reference data with caching
  static Future<List<Country>> loadCountriesWithCache() async {
    if (await isCacheValid()) {
      final cachedCountries = await getCachedCountries();
      if (cachedCountries.isNotEmpty) {
        return cachedCountries;
      }
    }
    
    // If no valid cache, fetch from API
    try {
      final response = await ReferenceDataApiService.getCountries();
      final countries = response.map((data) => Country.fromJson(data)).toList();
      await cacheCountries(countries);
      return countries;
    } catch (e) {
      // Return cached data even if expired, as fallback
      return await getCachedCountries();
    }
  }
  
  /// Load reference data with caching
  static Future<Map<String, List<ReferenceDataItem>>> loadReferenceDataWithCache() async {
    if (await isCacheValid()) {
      final cachedData = await getCachedReferenceData();
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
    }
    
    // If no valid cache, fetch from API
    try {
      // Note: ReferenceDataApiService.getAllReferenceData() returns Map<String, dynamic>
      // with Response objects, not List<ReferenceDataItem>. We need to extract the data.
      final dynamic responseData = await ReferenceDataApiService.loadAllReferenceData();
      
      // Convert the API response to our expected format
      final Map<String, List<ReferenceDataItem>> convertedData = {};
      
      // Extract data from each response object
      if (responseData is Map<String, dynamic>) {
        // For each response, extract the data field if it exists
        responseData.forEach((key, response) {
          if (response is Map<String, dynamic> && response.containsKey('data')) {
            final dynamic data = response['data'];
            if (data is List) {
              try {
                convertedData[key] = data.map((item) => ReferenceDataItem.fromJson(item as Map<String, dynamic>)).toList();
              } catch (e) {
                print('Error converting $key data: $e');
                convertedData[key] = [];
              }
            } else {
              convertedData[key] = [];
            }
          } else {
            convertedData[key] = [];
          }
        });
      }
      
      await cacheReferenceData(convertedData);
      return convertedData;
    } catch (e) {
      // Return cached data even if expired, as fallback
      return await getCachedReferenceData();
    }
  }
  
  /// Load cities with caching
  static Future<List<City>> loadCitiesWithCache(int countryId) async {
    if (await isCacheValid()) {
      final cachedCities = await getCachedCities(countryId);
      if (cachedCities.isNotEmpty) {
        return cachedCities;
      }
    }
    
    // If no valid cache, fetch from API
    try {
      final response = await ReferenceDataApiService.getCitiesByCountry(countryId.toString());
      final cities = response.map((data) => City.fromJson(data)).toList();
      await cacheCities(countryId, cities);
      return cities;
    } catch (e) {
      // Return cached data even if expired, as fallback
      return await getCachedCities(countryId);
    }
  }
}
