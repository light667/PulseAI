import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// Service HTTP centralisé pour toutes les requêtes API
class ApiService {
  // Backend unifié PulseAI (chatbot + diagnostic)
  static String get backendApiUrl => kReleaseMode
      ? ApiConfig.backendBase
      : ApiConfig.devBackend;

  final Dio _dio;

  ApiService({String? baseUrl}) 
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? (kReleaseMode ? ApiConfig.backendBase : ApiConfig.devBackend),
          connectTimeout: const Duration(seconds: 30), // Increased timeout for AI
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        )) {
    final effectiveBaseUrl = baseUrl ?? backendApiUrl;
    
    if (kDebugMode) {
      print('🔧 ApiService initializing with baseUrl: $effectiveBaseUrl');
      print('🔧 kReleaseMode: $kReleaseMode');
      
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  /// GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // --- Specific Methods ---

  // AI Services (Lyra & Rural Diag)
  Future<List<String>> getSymptoms() async {
    try {
      // Utilise le backend Diagnostic
      final dioDiag = Dio(BaseOptions(
        baseUrl: ApiConfig.diagnosticBase,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final response = await dioDiag.get('/symptoms');
      return List<String>.from(response.data['symptoms']);
    } catch (e) {
      if (kDebugMode) print('Error fetching symptoms: $e');
      return [];
    }
  }

  /// Common symptoms ranked by frequency (from rag_clean.csv via backend)
  Future<List<Map<String, dynamic>>> getCommonSymptoms({int limit = 50}) async {
    try {
      final dioDiag = Dio(BaseOptions(
        baseUrl: ApiConfig.diagnosticBase,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      final response = await dioDiag.get('/api/v1/diagnostic/common-symptoms', queryParameters: {'limit': limit});
      return List<Map<String, dynamic>>.from(response.data['common'] ?? []);
    } catch (e) {
      if (kDebugMode) print('Error fetching common symptoms: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> diagnose(List<String> symptoms) async {
    try {
      if (kDebugMode) {
        print('🔧 Diagnose - Backend URL: ${ApiConfig.diagnosticBase}');
        print('🔧 Diagnose - Symptoms: $symptoms');
      }
      
      // Utilise le backend unifié
      final dioDiag = Dio(BaseOptions(
        baseUrl: ApiConfig.diagnosticBase,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));
      
      final response = await dioDiag.post('/diagnostic', data: {
        'symptoms': symptoms,
        'use_ai': true
      });
      
      if (kDebugMode) {
        print('✅ Diagnose response: ${response.statusCode}');
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in diagnose: $e');
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> chat(String message, List<Map<String, String>> history) async {
    // Utilise le backend Lyra chatbot
    final dioLyra = Dio(BaseOptions(
      baseUrl: ApiConfig.lyraBase,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    final response = await dioLyra.post('/chat', data: {
      'message': message,
      'history': history,
    });
    return response.data;
  }

  // Hospital Services (SmartHosp)
  Future<List<dynamic>> searchHospitals({
    required double latitude,
    required double longitude,
    String service = 'Tout',
    double maxDistanceKm = 50.0,
  }) async {
    print('🌐 API: searchHospitals appelé');
    print('📍 Params: lat=$latitude, lon=$longitude, service=$service, rayon=$maxDistanceKm');
    
    final response = await get('/hospitals/search', queryParameters: {
      'latitude': latitude,
      'longitude': longitude,
      'service': service == 'Tout' ? null : service,
      'rayon_km': maxDistanceKm,
    });
    
    print('📡 Response status: ${response.statusCode}');
    print('📦 Response data type: ${response.data.runtimeType}');
    print("📦 Response keys: ${response.data is Map ? (response.data as Map).keys : 'N/A'}");
    
    final hospitals = response.data['hospitals'];
    print('🏥 Hospitals count: ${hospitals?.length ?? 0}');
    
    return hospitals;
  }
  
  Future<Map<String, dynamic>> getHospitalDetails(dynamic hospitalId) async {
    final response = await get('/hospitals/$hospitalId');
    return response.data;
  }
  
  Future<Map<String, dynamic>> rateHospital(dynamic hospitalId, int rating, {String? comment, String? userId}) async {
    final uid = userId ?? 'anonymous';
    final response = await post(
      '/hospitals/$hospitalId/reviews?user_id=$uid', 
      {
        'note': rating,
        'commentaire': comment ?? '',
        'service_utilise': 'Général'
      }
    );
    return response.data;
  }

  // Legacy endpoints for backward compatibility
  Future<List<dynamic>> getHospitals(double lat, double lon, String service) async {
    return searchHospitals(latitude: lat, longitude: lon, service: service);
  }

  /// Gestion centralisée des erreurs
  String _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return 'Requête invalide';
        } else if (statusCode == 401) {
          return 'Non autorisé';
        } else if (statusCode == 404) {
          return 'Service non trouvé';
        } else if (statusCode == 500) {
          return 'Erreur serveur';
        }
        return 'Erreur réseau ($statusCode)';
      
      case DioExceptionType.cancel:
        return 'Requête annulée';
      
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur. Vérifiez que l\'API est démarrée.';
      
      default:
        return 'Erreur de connexion: ${e.message}';
    }
  }

  /// Vérifier la santé de l'API
  Future<bool> checkHealth() async {
    try {
      final response = await get('/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
