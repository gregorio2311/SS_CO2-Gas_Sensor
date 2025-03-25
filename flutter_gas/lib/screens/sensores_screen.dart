import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';  // Importar Timer
import '../services/api_service.dart';
import 'graficas_screen.dart';


class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  final ApiService apiService = ApiService();
  late Future<List<dynamic>> sensores;
  Timer? _timer;  // Declarar Timer
  
  String? timestampInicio;
  String? timestampFin;
  int? cantidad;
  bool co2 = true, ch4 = true, temperatura = true, humedad = true;
  bool mostrarGraficas = false;

  @override
  void initState() {
    super.initState();
    sensores = apiService.fetchSensores();
    _iniciarActualizacionPeriodica();  // Iniciar actualización periódica
  }

  void _iniciarActualizacionPeriodica() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        sensores = apiService.fetchSensores(
          timestampInicio: timestampInicio,
          timestampFin: timestampFin,
          cantidad: (cantidad == null || cantidad! <= 0) ? null : cantidad,
          co2: co2,
          ch4: ch4,
          temperatura: temperatura,
          humedad: humedad,
        );
      });
    });
  }

  void aplicarFiltros() {
    setState(() {
      sensores = apiService.fetchSensores(
        timestampInicio: timestampInicio,
        timestampFin: timestampFin,
        cantidad: (cantidad == null || cantidad! <= 0) ? null : cantidad, // ✅ Si es vacío, traer todos los datos
        co2: co2,
        ch4: ch4,
        temperatura: temperatura,
        humedad: humedad,
      );
      mostrarGraficas = false; // Resetear vista al aplicar filtros
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Cancelar el timer al salir
    super.dispose();
  }

  Future<void> _seleccionarFechaHora(BuildContext context, bool esInicio) async {
    if (!mounted) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate == null || !mounted) return;

    int hora = TimeOfDay.now().hour;
    int minuto = TimeOfDay.now().minute;
    int segundo = 0;
    int milisegundo = 0;

    if (!context.mounted) return;

    bool? resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Seleccionar Hora Completa"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: hora,
                    items: List.generate(24, (index) => index)
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value h"),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => hora = value!),
                  ),
                  DropdownButton<int>(
                    value: minuto,
                    items: List.generate(60, (index) => index)
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value min"),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => minuto = value!),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: segundo,
                    items: List.generate(60, (index) => index)
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text("$value s"),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => segundo = value!),
                  ),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      decoration: const InputDecoration(labelText: "ms"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          milisegundo = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );

    if (resultado == true) {
      final DateTime fechaCompleta = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        hora,
        minuto,
        segundo,
        milisegundo,
      );

      setState(() {
        String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSS").format(fechaCompleta);
        if (esInicio) {
          timestampInicio = formattedDate;
        } else {
          timestampFin = formattedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtrar Sensores")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _seleccionarFechaHora(context, true),
                        child: Text(timestampInicio ?? "Desde"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _seleccionarFechaHora(context, false),
                        child: Text(timestampFin ?? "Hasta"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Cantidad de datos",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      cantidad = int.tryParse(value);
                    });
                  },
                ),
                Row(
                  children: [
                    Checkbox(value: co2, onChanged: (value) => setState(() => co2 = value!)),
                    const Text("CO₂"),
                    Checkbox(value: ch4, onChanged: (value) => setState(() => ch4 = value!)),
                    const Text("CH₄"),
                    Checkbox(value: temperatura, onChanged: (value) => setState(() => temperatura = value!)),
                    const Text("Temp"),
                    Checkbox(value: humedad, onChanged: (value) => setState(() => humedad = value!)),
                    const Text("Humedad"),
                  ],
                ),
                ElevatedButton(
                  onPressed: aplicarFiltros,
                  child: const Text("Aplicar Filtros"),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => mostrarGraficas = !mostrarGraficas),
                  child: Text(mostrarGraficas ? "Ocultar Gráficas" : "Mostrar Gráficas"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: sensores,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final datos = snapshot.data!;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📋 Lista de Datos a la Izquierda
                    Expanded(
                      flex: 1,
                      child: ListView.builder(
                        itemCount: datos.length,
                        itemBuilder: (context, index) {
                          final sensor = datos[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(sensor['timestamp'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (sensor.containsKey("CO2")) Text("CO₂: ${sensor['CO2']} ppm"),
                                  if (sensor.containsKey("CH4")) Text("CH₄: ${sensor['CH4']} ppm"),
                                  if (sensor.containsKey("temperature")) Text("Temp: ${sensor['temperature']}°C"),
                                  if (sensor.containsKey("humidity")) Text("Humedad: ${sensor['humidity']}%"),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                    ),
                    // 📊 Gráficas a la Derecha
                    if (mostrarGraficas)
                      Expanded(
                        flex: 2,
                        child: GraficasScreen(datos: datos),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
