import 'package:flutter/material.dart';

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
  final Map<String, dynamic> mockData = {
    'Moisture': {
      'value': 65, 
      'unit': '%', 
      'icon': Icons.water_drop, 
      'color': Colors.blue[700],
    },
    'Temperature': {
      'value': 24, 
      'unit': '°C', 
      'icon': Icons.thermostat, 
      'color': Colors.red[700],
    },
    'Water Level': {
      'value': 80, 
      'unit': '%', 
      'icon': Icons.propane_tank_sharp, 
      'color': Colors.lightBlue[400],
    },
    'Vermitea Level': {
      'value': 45, 
      'unit': '%', 
      'icon': Icons.local_drink, 
      'color': Colors.orange[200],
    },
  };

  void _navigateToDetailPage(BuildContext context, String title) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => DetailPage(
          title: title,
          data: mockData[title],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.3),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
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
          Flexible(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 1.0,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              children: [
                _buildMonitoringCard('Moisture', context),
                _buildMonitoringCard('Temperature', context),
                _buildMonitoringCard('Water Level', context),
                _buildMonitoringCard('Vermitea Level', context),
              ],
            ),
          ),
          _buildValveControlSection(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMonitoringCard(String title, BuildContext context) {
    final data = mockData[title];

    // Define gradient based on category (you can customize each if desired)
    final List<Color> gradientColors = [
      (data['color'] as Color).withOpacity(0.2),
      Colors.white,
    ];

    return InkWell(
      onTap: () => _navigateToDetailPage(context, title),
      borderRadius: BorderRadius.circular(16.0),
      child: Card(
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
            colors: widget.valveOpen
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
            // Valve Icon
            Icon(
              Icons.power_settings_new,
              size: 40,
              color: widget.valveOpen ? Colors.green[900] : Colors.red[900],
            ),
            const SizedBox(width: 16),

            // Valve Info Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valve Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.valveOpen ? Colors.green[900] : Colors.red[900],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Text(
                      widget.valveOpen ? 'The valve is OPEN' : 'The valve is CLOSED',
                      key: ValueKey(widget.valveOpen),
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.valveOpen ? Colors.green[800] : Colors.red[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Switch Button
            Switch(
              value: widget.valveOpen,
              onChanged: (value) {
                widget.onValveToggle(value);
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
      backgroundColor: Colors.green[50], // Set same background as HomePage
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.green[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top section with icon and value
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
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            
            // Recommendations/Details container
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

                  if (title == 'Moisture') ...[
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
                      'Ensure the system doesn’t dry out during hot days. Regularly check levels.',
                    ),
                    _buildVermicompostingTip(
                      Icons.build,
                      'Overflow Risk',
                      'Avoid overfilling to prevent leaks and sensor misreadings.',
                    ),
                  ] else if (title == 'Vermitea Level') ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Vermitea Usage and Storage Tips:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildVermicompostingTip(
                      Icons.local_drink,
                      'Freshness Matters',
                      'Use vermitea within 24–48 hours for maximum microbial benefit.',
                    ),
                    _buildVermicompostingTip(
                      Icons.science,
                      'Brewing Tip',
                      'Use dechlorinated water and aerate well for a quality vermitea batch.',
                    ),
                    _buildVermicompostingTip(
                      Icons.spa,
                      'Application',
                      'Apply directly to plant roots or as foliar spray during early morning or late afternoon.',
                    ),
                  ],
                ],
              ),
            ),

            
            const SizedBox(height: 24),

            // Back button
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
    // Convert value to double if it's not already
    double numericValue = value is int ? value.toDouble() : value;
    
    switch (title) {
      case 'Moisture':
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
      case 'Vermitea Level':
        if (numericValue < 20) {
          recommendation = 'Vermitea level critically low. Prepare more solution.';
        } else if (numericValue < 40) {
          recommendation = 'Vermitea level is moderate. Consider preparing more soon.';
        } else if (numericValue < 60) {
          recommendation = 'Good vermitea level. No immediate action needed.';
        } else {
          recommendation = 'Vermitea reservoir is full.';
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