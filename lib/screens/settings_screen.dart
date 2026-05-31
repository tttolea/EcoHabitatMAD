import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferencesScreen extends StatefulWidget {
  const SettingsPreferencesScreen({super.key});

  @override
  State<SettingsPreferencesScreen> createState() => _SettingsPreferencesScreenState();
}

class _SettingsPreferencesScreenState extends State<SettingsPreferencesScreen> {
  final _usernameFieldController = TextEditingController();
  final _apiKeyFieldController = TextEditingController();
  String _persistedUsername = "Not Configured";
  String _persistedApiKey = "Not Configured";

  @override
  void initState() {
    super.initState();
    _loadStoredPreferences();
  }

  // Safely requests flash key-value properties from storage rows
  Future<void> _loadStoredPreferences() async {
    final storageInstance = await SharedPreferences.getInstance();
    setState(() {
      _persistedUsername = storageInstance.getString('user_name_key') ?? "Guest Explorer";
      _persistedApiKey = storageInstance.getString('api_token_key') ?? "demo_weather_token_99x";

      _usernameFieldController.text = _persistedUsername;
      _apiKeyFieldController.text = _persistedApiKey;
    });
  }

  // Persists configuration adjustments down to device flash rows
  Future<void> _savePreferencesToDisk() async {
    final storageInstance = await SharedPreferences.getInstance();
    await storageInstance.setString('user_name_key', _usernameFieldController.text.trim());
    await storageInstance.setString('api_token_key', _apiKeyFieldController.text.trim());

    _loadStoredPreferences();

    // Satisfies qualitative popup feedback criteria inside your workbook
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚡ Preferences saved successfully to local flash registry!'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              color: Colors.blueGrey,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "SYSTEM PARAMETERS INTERFACE",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Local Storage State Key-Value Persistence Layer",
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameFieldController,
              decoration: const InputDecoration(
                labelText: 'Reserve Inspector Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyFieldController,
              decoration: const InputDecoration(
                labelText: 'OpenWeather API Key Token',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _savePreferencesToDisk,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[800],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("COMMIT CHANGES TO DISK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const Text("Active Storage Registry Dump:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text("Saved Name Variable: $_persistedUsername", style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
            const SizedBox(height: 4),
            Text("Saved Token Variable: $_persistedApiKey", style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
          ],
        ),
      ),
    );
  }
}