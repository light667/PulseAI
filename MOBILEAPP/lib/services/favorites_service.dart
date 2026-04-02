import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service pour gérer les favoris hôpitaux
class FavoritesService {
  static const String _favoritesKey = 'hospital_favorites';

  /// Ajouter un hôpital aux favoris
  Future<void> addFavorite(Map<String, dynamic> hospital) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    // Avoid duplicates
    final hospitalId = hospital['id'].toString();
    favorites.removeWhere((h) => h['id'].toString() == hospitalId);
    
    favorites.insert(0, hospital);
    
    // Limit to 20 favorites
    if (favorites.length > 20) {
      favorites.removeLast();
    }
    
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  /// Retirer un hôpital des favoris
  Future<void> removeFavorite(String hospitalId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();
    
    favorites.removeWhere((h) => h['id'].toString() == hospitalId);
    
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  /// Vérifier si un hôpital est favori
  Future<bool> isFavorite(String hospitalId) async {
    final favorites = await getFavorites();
    return favorites.any((h) => h['id'].toString() == hospitalId);
  }

  /// Récupérer tous les favoris
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKey);
    
    if (favoritesJson == null) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = jsonDecode(favoritesJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Toggle favori
  Future<bool> toggleFavorite(Map<String, dynamic> hospital) async {
    final hospitalId = hospital['id'].toString();
    final isCurrentlyFavorite = await isFavorite(hospitalId);
    
    if (isCurrentlyFavorite) {
      await removeFavorite(hospitalId);
      return false;
    } else {
      await addFavorite(hospital);
      return true;
    }
  }
}
