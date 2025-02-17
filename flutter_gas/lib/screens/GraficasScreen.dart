import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class GraficasScreen extends StatelessWidget {
  final List<dynamic> datos;

  GraficasScreen({required this.datos});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView( // ✅ Permite scroll en caso de overflow
        child: Column(
          children: [
            if (_tieneDatos(["CO2", "CH4"])) _buildGrafica(datos, ["CO2", "CH4"], "CO₂ y CH₄ (ppm)"),
            if (_tieneDatos(["temperature"])) _buildGrafica(datos, ["temperature"], "Temperatura (°C)"),
            if (_tieneDatos(["humidity"])) _buildGrafica(datos, ["humidity"], "Humedad (%)"),
          ],
        ),
      ),
    );
  }

  bool _tieneDatos(List<String> keys) {
    return datos.any((d) => keys.any((key) => d.containsKey(key)));
  }

  Widget _buildGrafica(List<dynamic> datos, List<String> keys, String titulo) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SizedBox(
                height: 250, // ✅ Aumentar altura para evitar overflow
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: false),
                    lineBarsData: keys.map((key) {
                      return LineChartBarData(
                        spots: _generarPuntos(datos, key),
                        isCurved: true,
                        color: _colorPorKey(key),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(show: false),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generarPuntos(List<dynamic> datos, String key) {
  return datos
      .where((d) => d.containsKey(key) && d[key] != null) // ✅ Filtrar datos nulos
      .toList()
      .asMap()
      .entries
      .map((entry) => FlSpot(
            entry.key.toDouble(),
            (entry.value[key] as num?)?.toDouble() ?? 0.0, // ✅ Si es null, asignar 0.0
          ))
      .toList();
}


  Color _colorPorKey(String key) {
    switch (key) {
      case "CO2":
        return Colors.blue;
      case "CH4":
        return Colors.green;
      case "temperature":
        return Colors.orange;
      case "humidity":
        return Colors.purple;
      default:
        return Colors.black;
    }
  }
}
