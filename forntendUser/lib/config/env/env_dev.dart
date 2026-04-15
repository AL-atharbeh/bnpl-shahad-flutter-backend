class EnvDev {
  // Backend API URL Configuration
  // 
  // Choose the correct URL based on your platform:
  // 
  // 1. Android Emulator: 'http://10.0.2.2:3000/api/v1'
  //    - 10.0.2.2 is the special IP that Android Emulator uses to connect to host machine
  // 
  // 2. iOS Simulator: 'http://localhost:3000/api/v1'
  //    - iOS Simulator can access localhost directly
  // 
  // 3. Physical Device: 'http://YOUR_COMPUTER_IP:3000/api/v1'
  //    - Find your computer's IP: ifconfig (Mac/Linux) or ipconfig (Windows)
  //    - Example: 'http://192.168.1.100:3000/api/v1'
  //    - Make sure your device and computer are on the same network
  // 
  // To find your IP address:
  // - Mac/Linux: run 'ifconfig | grep "inet " | grep -v 127.0.0.1'
  // - Windows: run 'ipconfig' and look for IPv4 Address
  
  // Auto-detect platform and use appropriate URL
  // For iOS Simulator: use 'http://localhost:3000/api/v1'
  // For Android Emulator: use 'http://10.0.2.2:3000/api/v1'
  // For Physical Device: use your computer's IP address
  // Current IP: 172.20.10.2 (update if changed)
  
  // Default: iOS Simulator (localhost)
  static const String baseUrl = 'https://enthusiastic-stillness-production-5dce.up.railway.app/api/v1';
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; // Android Emulator
  
  // Alternative URLs (uncomment the one you need):
  // static const String baseUrl = 'http://172.20.10.2:3000/api/v1'; // Physical Device (current IP)
  // static const String baseUrl = 'http://localhost:3000/api/v1'; // iOS Simulator
   
  static const String appName = 'BNPL Dev';
  static const bool isMock = false;
  
  // Additional development-specific configurations
  static const int timeoutDuration = 30000; // 30 seconds
  static const bool enableLogging = true;
  static const String logLevel = 'DEBUG';
  
  static const String stripePublishableKey = 'pk_test_51THL3qGnJab9pZ97eIkQrwbZi0cTOhIlD8IJFUOzYg8wHcVcfsys8mVmoYlEHDO2GzRQDk9eEBy5T5jDe8NQIDlc00CsDA7uTg';
}
