import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service pour cache offline
class OfflineCache {
  static const String _hospitalsKey = 'cached_hospitals';
  static const String _timestampKey = 'cache_timestamp';
  static const Duration _cacheValidity = Duration(hours: 24);

  /// Sauvegarder les hôpitaux en cache
  Future<void> cacheHospitals(List<dynamic> hospitals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hospitalsKey, jsonEncode(hospitals));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Récupérer les hôpitaux en cache
  Future<List<dynamic>?> getCachedHospitals() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check cache validity
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return null;
    
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    if (now.difference(cacheDate) > _cacheValidity) {
      // Cache expired
      return null;
    }
    
    // Get cached data
    final hospitalsJson = prefs.getString(_hospitalsKey);
    if (hospitalsJson == null) return null;
    
    try {
      return jsonDecode(hospitalsJson) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Vider le cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hospitalsKey);
    await prefs.remove(_timestampKey);
  }

  /// Vérifier si cache valide
  Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return false;
    
    final cacheDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheDate) <= _cacheValidity;
  }
}
