import 'package:pulseai/services/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ChatResponse {
  final String response;
  final double confidence;
  final List<String> sources;
  final String timestamp;

  ChatResponse({
    required this.response,
    required this.confidence,
    required this.sources,
    required this.timestamp,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['reply'] as String,
      confidence: 0.95,
      sources: ['Mistral RAG', 'Medical PDF'],
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}

class ChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.lyraBase,
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<ChatResponse> sendMessage({
    required String message,
    String? userId,
    String language = 'en',
  }) async {
    try {
      final response = await _dio.post('/chat', data: {
        'messages': [
          {'role': 'user', 'content': message}
        ],
        'user_id': userId,
        'language': language,
      });
      return ChatResponse.fromJson(response.data);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return _getMockResponse(message);
    }
  }

  Future<bool> isApiAvailable() async {
    try {
      final dioPing = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));
      final res = await dioPing.get('/');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  ChatResponse _getMockResponse(String userMessage) {
    return ChatResponse(
      response: "⚠️ The Lyra Medical AI Backend is currently unreachable. Please ensure the Python FastAPI server is running on port 8000.",
      confidence: 0.0,
      sources: ['Mock Fallback'],
      timestamp: DateTime.now().toIso8601String(),
    );
  }
}
