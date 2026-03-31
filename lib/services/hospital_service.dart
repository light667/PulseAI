import 'package:pulseai/services/api_service.dart';

class HospitalService {
  final ApiService _apiService = ApiService();

  /// Search for nearby hospitals with optional service filter
  Future<List<dynamic>> findHospitals({
    required double latitude,
    required double longitude,
    String service = "Tout",
    double maxDistanceKm = 50.0,
  }) async {
    return await _apiService.searchHospitals(
      latitude: latitude,
      longitude: longitude,
      service: service,
      maxDistanceKm: maxDistanceKm,
    );
  }

  /// Get detailed information about a specific hospital
  Future<Map<String, dynamic>> getHospitalDetails(int hospitalId) async {
    return await _apiService.getHospitalDetails(hospitalId);
  }

  /// Submit a rating for a hospital
  Future<Map<String, dynamic>> rateHospital({
    required dynamic hospitalId,
    required int rating,
    String? comment,
    String? userId,
  }) async {
    return await _apiService.rateHospital(
      hospitalId,
      rating,
      comment: comment,
      userId: userId,
    );
  }
}
