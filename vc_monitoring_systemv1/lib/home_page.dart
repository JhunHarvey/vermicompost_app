import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  final bool valveOpen;
  final Function(bool) onValveToggle;

  const HomePage({
    super.key,
    required this.valveOpen,
    required this.onValveToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sensorData/latest');
  bool _valveOpen = false;
  Map<String, dynamic>? _lastSensorData;

  @override
  void initState() {
    super.initState();
    _valveOpen = widget.valveOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Monitoring System',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  if (_lastSensorData == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                }

                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  _lastSensorData = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
                }

                final data = _lastSensorData ?? {};

                double temperature = double.tryParse((data['temperature'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture1 = double.tryParse((data['soilMoisture1'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture2 = double.tryParse((data['soilMoisture2'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture = ((moisture1 + moisture2) / 2);
                double waterLevel = double.tryParse((data['waterTankLevel'] ?? '0').toString().split(' ').first) ?? 0;
                String vermiwashLevel = (data['vermiwashTankLevel'] ?? 'UNKNOWN').toString();

                final cardData = {
                  'Soil Moisture': {
                    'icon': Icons.water,
                    'color': Colors.blue,
                    'value': moisture,
                    'unit': '%',
                    'detail': 'Sensor 1: ${moisture1.toStringAsFixed(1)}% | Sensor 2: ${moisture2.toStringAsFixed(1)}%',
                  },
                  'Temperature': {
                    'icon': Icons.thermostat,
                    'color': Colors.red,
                    'value': temperature,
                    'unit': '°C',
                  },
                  'Water Level': {
                    'icon': Icons.opacity,
                    'color': Colors.lightBlue,
                    'value': waterLevel,
                    'unit': waterLevel >= 100 ? ' %' : ' %',
                  },
                  'Vermiwash Level': {
                    'icon': Icons.local_drink,
                    'color': Colors.orange,
                    'value': vermiwashLevel,
                    'unit': '',
                  },
                };

                return GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: [
                    _buildMonitoringCard('Soil Moisture', context, cardData['Soil Moisture']!),
                    _buildMonitoringCard('Temperature', context, cardData['Temperature']!),
                    _buildMonitoringCard('Water Level', context, cardData['Water Level']!),
                    _buildMonitoringCard('Vermiwash Level', context, cardData['Vermiwash Level']!),
                  ],
                );
              },
            ),
          ),
          _buildValveControlSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMonitoringCard(String title, BuildContext context, Map<String, dynamic> data) {
    final List<Color> gradientColors = [
      (data['color'] as Color).withOpacity(0.2),
      Colors.white,
    ];

    final cardContent = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data['icon'], size: 80, color: data['color']),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${data['value']}${data['unit']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (title == 'Vermiwash Level') {
      return cardContent;
    } else {
      return InkWell(
        onTap: () => _navigateToDetailPage(context, title, data),
        borderRadius: BorderRadius.circular(16.0),
        child: cardContent,
      );
    }
  }

  void _navigateToDetailPage(BuildContext context, String title, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: title, data: data),
      ),
    );
  }

  Widget _buildValveControlSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _valveOpen
                ? [Colors.green[300]!, Colors.green[100]!]
                : [Colors.red[200]!, Colors.red[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.power_settings_new,
              size: 40,
              color: _valveOpen ? Colors.green[900] : Colors.red[900],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valve Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _valveOpen ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      _valveOpen ? 'The valve is OPEN' : 'The valve is CLOSED',
                      key: ValueKey(_valveOpen),
                      style: TextStyle(
                        fontSize: 16,
                        color: _valveOpen ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _valveOpen,
              onChanged: (value) async {
                setState(() {
                  _valveOpen = value;
                });
                widget.onValveToggle(value);

                try {
                  await _dbRef.child('waterPump').set(value ? "ON" : "OFF");
                  await _dbRef.child('manualOverride').set(value);
                } catch (e) {
                  print("Failed to update waterPump or manualOverride: $e");
                }
              },
              activeColor: Colors.green[700],
              activeTrackColor: Colors.green[300],
              inactiveThumbColor: Colors.red[400],
              inactiveTrackColor: Colors.red[200],
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final dynamic data;

  const DetailPage({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(data['icon'], size: 80, color: data['color']),
                  const SizedBox(height: 16),
                  Text(
                    '${data['value']}${data['unit']}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (title == 'Soil Moisture' && data['detail'] != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      data['detail'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommendations & Vermicomposting Info',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationText(data['value'], title),
                  const SizedBox(height: 16),

                  if (title == 'Soil Moisture') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Vermicomposting Moisture Guide:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVermicompostingTip(
                      Icons.water_drop,
                      'Ideal Moisture Range',
                      '60–70% is perfect for worms. They breathe through their skin and need moist conditions.',
                    ),
                    _buildVermicompostingTip(
                      Icons.warning,
                      'Too Dry (<40%)',
                      'Worms will dehydrate and composting slows down. Add moist bedding like soaked coconut coir.',
                    ),
                    _buildVermicompostingTip(
                      Icons.warning,
                      'Too Wet (>80%)',
                      'Can cause anaerobic conditions and worm drowning. Add dry bedding like shredded newspaper.',
                    ),
                    _buildVermicompostingTip(
                      Icons.lightbulb_outline,
                      'Quick Fixes',
                      'Squeeze test: Bedding should feel like a wrung-out sponge. If water drips, it\'s too wet.',
                    ),
                  ] else if (title == 'Temperature') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Vermicomposting Temperature Guide:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVermicompostingTip(
                      Icons.thermostat,
                      'Optimal Range',
                      '15°C to 25°C is ideal for red wigglers. Above 30°C can harm them.',
                    ),
                    _buildVermicompostingTip(
                      Icons.ac_unit,
                      'Too Cold (<10°C)',
                      'Worms slow down or die. Add insulation like straw or move bin indoors.',
                    ),
                    _buildVermicompostingTip(
                      Icons.wb_sunny,
                      'Too Hot (>30°C)',
                      'Worms may try to escape. Cool the bin or move it to a shaded area.',
                    ),
                  ] else if (title == 'Water Level') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Water Reservoir Management Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.lightBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVermicompostingTip(
                      Icons.propane_tank,
                      'Keep it Filled',
                      'Ensure the system doesnt dry out during hot days. Regularly check levels.',
                    ),
                    _buildVermicompostingTip(
                      Icons.build,
                      'Overflow Risk',
                      'Avoid overfilling to prevent leaks and sensor misreadings.',
                    ),
                  ]
                  // Vermiwash Level block removed!
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationText(dynamic value, String title) {
    String recommendation = '';
    double numericValue = value is int ? value.toDouble() : value;
    
    switch (title) {
      case 'Soil Moisture':
        if (numericValue < 30) {
          recommendation = 'The soil is too dry. Water the plants immediately.';
        } else if (numericValue < 50) {
          recommendation = 'Soil moisture is low. Consider watering soon.';
        } else if (numericValue < 70) {
          recommendation = 'Ideal moisture level. Maintain current watering schedule.';
        } else {
          recommendation = 'Soil is too wet. Reduce watering to prevent root rot.';
        }
        break;
      case 'Temperature':
        if (numericValue < 15) {
          recommendation = 'Temperature is too low for most plants. Consider moving to warmer area.';
        } else if (numericValue < 22) {
          recommendation = 'Slightly cool. Monitor plant health.';
        } else if (numericValue < 28) {
          recommendation = 'Ideal temperature range for most plants.';
        } else {
          recommendation = 'Temperature is too high. Provide shade and increase watering.';
        }
        break;
      case 'Water Level':
        if (numericValue < 20) {
          recommendation = 'Water reservoir critically low. Refill immediately.';
        } else if (numericValue < 50) {
          recommendation = 'Water level is getting low. Plan to refill soon.';
        } else if (numericValue < 80) {
          recommendation = 'Adequate water supply. No immediate action needed.';
        } else {
          recommendation = 'Water reservoir is full.';
        }
        break;
      case 'Vermiwash Level':
        if (value.toString().toUpperCase() == 'LOW') {
          recommendation = 'Vermiwash level is LOW. Prepare more solution.';
        } else if (value.toString().toUpperCase() == 'HIGH') {
          recommendation = 'Vermiwash level is HIGH. No immediate action needed.';
        } else {
          recommendation = 'Vermiwash level status unknown.';
        }
        break;
      default:
        recommendation = 'No specific recommendations available.';
    }
    
    return Text(
      recommendation,
      style: const TextStyle(
        fontSize: 16,
        height: 1.4,
      ),
    );
  }

  Widget _buildVermicompostingTip(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.green[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}