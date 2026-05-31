import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/ranking_screen.dart';
import 'screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Import core
import 'firebase_options.dart'; // 2. Import generated options


void main() async {
  // 3. Ensure plugins are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Initialize aFirebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EcoHabitatReserveApp());
}

class EcoHabitatReserveApp extends StatelessWidget {
  const EcoHabitatReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoHabitat Reserve Operations Center',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal[800]),
      ),
      home: const LoginScreen(),
    );
  }
}

class MainTabScreenNavigator extends StatefulWidget {
  const MainTabScreenNavigator({super.key});

  @override
  State<MainTabScreenNavigator> createState() => _MainTabScreenNavigatorState();
}

class _MainTabScreenNavigatorState extends State<MainTabScreenNavigator> {
  int _activeModuleIndex = 0;

  final List<Widget> _operationsScreensStack = [
    const DashboardScreen(),
    const MapInspectionScreen(),
    const CharacterScoreboardScreen(),
    const SettingsPreferencesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'EcoHabitat Reserve Center',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.teal[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()), // Fixed class name here
              );
            },
          )
        ],
      ),
      body: IndexedStack(
        index: _activeModuleIndex,
        children: _operationsScreensStack,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _activeModuleIndex,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        onTap: (targetSelectionIndex) {
          setState(() {
            _activeModuleIndex = targetSelectionIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield_moon_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Field Map'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_outlined), label: 'Rank Score'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Config Panel'),
        ],
      ),
    );
  }
}