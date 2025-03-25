class ApiConstants {
  // Para emulador Android usar: 'http://10.0.2.2:8000'
  // Para dispositivo físico usar: 'http://TU_IP_LOCAL:8000'
  // Para web o iOS simulator usar: 'http://localhost:8000'
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/v1';
  static const String wsPrefix = '/ws';
  
  // Endpoints de autenticación
  static const String login = '$apiPrefix/users/login';
  static const String register = '$apiPrefix/users/register';
  static const String profile = '$apiPrefix/users/me';
  
  // Endpoints de dispositivos
  static const String devices = '$apiPrefix/devices';
  static const String userDevices = '$apiPrefix/users/me/devices';
  
  // Endpoints de sensores
  static const String sensors = '$apiPrefix/sensors';
  
  // WebSocket
  static String deviceWebSocket(String deviceId) => '$wsPrefix/$deviceId';
} 