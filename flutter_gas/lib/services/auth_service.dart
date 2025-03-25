import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  final _prefs = SharedPreferences.getInstance();

  // Iniciar sesión
  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.login),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
      // Guardar el token
      final prefs = await _prefs;
      await prefs.setString(_tokenKey, loginResponse.accessToken);
      return loginResponse;
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  // Registrar usuario
  Future<UserProfile> register(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al registrar usuario: ${response.body}');
    }
  }

  // Obtener perfil del usuario
  Future<UserProfile> getProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.profile),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener perfil: ${response.body}');
    }
  }

  // Obtener token guardado
  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(_tokenKey);
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
  }

  // Verificar si hay sesión activa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
} 