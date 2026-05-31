import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../db/database_helper.dart';

class CharacterScoreboardScreen extends StatefulWidget {
  const CharacterScoreboardScreen({super.key});

  @override
  State<CharacterScoreboardScreen> createState() => _CharacterScoreboardScreenState();
}

class _CharacterScoreboardScreenState extends State<CharacterScoreboardScreen> {
  List<Map<String, dynamic>> _storedEcosystemHistoryRows = [];
  bool _isDataFetchingActive = true;

  @override
  void initState() {
    super.initState();
    _loadHistoricalEcosystemStateFootprints();
  }

  void _loadHistoricalEcosystemStateFootprints() async {
    final databaseLogs = await DatabaseHelper.instance.getHistoryLogs();

    final compliantEcosystemEntries = databaseLogs.where((row) {
      final conditionValueText = row['condition']?.toString() ?? '';
      return conditionValueText.contains('Status:') || conditionValueText.contains('Observation:');
    }).toList();

    setState(() {
      _storedEcosystemHistoryRows = compliantEcosystemEntries;
      _isDataFetchingActive = false;
    });
  }

  Future<void> _exportAndShareCSV() async {
    if (_storedEcosystemHistoryRows.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No records available to export.")),
      );
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ecosystem_history.csv');

      String csvContent = "ID;Timestamp;Latitude;Longitude;Condition\n";
      for (var row in _storedEcosystemHistoryRows) {
        csvContent += "${row['id']};${row['timestamp']};${row['latitude']};${row['longitude']};${row['condition']}\n";
      }

      await file.writeAsString(csvContent);
      await Share.shareXFiles([XFile(file.path)], text: 'Ecosystem Logs Export');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error generating CSV: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _exportAndShareCSV,
        backgroundColor: Colors.teal[800],
        icon: const Icon(Icons.share, color: Colors.white),
        label: const Text("Export CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.blueGrey[800],
              child: const Padding(
                padding: EdgeInsets.all(14.0),
                child: Text(
                  "CHRONOLOGICAL SCOREBOARD LEADERBOARD",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isDataFetchingActive
                  ? const Center(child: CircularProgressIndicator())
                  : _storedEcosystemHistoryRows.isEmpty
                  ? const Center(child: Text("No simulation run records caught inside database fields yet."))
                  : ListView.builder(
                itemCount: _storedEcosystemHistoryRows.length,
                itemBuilder: (context, index) {
                  final loggingFrame = _storedEcosystemHistoryRows[index];
                  final String loggedCondition = loggingFrame['condition'] ?? 'Telemetry Frame';
                  final bool isManualEntryFlag = loggedCondition.contains('Observation:');

                  return Card(
                    color: isManualEntryFlag ? Colors.teal[50] : Colors.grey[50],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        isManualEntryFlag ? Icons.assignment_turned_in : Icons.history_toggle_off,
                        color: isManualEntryFlag ? Colors.teal : Colors.blueGrey,
                      ),
                      title: Text(
                        loggedCondition.replaceAll('Status: ', ''),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      subtitle: Text(
                        "Log Entry Sync Sequence ID: #${loggingFrame['id']}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}