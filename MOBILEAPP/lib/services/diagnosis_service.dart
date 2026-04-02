import 'package:pulseai/services/api_service.dart';

class DiagnosisService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> diagnose({
    required List<String> symptoms,
    int? age,
    String? gender,
  }) async {
    return await _apiService.diagnose(symptoms);
  }
}
