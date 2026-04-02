import 'package:pulseai/services/api_config.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class LocalizationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.localeBase,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 45),
  ));

  Future<Map<String, String>?> getContextualTranslations(String targetLanguage, Map<String, String> defaultTexts) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'translations_$targetLanguage';
    
    // Check Cache first to prevent unnecessary mistral API calls
    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      try {
        final decoded = jsonDecode(cached) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      } catch (_) {}
    }

    // Not in cache, fetch from FastAPI Mistral implementation
    try {
      final response = await _dio.post('/translate', data: {
        'target_language': targetLanguage,
        'texts': defaultTexts,
      });
      
      final translations = Map<String, String>.from(response.data['translations']);
      
      // Save to Cache for future fast loading
      prefs.setString(cacheKey, jsonEncode(translations));
      
      return translations;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching dynamic translations: $e');
      }
      return null;
    }
  }
  
  Future<void> clearCache(String targetLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('translations_$targetLanguage');
  }
}
