class ApiConfig {
  // Use localhost alias for Android Emulator
  // Use localhost for local dev on Linux/Web/Desktop
  static const String backendBase = 'http://localhost:8000/api/v1'; 
  
  static const String diagnosticBase = backendBase;
  static const String lyraBase = '$backendBase/bot';
  static const String localeBase = '$backendBase/locale';

  // Dev fallbacks for emulators and local testing
  static const String devBackend = 'http://localhost:8000';
  static const String devBackendV1 = 'http://localhost:8000/api/v1';

  static String normalizeV1(String base) {
    return base;
  }
}
