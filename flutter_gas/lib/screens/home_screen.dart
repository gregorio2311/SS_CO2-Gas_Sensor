import 'package:flutter/material.dart';
import '../widgets/device_card.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _authService = AuthService();

  final List<Widget> _screens = [
    const DataVisualizationScreen(),
    const DevicesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Monitoreo'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Visualización',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.devices),
            label: 'Dispositivos',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade900,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  bool _showFilters = false;
  final Set<String> _selectedDevices = {};
  final Set<String> _selectedSensors = {};

  // Lista de ejemplo de dispositivos disponibles
  final List<String> _availableDevices = [
    'Sensor 1',
    'Sensor 2',
    'Sensor 3',
    'Sensor 4',
  ];

  // Lista de ejemplo de sensores disponibles
  final List<String> _availableSensors = [
    'CO2',
    'Temperatura',
    'Humedad',
    'Presión',
    'Ruido',
  ];

  void _toggleDevice(String device) {
    setState(() {
      if (_selectedDevices.contains(device)) {
        _selectedDevices.remove(device);
      } else {
        _selectedDevices.add(device);
      }
    });
  }

  void _toggleSensor(String sensor) {
    setState(() {
      if (_selectedSensors.contains(sensor)) {
        _selectedSensors.remove(sensor);
      } else {
        _selectedSensors.add(sensor);
      }
    });
  }

  void _applyFilters() {
    // TODO: Implementar lógica de filtrado
    setState(() {
      _showFilters = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDevices.clear();
      _selectedSensors.clear();
      _showFilters = false;
    });
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conectar Dispositivo'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bluetooth_searching,
                  size: 50,
                  color: Colors.blue.shade900,
                ),
                const SizedBox(height: 16),
                const Text('Buscando dispositivos...'),
                const SizedBox(height: 16),
                // Lista de ejemplo de dispositivos BT disponibles
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.bluetooth),
                        title: Text('Dispositivo BT ${index + 1}'),
                        subtitle: Text('00:11:22:33:44:5$index'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // Aquí irá la lógica de conexión
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Conectar'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Dispositivos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: Colors.blue.shade900,
                    ),
                    tooltip: 'Filtrar dispositivos',
                  ),
                ],
              ),
            ),
            if (_showFilters)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dispositivos:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _availableDevices.length,
                                  itemBuilder: (context, index) {
                                    final device = _availableDevices[index];
                                    return CheckboxListTile(
                                      title: Text(device),
                                      value: _selectedDevices.contains(device),
                                      onChanged: (bool? selected) {
                                        if (selected != null) {
                                          _toggleDevice(device);
                                        }
                                      },
                                      activeColor: Colors.blue.shade900,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sensores:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _availableSensors.length,
                                  itemBuilder: (context, index) {
                                    final sensor = _availableSensors[index];
                                    return CheckboxListTile(
                                      title: Text(sensor),
                                      value: _selectedSensors.contains(sensor),
                                      onChanged: (bool? selected) {
                                        if (selected != null) {
                                          _toggleSensor(sensor);
                                        }
                                      },
                                      activeColor: Colors.blue.shade900,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Aplicar Filtros'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Limpiar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const Expanded(
              child: DevicesList(),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _showBluetoothDialog,
            backgroundColor: Colors.blue.shade900,
            tooltip: 'Agregar dispositivo Bluetooth',
            child: const Icon(Icons.bluetooth_audio, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class DevicesList extends StatelessWidget {
  const DevicesList({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo
    final List<Map<String, dynamic>> devices = [
      {
        'name': 'Sensor 1',
        'location': 'Sala Principal',
        'sensorData': {
          'CO2': '450 ppm',
          'Temperatura': '25°C',
          'Humedad': '60%',
        },
      },
      {
        'name': 'Sensor 2',
        'location': 'Oficina',
        'sensorData': {
          'CO2': '380 ppm',
          'Temperatura': '23°C',
          'Humedad': '55%',
        },
      },
    ];

    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return DeviceCard(
          deviceName: device['name'],
          location: device['location'],
          sensorData: device['sensorData'],
          onConfigure: () {
            // TODO: Implementar configuración del dispositivo
          },
        );
      },
    );
  }
}

class DataVisualizationScreen extends StatefulWidget {
  const DataVisualizationScreen({super.key});

  @override
  State<DataVisualizationScreen> createState() => _DataVisualizationScreenState();
}

class _DataVisualizationScreenState extends State<DataVisualizationScreen> {
  bool _showDataFilters = false;
  final Set<String> _selectedDataTypes = {};
  final Set<String> _selectedTimeRanges = {};

  // Lista de ejemplo de tipos de datos
  final List<String> _availableDataTypes = [
    'CO2',
    'Temperatura',
    'Humedad',
    'Presión',
    'Ruido',
  ];

  // Lista de ejemplo de rangos de tiempo
  final List<String> _availableTimeRanges = [
    'Última hora',
    'Último día',
    'Última semana',
    'Último mes',
    'Último año',
  ];

  // Datos de ejemplo
  final List<Map<String, dynamic>> _deviceData = [
    {
      'device': 'Sensor 1',
      'timestamp': '2024-03-07 14:30',
      'data': {
        'CO2': '450 ppm',
        'Temperatura': '25°C',
        'Humedad': '60%',
      },
    },
    {
      'device': 'Sensor 2',
      'timestamp': '2024-03-07 14:30',
      'data': {
        'CO2': '380 ppm',
        'Temperatura': '23°C',
        'Humedad': '55%',
      },
    },
  ];

  void _toggleDataType(String type) {
    setState(() {
      if (_selectedDataTypes.contains(type)) {
        _selectedDataTypes.remove(type);
      } else {
        _selectedDataTypes.add(type);
      }
    });
  }

  void _toggleTimeRange(String range) {
    setState(() {
      if (_selectedTimeRanges.contains(range)) {
        _selectedTimeRanges.remove(range);
      } else {
        _selectedTimeRanges.add(range);
      }
    });
  }

  void _applyDataFilters() {
    // TODO: Implementar lógica de filtrado de datos
    setState(() {
      _showDataFilters = false;
    });
  }

  void _clearDataFilters() {
    setState(() {
      _selectedDataTypes.clear();
      _selectedTimeRanges.clear();
      _showDataFilters = false;
    });
  }

  void _downloadData() {
    // TODO: Implementar lógica de descarga de datos
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descargando datos...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _downloadGraph() {
    // TODO: Implementar lógica de descarga de gráfica
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Descargando gráfica...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Visualización de Datos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showDataFilters = !_showDataFilters;
                  });
                },
                icon: Icon(
                  _showDataFilters ? Icons.filter_list_off : Icons.filter_list,
                  color: Colors.blue.shade900,
                ),
                tooltip: 'Filtrar datos',
              ),
            ],
          ),
        ),
        if (_showDataFilters)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tipos de Datos:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.2,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _availableDataTypes.length,
                              itemBuilder: (context, index) {
                                final type = _availableDataTypes[index];
                                return CheckboxListTile(
                                  title: Text(type),
                                  value: _selectedDataTypes.contains(type),
                                  onChanged: (bool? selected) {
                                    if (selected != null) {
                                      _toggleDataType(type);
                                    }
                                  },
                                  activeColor: Colors.blue.shade900,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rangos de Tiempo:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height * 0.2,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _availableTimeRanges.length,
                              itemBuilder: (context, index) {
                                final range = _availableTimeRanges[index];
                                return CheckboxListTile(
                                  title: Text(range),
                                  value: _selectedTimeRanges.contains(range),
                                  onChanged: (bool? selected) {
                                    if (selected != null) {
                                      _toggleTimeRange(range);
                                    }
                                  },
                                  activeColor: Colors.blue.shade900,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyDataFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Aplicar Filtros'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearDataFilters,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Limpiar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
          child: Row(
            children: [
              // Lista de datos
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Datos de Dispositivos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _downloadData,
                              icon: const Icon(Icons.download),
                              tooltip: 'Descargar datos',
                              color: Colors.blue.shade900,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _deviceData.length,
                          itemBuilder: (context, index) {
                            final data = _deviceData[index];
                            return ListTile(
                              title: Text(data['device']),
                              subtitle: Text(data['timestamp']),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios),
                                onPressed: () {
                                  // TODO: Implementar vista detallada
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Gráfica
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gráfica de Datos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _downloadGraph,
                              icon: const Icon(Icons.download),
                              tooltip: 'Descargar gráfica',
                              color: Colors.blue.shade900,
                            ),
                          ],
                        ),
                      ),
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.analytics,
                                size: 60,
                                color: Colors.blue,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Gráfica en desarrollo',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 