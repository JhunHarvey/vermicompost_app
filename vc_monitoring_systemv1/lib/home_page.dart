import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  final bool pumpOn;
  final Function(bool) onPumpToggle;

  const HomePage({
    super.key,
    required this.pumpOn,
    required this.onPumpToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sensorData/latest');
  bool _pumpOn = false;
  bool _manualMode = false; // Add this for mode selection
  Map<String, dynamic>? _lastSensorData;

  @override
  void initState() {
    super.initState();
    _pumpOn = widget.pumpOn;
    _fetchManualMode();
  }

  Future<void> _fetchManualMode() async {
    final snapshot = await _dbRef.child('manualOverride').get();
    setState(() {
      _manualMode = snapshot.value == true;
    });
  }

  Future<void> _setManualMode(bool manual) async {
    setState(() {
      _manualMode = manual;
    });
    await _dbRef.child('manualOverride').set(manual);
  }

  Future<void> _updatePumpState(bool value) async {
    setState(() {
      _pumpOn = value;
    });
    widget.onPumpToggle(value);
    await _dbRef.child('waterPump').set(value ? "ON" : "OFF");
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
                  // Update pump state from database if in automatic mode
                  if (!_manualMode) {
                    final pumpValue = _lastSensorData?['waterPump'];
                    _pumpOn = pumpValue == "ON";
                  }
                }

                final data = _lastSensorData ?? {};

                double temperature = double.tryParse((data['temperature'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture1 = double.tryParse((data['CompostMoisture1'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture2 = double.tryParse((data['CompostMoisture2'] ?? '0').toString().split(' ').first) ?? 0;
                double moisture = ((moisture1 + moisture2) / 2);
                // Change this line:
                // double waterLevel = double.tryParse((data['waterTankLevel'] ?? '0').toString().split(' ').first) ?? 0;
                // String vermiwashLevel = (data['vermiwashTankLevel'] ?? 'UNKNOWN').toString();

                String waterLevel = (data['waterTankLevel'] ?? 'UNKNOWN').toString();
                String vermiwashLevel = (data['vermiwashTankLevel'] ?? 'UNKNOWN').toString();

                final cardData = {
                  'Compost Moisture': {
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
                    'unit': '',
                  },
                  'Vermiwash Level': {
                    'icon': Icons.local_drink,
                    'color': Colors.orange,
                    'value': vermiwashLevel,
                    'unit': '',
                  },
                };

                return Column(
                  children: [
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // Reduced bottom padding
                        childAspectRatio: 1.0,
                        mainAxisSpacing: 16.0,
                        crossAxisSpacing: 16.0,
                        children: [
                          _buildMonitoringCard('Compost Moisture', context, cardData['Compost Moisture']!),
                          _buildMonitoringCard('Temperature', context, cardData['Temperature']!),
                          _buildMonitoringCard('Water Level', context, cardData['Water Level']!),
                          _buildMonitoringCard('Vermiwash Level', context, cardData['Vermiwash Level']!),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Reduced vertical padding
                      child: Column(
                        children: [
                          _buildPumpControlSection(),
                          _buildModeSwitch(),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16), // Reduced from 80 to 16 for more space
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
              // Show sensor details for Compost Moisture card
              if (title == 'Compost Moisture' && data['detail'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  data['detail'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Make both Water Level and Vermiwash Level NOT clickable
    if (title == 'Vermiwash Level' || title == 'Water Level') {
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

  Widget _buildPumpControlSection() {
    // Color logic for background
    final List<Color> bgColors = _pumpOn
        ? [Colors.green[300]!, Colors.green[100]!]
        : [Colors.red[200]!, Colors.red[50]!];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: bgColors,
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
              color: _pumpOn ? Colors.green[900] : Colors.red[900],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pump Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _pumpOn ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      _pumpOn ? 'The pump is ON' : 'The pump is OFF',
                      key: ValueKey(_pumpOn),
                      style: TextStyle(
                        fontSize: 16,
                        color: _pumpOn ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Show switch only in manual mode, but always reserve space
            Opacity(
              opacity: _manualMode ? 1.0 : 0.0,
              child: Switch(
                value: _pumpOn,
                onChanged: _manualMode
                    ? (value) async {
                        await _updatePumpState(value);
                      }
                    : null, // Disable in automatic mode
                activeColor: Colors.green[700],
                activeTrackColor: Colors.green[300],
                inactiveThumbColor: Colors.red[400],
                inactiveTrackColor: Colors.red[200],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Automatic',
            style: TextStyle(
              fontWeight: !_manualMode ? FontWeight.bold : FontWeight.normal,
              color: !_manualMode ? Colors.green[800] : Colors.black54,
              fontSize: 16,
            ),
          ),
          Switch(
            value: _manualMode,
            onChanged: (value) async {
              await _setManualMode(value);
              // If switching to automatic, update pump state from DB
              if (!value) {
                final snapshot = await _dbRef.child('waterPump').get();
                setState(() {
                  _pumpOn = snapshot.value == "ON";
                });
              }
            },
            activeColor: Colors.green[700],
            inactiveThumbColor: Colors.blue[400],
            inactiveTrackColor: Colors.blue[100],
          ),
          Text(
            'Manual',
            style: TextStyle(
              fontWeight: _manualMode ? FontWeight.bold : FontWeight.normal,
              color: _manualMode ? Colors.green[800] : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
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
                  if (title == 'Compsot Moisture' && data['detail'] != null) ...[
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

                  if (title == 'Compost Moisture') ...[
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
                      '50–80% is perfect for worms. They breathe through their skin and need moist conditions.',
                    ),
                    _buildVermicompostingTip(
                      Icons.warning,
                      'Too Dry (<50%)',
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
                      '25°C to 35°C is ideal for red wigglers. Above 35°C can harm them.',
                    ),
                    _buildVermicompostingTip(
                      Icons.ac_unit,
                      'Too Cold (<20°C)',
                      'Worms slow down or die. Add insulation like straw or move bin indoors.',
                    ),
                    _buildVermicompostingTip(
                      Icons.wb_sunny,
                      'Too Hot (>35°C)',
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
      case 'Compost Moisture':
        if (numericValue < 30) {
          recommendation = 'The compost is too dry. Water the compost immediately.';
        } else if (numericValue < 50) {
          recommendation = 'Compost moisture is low. Consider watering soon.';
        } else if (numericValue < 70) {
          recommendation = 'Ideal moisture level. Maintain current watering schedule.';
        } else {
          recommendation = 'Compost is too wet. Reduce watering to prevent root rot.';
        }
        break;
      case 'Temperature':
        if (numericValue < 15) {
          recommendation = 'Temperature is too low for composting. Consider moving to warmer area.';
        } else if (numericValue < 22) {
          recommendation = 'Slightly cool. Monitor plant health.';
        } else if (numericValue < 28) {
          recommendation = 'Ideal temperature range for composting.';
        } else {
          recommendation = 'Temperature is too high. Provide shade and increase watering.';
        }
        break;
      case 'Water Level':
        if (value.toString().toUpperCase() == 'LOW') {
          recommendation = 'Water reservoir is LOW. Refill immediately.';
        } else if (value.toString().toUpperCase() == 'HIGH') {
          recommendation = 'Water reservoir is FULL.';
        } else {
          recommendation = 'Water level status unknown.';
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