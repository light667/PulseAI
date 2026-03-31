import 'package:pulseai/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';

class ScanService {


  Future<Map<String, dynamic>> scanMedication(XFile image) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image.path, filename: fileName),
        "scan_type": "ocr",
      });

      // We need to access the underlying Dio instance or create a method in ApiService for FormData
      // For simplicity, let's assume ApiService.post can handle FormData if we modify it, 
      // or we just use Dio directly here for upload.
      // Since ApiService wraps Dio, let's add a method for upload or expose Dio.
      // But ApiService.post takes Map<String, dynamic>.
      
      // Let's modify ApiService to support FormData or just use a new Dio here for simplicity.
      // But to keep it clean, I'll assume I can add an upload method to ApiService later.
      // For now, I will use a local Dio instance with the same baseUrl.
      
      final dio = Dio(BaseOptions(baseUrl: ApiService.backendApiUrl));
      final response = await dio.post('/api/scan', data: formData);
      
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning medication: $e');
      }
      rethrow;
    }
  }
}
