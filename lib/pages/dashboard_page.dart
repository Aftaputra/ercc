import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardPage extends StatelessWidget {
  final double level;
  final int amperage;
  final String batteryHealth;
  final int voltage;
  final int temperature;

  DashboardPage({
    required this.level,
    required this.amperage,
    required this.batteryHealth,
    required this.voltage,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 241, 243, 247), // Background color
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(16),
            width: double.infinity, // Full horizontal width
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${(level * 100).toStringAsFixed(0)}% - Idle',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '8 h 15 m remaining',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
                CircularPercentIndicator(
                  reverse: true,
                  radius: 38.0, // Setengah dari 76px
                  lineWidth: 10.0, // Sesuaikan dengan ketebalan lingkaran
                  percent: level,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Icon(
                    Icons.bolt,
                    size: 32.0,
                    color: Colors.black,
                  ),
                  progressColor: _getBatteryColor(level), // Warna berubah sesuai level
                  backgroundColor: Colors.grey.shade300,
                ),
                SizedBox(height: 16),
                Text(
                  'Last charge was 7 h ago',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Tambahin space biar nggak nabrak yang bawah
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2 / 1.5,
              children: [
                _buildInfoCard('Amperage', '$amperage mAh', Icons.waves),
                _buildInfoCard('Battery Health', batteryHealth, Icons.battery_charging_full),
                _buildInfoCard('Voltage', '$voltage V', Icons.power),
                _buildInfoCard('Temperature', '$temperature C', Icons.thermostat_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

Color _getBatteryColor(double level) {
  int red, green;

  if (level > 0.5) {
    // Transisi dari Hijau ke Kuning
    red = (48 + (level - 0.5) * 2 * (151 - 48)).toInt();
    green = 177;
  } else {
    // Transisi dari Kuning ke Merah
    red = 151 + ((0.5 - level) * 2 * (177 - 151)).toInt();
    green = (177 - (0.5 - level) * 2 * (177 - 48)).toInt();
  }

  int b = 48; // Biru tetap konstan

  return Color.fromARGB(255, red, green, b);
}


  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
          Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              icon,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
