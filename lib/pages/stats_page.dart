import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../voltcell.dart';
import 'dart:convert';
import 'dart:async';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final double maxValue = 4.2;
  List<double> data = [];
  bool isLoading = true;
  final String dataUrl = 'https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/sensorcel.json';

  @override
  void initState() {
    super.initState();
  }

  Future<List<double>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(dataUrl));

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData is List) {
          List<double> fetchedData = jsonData.map((item) {
            if (item is int) {
              return item.toDouble();
            } else if (item is double) {
              return item;
            } else {
              return 0.0;
            }
          }).toList();

          return fetchedData.take(12).toList(); // Ambil 12 data terbaru
        } else {
          throw Exception('Data is not a list');
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Stream<List<double>> dataStream() async* {
    while (true) {
      yield await fetchData();
      await Future.delayed(Duration(seconds: 2)); // Refresh setiap 2 detik
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<double>>(
        stream: dataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<double> data = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 2 / 1, // Perbandingan grafik 2:3
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LineChart(
                            LineChartData(
                              lineBarsData: [
                                LineChartBarData(
                                  spots: data.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value);
                                  }).toList(),
                                  isCurved: true,
                                  color: Color(0xFF30B180),
                                  barWidth: 5,
                                  belowBarData: BarAreaData(show: true, color: Color(0xFF30B180).withOpacity(0.1)),
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                              maxY: 50,
                              minY: 0,
                              minX: 0,
                              maxX: data.length.toDouble() - 1,
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${(value.toInt() * 10).toString().padLeft(2)}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              lineTouchData: LineTouchData(enabled: true),
                              gridData: FlGridData(show: false),
                              borderData: FlBorderData(
                                show: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: data.length > 6 ? 6 : data.length,
                    itemBuilder: (context, index) {
                      double value = data[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              '${index + 1}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  final snackBar = SnackBar(
                                    content: Text('Value: ${value.toStringAsFixed(1)}/$maxValue'),
                                    duration: Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: value / maxValue,
                                    minHeight: 20,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.lerp(Colors.red, Color(0xFF30B180), value / maxValue)!,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressBarPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF30B180), // Warna tombol
                      foregroundColor: Colors.white,
                    ),
                    child: Text('See All'),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('No Data Available'));
          }
        },
      ),
    );
  }
}
