import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../db/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double ecosystemHealthScore = 100.0;
  int monitoringCycles = 0;
  String reserveLifecycleStage = "Incubation / Germination";
  String inspectorTag = "Guest Inspector";
  String apiToken = "";
  String weatherStatus = "Loading external API...";

  double targetTemperature = 22.0;
  double relativeHumidity = 40.0;
  double ambientLightLux = 500.0;
  double carbonDioxidePpm = 400.0;

  String actionRecommendationsStackText = "Ecosystem state checks optimal. No deviations found.";
  Timer? environmentalTimer;

  @override
  void initState() {
    super.initState();
    _fetchPersistedData();
    environmentalTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _processComprehensiveEcosystemTick();
    });
  }

  Future<void> _fetchPersistedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      inspectorTag = prefs.getString('user_name_key') ?? "Guest Inspector";
      apiToken = prefs.getString('api_token_key') ?? "";
    });
    if (apiToken.isNotEmpty && apiToken != "demo_weather_token_99x") {
      _fetchWeatherData();
    } else {
      setState(() {
        weatherStatus = "API Token missing or default. Skipping HTTP request.";
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    // Madrid coordinates
    final url = Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=40.4168&lon=-3.7038&appid=$apiToken&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          targetTemperature = (data['main']['temp'] as num).toDouble();
          relativeHumidity = (data['main']['humidity'] as num).toDouble();
          weatherStatus = "Live weather synced: ${data['weather'][0]['description']}";
        });
      } else {
        setState(() {
          weatherStatus = "External API Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        weatherStatus = "Failed to fetch remote data.";
      });
    }
  }

  void _processComprehensiveEcosystemTick() {
    if (reserveLifecycleStage == "Ecological Collapse") return;

    setState(() {
      monitoringCycles += 1;
      List<String> anomalyAlerts = [];

      if (targetTemperature < 18.0) {
        ecosystemHealthScore -= 1.0;
        anomalyAlerts.add("⚠️ TEMPERATURE CRITICAL: TOO LOW.\nTurn the heater on or protect local species.");
      } else if (targetTemperature > 24.0) {
        ecosystemHealthScore -= 1.0;
        anomalyAlerts.add("⚠️ TEMPERATURE CRITICAL: TOO HIGH.\nVentilate shelter zones or move assets to shade.");
      }

      if (relativeHumidity < 30.0) {
        ecosystemHealthScore -= 0.1;
        anomalyAlerts.add("⚠️ HUMIDITY DEFICIT: CRITICAL DRYNESS.\nDeploy humidification mist channels or irrigate open spaces.");
      } else if (relativeHumidity > 50.0) {
        ecosystemHealthScore -= 0.1;
        anomalyAlerts.add("⚠️ HUMIDITY EXCESS: WATER SATURATION.\nActivate environmental drainage systems.");
      }

      if (ambientLightLux > 1100.0) {
        ecosystemHealthScore -= 0.5;
        anomalyAlerts.add("⚠️ LIGHT RADIANCY EXCESS: OVEREXPOSURE.\nDim structural lighting arrays or expand canopy cover.");
      }

      if (carbonDioxidePpm > 1200.0) {
        ecosystemHealthScore -= 1.2;
        anomalyAlerts.add("⚠️ CARBON DIOXIDE SPIKE: AIR QUALITY CRISIS.\nOpen windows instantly or initiate environmental safety purges.");
      }

      if (ecosystemHealthScore <= 0) {
        ecosystemHealthScore = 0;
        reserveLifecycleStage = "Ecological Collapse";
        anomalyAlerts = ["❌ ECOSYSTEM CRASH: TOTAL COLLAPSE.\nEnvironmental bounds remained critical too long."];
      }

      if (reserveLifecycleStage != "Ecological Collapse") {
        if (monitoringCycles <= 2) {
          reserveLifecycleStage = "Incubation / Germination";
        } else if (monitoringCycles <= 6) {
          reserveLifecycleStage = "Sapling / Early Growth";
        } else if (monitoringCycles <= 12) {
          reserveLifecycleStage = "Mature Canopy";
        } else if (monitoringCycles <= 16) {
          reserveLifecycleStage = "Ancient Growth Status";
        } else {
          reserveLifecycleStage = "Ecological Collapse";
          ecosystemHealthScore = 0;
          anomalyAlerts = ["❌ MAXIMUM Lifespan reached (18-cycle boundary capacity checked)."];
        }
      }

      if (anomalyAlerts.isEmpty) {
        actionRecommendationsStackText = "🌿 All telemetry arrays balance checks optimal.\nNo corrective action required.";
      } else {
        actionRecommendationsStackText = anomalyAlerts.join("\n\n");
      }
    });

    DatabaseHelper.instance.insertLog(
        40.389235,
        -3.627749,
        "Status: $reserveLifecycleStage - ${ecosystemHealthScore.toStringAsFixed(0)} Score"
    );
  }

  @override
  void dispose() {
    environmentalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.teal[800],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.teal[50],
                      child: Icon(
                          reserveLifecycleStage == "Ecological Collapse" ? Icons.gavel : Icons.nature_people,
                          size: 32, color: Colors.teal[900]
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("RESERVE MATRIX STAGE", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(reserveLifecycleStage, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Inspector: $inspectorTag | Cycles: $monitoringCycles", style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            value: ecosystemHealthScore / 100,
                            backgroundColor: Colors.teal[900],
                            color: ecosystemHealthScore > 35 ? Colors.greenAccent : Colors.redAccent,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(ecosystemHealthScore.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text("Thingsboard IoT Metrics Output Grid Container: $weatherStatus", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
            const SizedBox(height: 6),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildTelemetryGridBox("Temperature", "${targetTemperature.toStringAsFixed(1)}°C", Icons.thermostat, Colors.orange),
                _buildTelemetryGridBox("Humidity", "${relativeHumidity.toStringAsFixed(0)}%", Icons.water_drop, Colors.blue),
                _buildTelemetryGridBox("Light Level", "${ambientLightLux.toStringAsFixed(0)} lx", Icons.wb_sunny, Colors.amber),
                _buildTelemetryGridBox("CO2 Level", "${carbonDioxidePpm.toStringAsFixed(0)} ppm", Icons.cloud, Colors.blueGrey),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Simulate Scenario Testing Anomaly Triggers:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                ActionChip(
                  label: const Text("Optimal State", style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() { targetTemperature = 22.0; relativeHumidity = 40.0; ambientLightLux = 500.0; carbonDioxidePpm = 400.0; }),
                ),
                ActionChip(
                  label: const Text("Heatwave (+1 HP/4s)", style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.orange[50],
                  onPressed: () => setState(() { targetTemperature = 31.5; }),
                ),
                ActionChip(
                  label: const Text("Drought (-0.1 HP/4s)", style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.blue[50],
                  onPressed: () => setState(() { relativeHumidity = 15.0; }),
                ),
                ActionChip(
                  label: const Text("Lux Burst (-0.5 HP/4s)", style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.amber[50],
                  onPressed: () => setState(() { ambientLightLux = 1400.0; }),
                ),
                ActionChip(
                  label: const Text("CO2 Toxic (-1.2 HP/4s)", style: TextStyle(fontSize: 11)),
                  backgroundColor: Colors.purple[50],
                  onPressed: () => setState(() { carbonDioxidePpm = 1750.0; }),
                ),
                ActionChip(
                  label: const Text("Reboot Index Loop", style: TextStyle(fontSize: 11, color: Colors.teal)),
                  onPressed: () => setState(() { ecosystemHealthScore = 100.0; monitoringCycles = 0; reserveLifecycleStage = "Incubation / Germination"; }),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Actionable Recommendation Stack Output Display Container:", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11)),
            const SizedBox(height: 4),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    actionRecommendationsStackText,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.teal[900], height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryGridBox(String metricLabel, String metricValue, IconData iconRef, Color themeColor) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconRef, color: themeColor, size: 20),
            const SizedBox(height: 2),
            Text(metricLabel, style: const TextStyle(fontSize: 9, color: Colors.grey), overflow: TextOverflow.ellipsis),
            Text(metricValue, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}