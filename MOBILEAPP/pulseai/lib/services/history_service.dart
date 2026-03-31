import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static const String _diagnosisHistoryKey = 'diagnosis_history';
  static const String _chatHistoryKey = 'chat_history';

  // Diagnostic History
  Future<void> saveDiagnosis({
    required String symptoms,
    required Map<String, dynamic> results,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDiagnosisHistory();
    
    final diagnosis = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'symptoms': symptoms,
      'diagnosis': results['diagnosis'] ?? '',
      'recommendations': results['recommendations'] ?? '',
      'severity': results['severity'] ?? 'normal',
    };
    
    history.insert(0, diagnosis); // Add to beginning
    
    // Keep only last 50 diagnoses
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setString(_diagnosisHistoryKey, json.encode(history));
    
    // Update count
    await prefs.setInt('diagnostic_count', history.length);
  }

  Future<List<Map<String, dynamic>>> getDiagnosisHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_diagnosisHistoryKey);
    
    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading diagnosis history: $e');
      return [];
    }
  }

  Future<void> deleteDiagnosis(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getDiagnosisHistory();
    
    history.removeWhere((d) => d['id'] == id);
    
    await prefs.setString(_diagnosisHistoryKey, json.encode(history));
    await prefs.setInt('diagnostic_count', history.length);
  }

  // Chat History
  Future<void> saveChatSession({
    required List<Map<String, dynamic>> messages,
  }) async {
    if (messages.length <= 1) return; // Don't save if only welcome message
    
    final prefs = await SharedPreferences.getInstance();
    final history = await getChatHistory();
    
    final session = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'date': DateTime.now().toIso8601String(),
      'messages': messages,
      'messageCount': messages.length,
    };
    
    history.insert(0, session);
    
    // Keep only last 30 sessions
    if (history.length > 30) {
      history.removeRange(30, history.length);
    }
    
    await prefs.setString(_chatHistoryKey, json.encode(history));
    await prefs.setInt('session_count', history.length);
  }

  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString(_chatHistoryKey);
    
    if (historyJson == null || historyJson.isEmpty) {
      return [];
    }
    
    try {
      final List<dynamic> decoded = json.decode(historyJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }

  Future<void> deleteChatSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getChatHistory();
    
    history.removeWhere((s) => s['id'] == id);
    
    await prefs.setString(_chatHistoryKey, json.encode(history));
    await prefs.setInt('session_count', history.length);
  }

  // Clear all history
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_diagnosisHistoryKey);
    await prefs.remove(_chatHistoryKey);
    await prefs.setInt('diagnostic_count', 0);
    await prefs.setInt('session_count', 0);
  }
}
