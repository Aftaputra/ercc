import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardPage extends StatefulWidget {
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
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  bool isCooling = false; // Status tombol Cooler (Idle atau Cooling)
  bool isHeating = false; // Status tombol Heater (Idle atau Heating)
  late AnimationController
      _coolerController; // Controller untuk animasi rotasi Cooler
  late AnimationController
      _heaterController; // Controller untuk animasi "breathing" Heater

  @override
  void initState() {
    super.initState();
    _coolerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _heaterController = AnimationController(
      duration: const Duration(seconds: 1), // Durasi animasi breathing
      vsync: this,
      lowerBound: 0.6, // Ukuran minimum
      upperBound: 1.0, // Ukuran maksimum
    )..repeat(reverse: true); // Ulangi animasi secara bolak-balik
  }

  @override
  void dispose() {
    _coolerController.dispose(); // Hentikan controller saat widget dibuang
    _heaterController.dispose();
    super.dispose();
  }

  void _toggleCooling() {
    setState(() {
      if (!isCooling) {
        // Jika cooler aktif, matikan heater
        isCooling = true;
        isHeating = false;
        _coolerController.repeat(); // Mulai animasi berputar
        _heaterController.stop(); // Hentikan animasi Heater
      } else {
        // Jika cooler sudah aktif, nonaktifkan cooler
        isCooling = false;
        _coolerController.stop(); // Hentikan animasi
      }
    });
  }

  void _toggleHeating() {
    setState(() {
      if (!isHeating) {
        // Jika heater aktif, matikan cooler
        isHeating = true;
        isCooling = false;
        _heaterController.repeat(reverse: true); // Mulai animasi Heater
        _coolerController.stop(); // Hentikan animasi Cooler
      } else {
        // Jika heater sudah aktif, nonaktifkan heater
        isHeating = false;
        _heaterController.stop();
      }
    });
  }

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
                  isCooling
                      ? '${(widget.level * 100).toStringAsFixed(0)}% - Cooling'
                      : isHeating
                          ? '${(widget.level * 100).toStringAsFixed(0)}% - Heating'
                          : '${(widget.level * 100).toStringAsFixed(0)}% - Idle',
                  style: TextStyle(
                    color: isCooling ? Colors.blue : isHeating ? Colors.amber : Colors.black,
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
                  percent: widget.level,
                  circularStrokeCap: CircularStrokeCap.round,
                  center: Icon(
                    Icons.bolt,
                    size: 32.0,
                    color: isCooling ? Colors.green : isHeating ? Colors.orange : Colors.black,
                  ),
                  progressColor: _getBatteryColor(
                      widget.level), // Warna berubah sesuai level
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
          SizedBox(height: 16),
          // COOLER and HEATER BUTTONS
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleCooling, // Ubah state saat tombol ditekan
                  child: AnimatedContainer(
                    duration:
                        Duration(milliseconds: 300), // Animasi perubahan warna
                    decoration: BoxDecoration(
                      gradient: isCooling
                          ? null // Jika Cooling, tidak ada gradasi, warna putih dengan border biru
                          : LinearGradient(
                              colors: [
                                Colors.greenAccent,
                                Colors.blue.shade800,
                                Colors.blue.shade600,
                                Colors.black,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isCooling ? Colors.white : null,
                      borderRadius: BorderRadius.circular(20),
                      border: isCooling
                          ? Border.all(color: Colors.black12, width: 2)
                          : Border.all(color: Colors.white, width: 2),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Rotating Icon for Cooler
                        RotationTransition(
                          turns:
                              _coolerController, // Menggunakan controller untuk animasi rotasi
                          child: Icon(
                            Icons.ac_unit_rounded,
                            color: isCooling ? Colors.blue.shade200 : Colors.white,
                            size: 26,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          isCooling ? 'Cooler' : 'Cooler',
                          style: TextStyle(
                            color: isCooling ? Colors.black : Colors.white,
                            fontSize: 24,
                            fontWeight:
                                isCooling ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16), // Jarak antara dua tombol
              Expanded(
                child: GestureDetector(
                  onTap: _toggleHeating, // Ubah state saat tombol ditekan
                  child: AnimatedContainer(
                    duration:
                        Duration(milliseconds: 300), // Animasi perubahan warna
                    decoration: BoxDecoration(
                      gradient: isHeating
                          ? null // Jika Heating, tidak ada gradasi, warna putih dengan border biru
                          : LinearGradient(
                              colors: [
                                Colors.orange.shade400,
                                Colors.red.shade700,
                                Colors.red.shade900,
                                Colors.yellow,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: isHeating ? Colors.white : null,
                      borderRadius: BorderRadius.circular(20),
                      border: isHeating
                          ? Border.all(color: Colors.black12, width: 2)
                          : Border.all(color: Colors.white, width: 2),
                    ),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Breathing Icon for Heater
                        ScaleTransition(
                          scale: _heaterController, // Menggunakan controller untuk animasi "breathing"
                          child: Icon(
                            Icons.wb_sunny_rounded,
                            color: isHeating ? Colors.orangeAccent : Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          isHeating ? 'Heater' : 'Heater',
                          style: TextStyle(
                            color: isHeating ? Colors.black : Colors.white,
                            fontSize: 24,
                            fontWeight:
                                isHeating ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // End of COOLER and HEATER BUTTONS
          SizedBox(height: 16), // Tambahin space biar nggak nabrak yang bawah
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2 / 1.5,
              children: [
                _buildInfoCard(
                    'Amperage', '${widget.amperage} mAh', Icons.waves),
                _buildInfoCard('Battery Health', widget.batteryHealth,
                    Icons.battery_charging_full),
                _buildInfoCard('Voltage', '${widget.voltage} V', Icons.power),
                _buildInfoCard('Temperature', '${widget.temperature} C',
                    Icons.thermostat_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(double level) {
    int red = 50;
    int green = 50;
    int blue = 50; // Biru tetap konstan
    if (isCooling) {
      red = 0;
      green = 75;
      blue = 150;
    } else if (isHeating) {
      red = 200;
      green = 100;
      blue = 0;
    } else {
      if (level > 0.5) {
        // Transisi dari hijau ke kuning
        green = 255;
        red = (255 * (1.0 - level) * 2.0).toInt();
      } else {
        // Transisi dari kuning ke merah
        red = 255;
        green = (255 * level * 2.0).toInt();
      }
    }
    return Color.fromARGB(255, red, green, blue);
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
