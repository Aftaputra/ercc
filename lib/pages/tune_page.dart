import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TunePage extends StatefulWidget {
  @override
  _TuningState createState() => _TuningState();
}

class _TuningState extends State<TunePage> {
  double dischargeCurrent = 30;
  double temperatureCutoff = 67;
  double voltageCutoff = 31;
  String dropdownValue = 'Medium threshold';

  bool isEditing = false;

  final String _baseUrl = 'https://bmsmipa-default-rtdb.asia-southeast1.firebasedatabase.app/tuning.json';

  @override
  void initState() {
    super.initState();
    _fetchInitialData(dropdownValue);
  }

  void _fetchInitialData(String threshold) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          String key = _getThresholdKey(threshold);
          dischargeCurrent = data[key]['current']?.toDouble() ?? 30.0;
          temperatureCutoff = data[key]['temp']?.toDouble() ?? 67.0;
          voltageCutoff = data[key]['volt']?.toDouble() ?? 31.0;
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _saveData() async {
    Map<String, dynamic> jsonData = {
      "current": dischargeCurrent,
      "temp": temperatureCutoff,
      "volt": voltageCutoff
    };

    String selectedThreshold = _getThresholdKey(dropdownValue);

    try {
      final response = await http.patch(
        Uri.parse(_baseUrl),
        body: json.encode({selectedThreshold: jsonData}),
      );

      if (response.statusCode == 200) {
        print('Data saved successfully');
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  String _getThresholdKey(String threshold) {
    switch (threshold) {
      case 'Low threshold':
        return 'low';
      case 'Medium threshold':
        return 'mid';
      case 'High threshold':
        return 'high';
      default:
        return 'mid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 241, 243, 247),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                underline: SizedBox(),
                items: <String>['Low threshold', 'Medium threshold', 'High threshold']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                    _fetchInitialData(dropdownValue);
                  });
                },
              ),
            ),
            SizedBox(height: 24),
            _buildSlider(
              title: 'Max. discharge current (A)',
              value: dischargeCurrent,
              min: 0,
              max: 100,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        dischargeCurrent = value;
                      });
                    }
                  : null,
            ),
            _buildSlider(
              title: 'Temperature cut-off (C)',
              value: temperatureCutoff,
              min: 0,
              max: 100,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        temperatureCutoff = value;
                      });
                    }
                  : null,
            ),
            _buildSlider(
              title: 'Voltage cut-off (V)',
              value: voltageCutoff,
              min: 0,
              max: 100,
              onChanged: isEditing
                  ? (double value) {
                      setState(() {
                        voltageCutoff = value;
                      });
                    }
                  : null,
            ),
            SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF30B180)),
                      foregroundColor: Color(0xFF30B180),
                    ),
                    child: Text('Edit'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isEditing
                        ? () {
                            setState(() {
                              isEditing = false;
                              _saveData();
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF30B180),
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: TextStyle(color: Colors.black)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: 100,
              label: value.round().toString(),
              onChanged: onChanged,
              activeColor: Color(0xFF30B180),
              inactiveColor: Color(0xFFD6D6D6),
            ),
          ],
        ),
      ),
    );
  }
}
