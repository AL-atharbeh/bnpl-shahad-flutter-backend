class EnvProd {
  static const String baseUrl = 'https://api.bnpl.com';
  static const String appName = 'BNPL';
  static const bool isMock = false;
  
  // Additional production-specific configurations
  static const int timeoutDuration = 20000; // 20 seconds
  static const bool enableLogging = false;
  static const String logLevel = 'ERROR';
}
