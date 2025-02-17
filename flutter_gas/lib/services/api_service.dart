import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000"; // Cambia si está en un servidor

  Future<List<dynamic>> fetchSensores({
    String? timestampInicio,
    String? timestampFin,
    int? cantidad,
    bool co2 = true,
    bool ch4 = true,
    bool temperatura = true,
    bool humedad = true,
  }) async {
    Uri url = Uri.parse("$baseUrl/sensores/filtrar").replace(
      queryParameters: {
        if (timestampInicio != null) "timestamp_inicio": timestampInicio,
        if (timestampFin != null) "timestamp_fin": timestampFin,
        if (cantidad != null) "cantidad": cantidad.toString(),
        "co2": co2.toString(),
        "ch4": ch4.toString(),
        "temperatura": temperatura.toString(),
        "humedad": humedad.toString(),
      },
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Devuelve la lista de sensores filtrados
    } else {
      throw Exception("Error al obtener datos filtrados");
    }
  }
}
