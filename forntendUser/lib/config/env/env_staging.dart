class EnvStaging {
  static const String baseUrl = 'https://staging-api.bnpl.com';
  static const String appName = 'BNPL Staging';
  static const bool isMock = false;
  
  // Additional staging-specific configurations
  static const int timeoutDuration = 25000; // 25 seconds
  static const bool enableLogging = true;
  static const String logLevel = 'INFO';
}
